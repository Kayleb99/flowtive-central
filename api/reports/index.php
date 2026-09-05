<?php
/**
 * Flowtive Central ERP - Reports API
 * Generates comprehensive business reports
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

try {
    $db = getDB();
    
    $type = $_GET['type'] ?? 'sales';
    $startDate = $_GET['start'] ?? date('Y-m-01');
    $endDate = $_GET['end'] ?? date('Y-m-d');
    
    $report = [];
    
    switch ($type) {
        case 'sales':
            // Sales report with items
            $sales = $db->fetchAll(
                "SELECT s.*, u.full_name as cashier_name, c.name as customer_name
                 FROM sales s
                 LEFT JOIN users u ON s.user_id = u.id
                 LEFT JOIN customers c ON s.customer_id = c.id
                 WHERE DATE(s.sale_date) >= ? AND DATE(s.sale_date) <= ?
                 ORDER BY s.sale_date DESC",
                [$startDate, $endDate]
            );
            
            foreach ($sales as &$sale) {
                $sale['items'] = $db->fetchAll(
                    "SELECT * FROM sale_items WHERE sale_id = ?",
                    [$sale['id']]
                );
            }
            
            $summary = $db->fetchOne(
                "SELECT COUNT(*) as total_orders,
                 COALESCE(SUM(total), 0) as total_revenue,
                 COALESCE(SUM(profit), 0) as total_profit,
                 COALESCE(SUM(unexpected_profit), 0) as unexpected_profit,
                 COALESCE(AVG(total), 0) as avg_order_value
                 FROM sales
                 WHERE DATE(sale_date) >= ? AND DATE(sale_date) <= ?",
                [$startDate, $endDate]
            );
            
            $report = [
                'type' => 'Sales Report',
                'period' => "$startDate to $endDate",
                'summary' => $summary,
                'data' => $sales
            ];
            break;
            
        case 'inventory':
            // Inventory report with stock levels
            $products = $db->fetchAll(
                "SELECT p.*, c.name as category_name, u.name as unit_name,
                 (p.current_stock * p.cost_price) as stock_value,
                 (p.current_stock * p.selling_price) as potential_value
                 FROM products p
                 LEFT JOIN categories c ON p.category_id = c.id
                 LEFT JOIN units u ON p.unit_id = u.id
                 WHERE p.status = 'active'
                 ORDER BY p.name ASC"
            );
            
            $summary = $db->fetchOne(
                "SELECT COUNT(*) as total_products,
                 SUM(current_stock) as total_units,
                 COALESCE(SUM(current_stock * cost_price), 0) as total_stock_value,
                 COALESCE(SUM(current_stock * selling_price), 0) as potential_sales_value,
                 SUM(CASE WHEN current_stock <= minimum_stock THEN 1 ELSE 0 END) as low_stock_count
                 FROM products WHERE status = 'active'"
            );
            
            $report = [
                'type' => 'Inventory Report',
                'period' => "As of $endDate",
                'summary' => $summary,
                'data' => $products
            ];
            break;
            
        case 'profit':
            // Profit analysis report
            $daily = $db->fetchAll(
                "SELECT DATE(sale_date) as date,
                 COUNT(*) as orders,
                 COALESCE(SUM(total), 0) as revenue,
                 COALESCE(SUM(profit), 0) as profit,
                 COALESCE(SUM(unexpected_profit), 0) as unexpected_profit
                 FROM sales
                 WHERE DATE(sale_date) >= ? AND DATE(sale_date) <= ?
                 GROUP BY DATE(sale_date)
                 ORDER BY date ASC",
                [$startDate, $endDate]
            );
            
            $byCategory = $db->fetchAll(
                "SELECT c.name as category,
                 COALESCE(SUM(si.total), 0) as revenue,
                 COALESCE(SUM(si.profit), 0) as profit
                 FROM categories c
                 LEFT JOIN products p ON c.id = p.category_id
                 LEFT JOIN sale_items si ON p.id = si.product_id
                 LEFT JOIN sales s ON si.sale_id = s.id
                 WHERE DATE(s.sale_date) >= ? AND DATE(s.sale_date) <= ?
                 GROUP BY c.id
                 ORDER BY profit DESC",
                [$startDate, $endDate]
            );
            
            $summary = $db->fetchOne(
                "SELECT 
                 COALESCE(SUM(total), 0) as total_revenue,
                 COALESCE(SUM(profit), 0) as total_profit,
                 COALESCE(SUM(total - profit), 0) as total_cost,
                 COALESCE(SUM(unexpected_profit), 0) as total_unexpected_profit,
                 CASE WHEN SUM(total) > 0 THEN (SUM(profit) / SUM(total) * 100) ELSE 0 END as profit_margin
                 FROM sales
                 WHERE DATE(sale_date) >= ? AND DATE(sale_date) <= ?",
                [$startDate, $endDate]
            );
            
            $report = [
                'type' => 'Profit Report',
                'period' => "$startDate to $endDate",
                'summary' => $summary,
                'daily' => $daily,
                'by_category' => $byCategory,
                'data' => $daily // Include data array for consistency
            ];
            break;
            
        case 'cashier':
            // Ensure split_cash / split_mobile columns exist (self-healing migration).
            // Silently ignore if they already exist (MySQL error 1060 = Duplicate column).
            foreach (['split_cash', 'split_mobile'] as $col) {
                try {
                    $db->query("ALTER TABLE sales ADD COLUMN {$col} DECIMAL(15,2) DEFAULT NULL");
                } catch (Exception $e) {
                    // Column already exists — safe to ignore
                }
            }

            // Cashier performance report with payment method breakdown.
            // Uses COALESCE(split_cash/split_mobile, 0) so rows inserted before
            // the migration (without those columns) are counted as 0.
            $performance = $db->fetchAll(
                "SELECT u.id, u.full_name, u.username,
                 COUNT(s.id) as total_sales,
                 COALESCE(SUM(s.total), 0) as total_revenue,
                 COALESCE(SUM(s.profit), 0) as total_profit,
                 COALESCE(SUM(s.unexpected_profit), 0) as unexpected_profit,
                 COALESCE(AVG(s.total), 0) as avg_order_value,
                 COUNT(CASE WHEN s.payment_method IN ('cash','split') THEN 1 END) as cash_sales,
                 COUNT(CASE WHEN s.payment_method IN ('mobile','mpesa','split') THEN 1 END) as mobile_sales,
                 COALESCE(SUM(
                     CASE
                         WHEN s.payment_method = 'cash'   THEN s.total
                         WHEN s.payment_method = 'split'  THEN COALESCE(s.split_cash, 0)
                         ELSE 0
                     END
                 ), 0) as cash_revenue,
                 COALESCE(SUM(
                     CASE
                         WHEN s.payment_method IN ('mobile','mpesa') THEN s.total
                         WHEN s.payment_method = 'split'             THEN COALESCE(s.split_mobile, 0)
                         ELSE 0
                     END
                 ), 0) as mobile_revenue
                 FROM users u
                 LEFT JOIN sales s ON u.id = s.user_id
                     AND DATE(s.sale_date) >= ? AND DATE(s.sale_date) <= ?
                 WHERE u.role IN ('Cashier', 'Manager', 'Admin', 'Super Admin')
                 GROUP BY u.id, u.full_name, u.username
                 ORDER BY total_revenue DESC",
                [$startDate, $endDate]
            );

            $totalRevenue = array_sum(array_column($performance, 'total_revenue'));
            $totalSales   = array_sum(array_column($performance, 'total_sales'));

            $report = [
                'type'    => 'Cashier Performance Report',
                'period'  => "$startDate to $endDate",
                'summary' => [
                    'total_cashiers' => count($performance),
                    'total_orders'   => $totalSales,
                    'total_revenue'  => $totalRevenue,
                ],
                'data' => $performance
            ];
            break;
        
        case 'debts':
            $debts = $db->fetchAll(
                "SELECT s.*, u.full_name as cashier_name, c.name as customer_name,
                 (s.total - COALESCE(s.amount_paid, 0)) as balance
                 FROM sales s
                 LEFT JOIN users u ON s.user_id = u.id
                 LEFT JOIN customers c ON s.customer_id = c.id
                 WHERE (s.payment_status = 'debt' OR s.payment_status = 'partial')
                 AND DATE(s.sale_date) >= ? AND DATE(s.sale_date) <= ?
                 ORDER BY s.sale_date DESC",
                [$startDate, $endDate]
            );
            
            // Also include cleared debts for the period (follow-up payments)
            $clearedDebts = $db->fetchAll(
                "SELECT s.*, u.full_name as cashier_name, c.name as customer_name,
                 0 as balance
                 FROM sales s
                 LEFT JOIN users u ON s.user_id = u.id
                 LEFT JOIN customers c ON s.customer_id = c.id
                 WHERE s.payment_status = 'paid' 
                 AND s.parent_sale_id IS NOT NULL
                 AND DATE(s.sale_date) >= ? AND DATE(s.sale_date) <= ?
                 ORDER BY s.sale_date DESC",
                [$startDate, $endDate]
            );
            
            $allDebts = array_merge($debts, $clearedDebts);
            
            $totalOutstanding = 0;
            $totalOriginal = 0;
            $totalPaid = 0;
            
            foreach ($debts as $d) {
                $totalOutstanding += floatval($d['balance'] ?? ($d['total'] - ($d['amount_paid'] ?? 0)));
                $totalOriginal += floatval($d['total'] ?? 0);
                $totalPaid += floatval($d['amount_paid'] ?? 0);
            }
            
            foreach ($clearedDebts as $d) {
                $totalOriginal += floatval($d['total'] ?? 0);
                $totalPaid += floatval($d['amount_paid'] ?? 0);
            }
            
            $summary = [
                'total_debts' => count($debts),
                'total_cleared' => count($clearedDebts),
                'total_outstanding' => $totalOutstanding,
                'total_original' => $totalOriginal,
                'total_paid' => $totalPaid
            ];
            
            $report = [
                'type' => 'Debts Report',
                'period' => "$startDate to $endDate",
                'summary' => $summary,
                'data' => $allDebts // Return flat array instead of nested object
            ];
            break;
            
        default:
            jsonResponse(['success' => false, 'message' => 'Invalid report type'], 400);
    }
    
    jsonResponse(['success' => true, 'report' => $report]);
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
