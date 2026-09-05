<?php
/**
 * Flowtive Central ERP - Dashboard API
 * Enhanced with cashier performance, unexpected profit tracking, and date range filtering support
 */

error_reporting(0);
ini_set('display_errors', 0);

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }

try {
    require_once '../config/database.php';
    $authUser = getAuthenticatedUser();

    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        exit;
    }

    $db = getDB();
    
    $startDate = $_GET['start'] ?? date('Y-m-d');
    $endDate = $_GET['end'] ?? date('Y-m-d');
    
    // Validate dates
    $start = date('Y-m-d', strtotime($startDate));
    $end = date('Y-m-d', strtotime($endDate));
    
    // Range-specific statistics for KPI cards
    $rangeStats = $db->fetchOne(
        "SELECT 
            COUNT(*) as total_orders,
            COALESCE(SUM(total), 0) as total_revenue,
            COALESCE(SUM(profit), 0) as total_profit,
            COALESCE(SUM(unexpected_profit), 0) as unexpected_profit,
            COALESCE(SUM(CASE WHEN payment_status IN ('debt', 'partial') THEN (total - COALESCE(amount_paid, 0)) ELSE 0 END), 0) as active_debts,
            COALESCE(AVG(total), 0) as avg_order
         FROM sales 
         WHERE DATE(sale_date) BETWEEN ? AND ?",
        [$start, $end]
    ) ?: ['total_orders' => 0, 'total_revenue' => 0, 'total_profit' => 0, 'unexpected_profit' => 0, 'active_debts' => 0, 'avg_order' => 0];
    
    // Today's statistics with unexpected profit
    $todayStats = $db->fetchOne(
        "SELECT 
            COUNT(*) as orders_count,
            COALESCE(SUM(total), 0) as revenue,
            COALESCE(SUM(profit), 0) as profit,
            COALESCE(SUM(unexpected_profit), 0) as unexpected_profit
         FROM sales 
         WHERE DATE(sale_date) = CURDATE()"
    ) ?: ['orders_count' => 0, 'revenue' => 0, 'profit' => 0, 'unexpected_profit' => 0];
    
    // Yesterday's statistics for comparison
    $yesterdayStats = $db->fetchOne(
        "SELECT COALESCE(SUM(total), 0) as revenue FROM sales WHERE DATE(sale_date) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)"
    ) ?: ['revenue' => 0];
    
    // This week statistics
    $weekStats = $db->fetchOne(
        "SELECT 
            COUNT(*) as orders_count,
            COALESCE(SUM(total), 0) as revenue,
            COALESCE(SUM(profit), 0) as profit,
            COALESCE(SUM(unexpected_profit), 0) as unexpected_profit
         FROM sales 
         WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)"
    ) ?: ['orders_count' => 0, 'revenue' => 0, 'profit' => 0, 'unexpected_profit' => 0];
    
    // This month statistics
    $monthStats = $db->fetchOne(
        "SELECT 
            COUNT(*) as orders_count,
            COALESCE(SUM(total), 0) as revenue,
            COALESCE(SUM(profit), 0) as profit,
            COALESCE(SUM(unexpected_profit), 0) as unexpected_profit
         FROM sales 
         WHERE MONTH(sale_date) = MONTH(CURDATE()) AND YEAR(sale_date) = YEAR(CURDATE())"
    ) ?: ['orders_count' => 0, 'revenue' => 0, 'profit' => 0, 'unexpected_profit' => 0];
    
    // Inventory statistics with potential sales value
    $inventoryStats = $db->fetchOne(
        "SELECT 
            COUNT(*) as total_products,
            COALESCE(SUM(current_stock * cost_price), 0) as inventory_value,
            COALESCE(SUM(current_stock * selling_price), 0) as potential_sales_value,
            SUM(CASE WHEN current_stock <= minimum_stock THEN 1 ELSE 0 END) as low_stock_count,
            SUM(CASE WHEN current_stock = 0 THEN 1 ELSE 0 END) as out_of_stock_count
         FROM products WHERE status = 'active'"
    ) ?: ['total_products' => 0, 'inventory_value' => 0, 'potential_sales_value' => 0, 'low_stock_count' => 0, 'out_of_stock_count' => 0];
    
    $margin = 0;
    if ($rangeStats['total_revenue'] > 0) {
        $margin = ($rangeStats['total_profit'] / $rangeStats['total_revenue']) * 100;
    }

    // Cashier performance data
    $cashierPerformance = $db->fetchAll(
        "SELECT 
            u.id as user_id,
            u.full_name,
            u.username,
            COUNT(s.id) as total_sales,
            COALESCE(SUM(s.total), 0) as total_revenue,
            COALESCE(SUM(s.profit), 0) as total_profit,
            COALESCE(SUM(s.unexpected_profit), 0) as unexpected_profit,
            COALESCE(AVG(s.total), 0) as avg_order_value
         FROM users u
         LEFT JOIN sales s ON u.id = s.user_id AND DATE(s.sale_date) = CURDATE()
         WHERE u.role IN ('Cashier', 'Manager', 'Admin', 'Super Admin') AND u.status = 'active'
         GROUP BY u.id, u.full_name, u.username
         ORDER BY total_revenue DESC"
    ) ?: [];
    
    // Cashier performance for selected date range
    $cashierPerf = $db->fetchAll(
        "SELECT 
            u.full_name as name,
            COALESCE(SUM(s.total), 0) as sales
         FROM users u
         LEFT JOIN sales s ON u.id = s.user_id 
         AND DATE(s.sale_date) BETWEEN ? AND ?
         WHERE u.role IN ('Cashier', 'Manager', 'Admin', 'Super Admin') AND u.status = 'active'
         GROUP BY u.id, u.full_name
         ORDER BY sales DESC
         LIMIT 10",
        [$start, $end]
    ) ?: [];
    
    // Recent sales for selected date range
    $recentSales = $db->fetchAll(
        "SELECT s.*, u.full_name as cashier_name 
         FROM sales s 
         LEFT JOIN users u ON s.user_id = u.id 
         WHERE DATE(s.sale_date) BETWEEN ? AND ?
         ORDER BY s.sale_date DESC 
         LIMIT 20",
        [$start, $end]
    ) ?: [];
    
    // Recent orders
    $recentOrders = $db->fetchAll(
        "SELECT s.*, u.full_name as cashier_name,
         CASE 
            WHEN s.payment_status = 'paid' THEN 'Completed'
            WHEN s.payment_status = 'partial' THEN 'Partial Payment'
            WHEN s.payment_status = 'debt' THEN 'Debt'
            ELSE 'Pending'
         END as status_display
         FROM sales s 
         LEFT JOIN users u ON s.user_id = u.id 
         WHERE DATE(s.sale_date) BETWEEN ? AND ?
         ORDER BY s.sale_date DESC 
         LIMIT 10",
        [$start, $end]
    ) ?: [];
    
    // Low stock products
    $lowStockProducts = $db->fetchAll(
        "SELECT p.*, c.name as category_name 
         FROM products p 
         LEFT JOIN categories c ON p.category_id = c.id 
         WHERE p.current_stock <= p.minimum_stock AND p.status = 'active' 
         ORDER BY p.current_stock ASC 
         LIMIT 10"
    ) ?: [];
    
    // Top selling products for selected date range
    $topProducts = $db->fetchAll(
        "SELECT p.id, p.name, p.sku, COALESCE(SUM(si.quantity), 0) as sold_quantity, COALESCE(SUM(si.total), 0) as sold_value
         FROM products p
         LEFT JOIN sale_items si ON p.id = si.product_id
         LEFT JOIN sales s ON si.sale_id = s.id AND DATE(s.sale_date) BETWEEN ? AND ?
         WHERE p.status = 'active'
         GROUP BY p.id, p.name, p.sku
         HAVING sold_quantity > 0
         ORDER BY sold_quantity DESC
         LIMIT 5",
        [$start, $end]
    ) ?: [];
    
    // Add rank to top products
    foreach ($topProducts as $idx => &$product) {
        $product['rank'] = $idx + 1;
    }
    
    $priceAdjustments = $db->fetchAll(
        "SELECT 
            si.id,
            si.sale_id,
            s.order_number,
            si.product_id,
            si.product_name,
            p.selling_price as original_price,
            si.unit_price as adjusted_price,
            si.quantity,
            (si.unit_price - p.selling_price) * si.quantity as price_difference,
            s.sale_date
         FROM sale_items si
         JOIN sales s ON si.sale_id = s.id
         JOIN products p ON si.product_id = p.id
         WHERE DATE(s.sale_date) BETWEEN ? AND ?
         AND si.unit_price != p.selling_price
         ORDER BY s.sale_date DESC",
        [$start, $end]
    ) ?: [];
    
    // Calculate total unexpected profit/loss from price adjustments
    $totalUnexpectedProfit = 0;
    $totalUnexpectedLoss = 0;
    foreach ($priceAdjustments as $adj) {
        $diff = floatval($adj['price_difference']);
        if ($diff > 0) {
            $totalUnexpectedProfit += $diff;
        } else {
            $totalUnexpectedLoss += abs($diff);
        }
    }
    
    // Pending debts
    $pendingDebts = $db->fetchOne(
        "SELECT COUNT(*) as count, COALESCE(SUM(total - COALESCE(amount_paid, 0)), 0) as total 
         FROM sales WHERE payment_status IN ('debt', 'partial')"
    ) ?: ['count' => 0, 'total' => 0];

    // Debt status breakdown (Paid / Pending / Overdue) for the selected range - powers the donut chart
    $debtBreakdown = $db->fetchOne(
        "SELECT 
            SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) as paid_count,
            SUM(CASE WHEN payment_status = 'partial' THEN 1 ELSE 0 END) as pending_count,
            SUM(CASE WHEN payment_status = 'debt' THEN 1 ELSE 0 END) as overdue_count,
            COALESCE(SUM(CASE WHEN payment_status = 'paid' THEN total ELSE 0 END), 0) as paid_amount,
            COALESCE(SUM(CASE WHEN payment_status = 'partial' THEN (total - COALESCE(amount_paid, 0)) ELSE 0 END), 0) as pending_amount,
            COALESCE(SUM(CASE WHEN payment_status = 'debt' THEN (total - COALESCE(amount_paid, 0)) ELSE 0 END), 0) as overdue_amount
         FROM sales 
         WHERE DATE(sale_date) BETWEEN ? AND ?",
        [$start, $end]
    ) ?: ['paid_count' => 0, 'pending_count' => 0, 'overdue_count' => 0, 'paid_amount' => 0, 'pending_amount' => 0, 'overdue_amount' => 0];

    // Inventory turnover ratio = revenue generated relative to inventory value on hand
    $inventoryTurnover = 0;
    if (floatval($inventoryStats['inventory_value']) > 0) {
        $inventoryTurnover = floatval($rangeStats['total_revenue']) / floatval($inventoryStats['inventory_value']);
    }
    
    // Revenue growth calculation
    $revenueGrowth = 0;
    if ($yesterdayStats['revenue'] > 0) {
        $revenueGrowth = (($todayStats['revenue'] - $yesterdayStats['revenue']) / $yesterdayStats['revenue']) * 100;
    }
    
    // Daily sales for chart (for selected date range)
    $dailySalesRange = $db->fetchAll(
        "SELECT DATE(sale_date) as date, COUNT(*) as orders, 
         COALESCE(SUM(total), 0) as revenue,
         COALESCE(SUM(profit), 0) as profit
         FROM sales 
         WHERE DATE(sale_date) BETWEEN ? AND ?
         GROUP BY DATE(sale_date) 
         ORDER BY date ASC",
        [$start, $end]
    ) ?: [];
    
    $salesLabels = [];
    $salesData = [];
    $profitData = [];
    foreach ($dailySalesRange as $day) {
        $salesLabels[] = date('M d', strtotime($day['date']));
        $salesData[] = floatval($day['revenue']);
        $profitData[] = floatval($day['profit']);
    }
    
    // Sales by category for selected date range
    $categoryData = $db->fetchAll(
        "SELECT c.name, COALESCE(SUM(si.total), 0) as value
         FROM categories c
         LEFT JOIN products p ON c.id = p.category_id
         LEFT JOIN sale_items si ON p.id = si.product_id
         LEFT JOIN sales s ON si.sale_id = s.id AND DATE(s.sale_date) BETWEEN ? AND ?
         GROUP BY c.id, c.name
         HAVING value > 0
         ORDER BY value DESC",
        [$start, $end]
    ) ?: [];
    
    // Payment methods breakdown for selected date range
    $paymentMethodsRange = $db->fetchAll(
        "SELECT payment_method as name, COALESCE(SUM(total), 0) as value
         FROM sales 
         WHERE DATE(sale_date) BETWEEN ? AND ?
         GROUP BY payment_method",
        [$start, $end]
    ) ?: [];
    
    // Hourly sales for today (used when single day is selected)
    $hourlySales = $db->fetchAll(
        "SELECT HOUR(sale_date) as hour, COUNT(*) as orders, COALESCE(SUM(total), 0) as revenue
         FROM sales 
         WHERE DATE(sale_date) = ?
         GROUP BY HOUR(sale_date)
         ORDER BY hour ASC",
        [$start]
    ) ?: [];
    
    // Total customers
    $customerStats = $db->fetchOne(
        "SELECT 
            COUNT(*) as total_customers,
            (SELECT COUNT(*) FROM customers WHERE DATE(created_at) = CURDATE()) as new_today
         FROM customers"
    ) ?: ['total_customers' => 0, 'new_today' => 0];
    
    echo json_encode([
        'success' => true,
        'total_revenue' => floatval($rangeStats['total_revenue']),
        'total_profit' => floatval($rangeStats['total_profit']),
        'total_orders' => intval($rangeStats['total_orders']),
        'active_debts' => floatval($rangeStats['active_debts']),
        'inventory_value' => floatval($inventoryStats['inventory_value']),
        'low_stock_count' => intval($inventoryStats['low_stock_count']),
        'product_count' => intval($inventoryStats['total_products']),
        'margin' => round($margin, 1),
        'inventory_turnover' => round($inventoryTurnover, 2),
        'avg_order' => floatval($rangeStats['avg_order']),
        'total_unexpected_profit' => $totalUnexpectedProfit,
        'total_unexpected_loss' => $totalUnexpectedLoss,
        'outstanding_debts' => floatval($pendingDebts['total']),
        'data' => [
            'today' => [
                'revenue' => floatval($todayStats['revenue']),
                'orders' => intval($todayStats['orders_count']),
                'profit' => floatval($todayStats['profit']),
                'unexpected_profit' => floatval($todayStats['unexpected_profit'] ?? 0),
                'growth' => round($revenueGrowth, 1)
            ],
            'week' => [
                'revenue' => floatval($weekStats['revenue']),
                'orders' => intval($weekStats['orders_count']),
                'profit' => floatval($weekStats['profit']),
                'unexpected_profit' => floatval($weekStats['unexpected_profit'] ?? 0)
            ],
            'month' => [
                'revenue' => floatval($monthStats['revenue']),
                'orders' => intval($monthStats['orders_count']),
                'profit' => floatval($monthStats['profit']),
                'unexpected_profit' => floatval($monthStats['unexpected_profit'] ?? 0)
            ],
            'inventory' => [
                'total_products' => intval($inventoryStats['total_products']),
                'inventory_value' => floatval($inventoryStats['inventory_value']),
                'potential_sales_value' => floatval($inventoryStats['potential_sales_value']),
                'low_stock_count' => intval($inventoryStats['low_stock_count']),
                'out_of_stock_count' => intval($inventoryStats['out_of_stock_count'])
            ],
            'customers' => [
                'total' => intval($customerStats['total_customers']),
                'new_today' => intval($customerStats['new_today'])
            ],
            'debts' => [
                'count' => intval($pendingDebts['count']),
                'total' => floatval($pendingDebts['total'])
            ],
            'debt_breakdown' => [
                'paid_count' => intval($debtBreakdown['paid_count']),
                'pending_count' => intval($debtBreakdown['pending_count']),
                'overdue_count' => intval($debtBreakdown['overdue_count']),
                'paid_amount' => floatval($debtBreakdown['paid_amount']),
                'pending_amount' => floatval($debtBreakdown['pending_amount']),
                'overdue_amount' => floatval($debtBreakdown['overdue_amount'])
            ],
            'cashier_performance' => $cashierPerformance,
            'cashier_performance_range' => $cashierPerf,
            'recent_sales' => $recentSales,
            'recent_orders' => $recentOrders,
            'low_stock_products' => $lowStockProducts,
            'top_products' => $topProducts,
            'price_adjustments' => $priceAdjustments,
            'daily_sales' => $dailySalesRange,
            'hourly_sales' => $hourlySales,
            'payment_methods' => $paymentMethodsRange,
            'payment_methods_range' => $paymentMethodsRange,
            'sales_trend' => [
                'labels' => $salesLabels,
                'data' => $salesData
            ],
            'category_distribution' => $categoryData,
            'rev_profit_trend' => [
                'labels' => $salesLabels,
                'revenue' => $salesData,
                'profit' => $profitData
            ]
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
