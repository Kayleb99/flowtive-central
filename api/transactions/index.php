<?php
/**
 * Flowtive Central ERP - Transactions API
 * Handles transaction queries and reporting
 */

require_once '../config/database.php';

// Handle preflight requests
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
    
    $where = "WHERE 1=1";
    $params = [];
    
    // Filter by date range
    if (isset($_GET['date_from'])) {
        $where .= " AND DATE(s.sale_date) >= ?";
        $params[] = $_GET['date_from'];
    }
    
    if (isset($_GET['date_to'])) {
        $where .= " AND DATE(s.sale_date) <= ?";
        $params[] = $_GET['date_to'];
    }
    
    // Filter by user
    if (isset($_GET['user_id'])) {
        $where .= " AND s.user_id = ?";
        $params[] = $_GET['user_id'];
    }
    
    // Filter by payment status
    if (isset($_GET['payment_status'])) {
        $where .= " AND s.payment_status = ?";
        $params[] = $_GET['payment_status'];
    }
    
    // Filter by payment method
    if (isset($_GET['payment_method'])) {
        $where .= " AND s.payment_method = ?";
        $params[] = $_GET['payment_method'];
    }
    
    // Get transactions
    $transactions = $db->fetchAll(
        "SELECT s.*, u.full_name as cashier_name,
                CASE 
                    WHEN s.payment_status = 'paid' THEN 'Completed'
                    WHEN s.payment_status = 'partial' THEN 'Partial Payment'
                    WHEN s.payment_status = 'pending' THEN 'Pending'
                    ELSE 'Unknown'
                END as status_display
         FROM sales s
         LEFT JOIN users u ON s.user_id = u.id
         $where
         ORDER BY s.sale_date DESC
         LIMIT 500",
        $params
    );
    
    // Calculate totals
    $totals = $db->fetchOne(
        "SELECT 
            COUNT(*) as total_transactions,
            COALESCE(SUM(s.total), 0) as revenue,
            COALESCE(SUM(s.profit), 0) as profit,
            COALESCE(SUM(s.unexpected_profit), 0) as unexpected_profit,
            COALESCE(SUM(CASE WHEN s.payment_method = 'cash' THEN s.total ELSE 0 END), 0) as cash_total,
            COALESCE(SUM(CASE WHEN s.payment_method = 'mobile' THEN s.total ELSE 0 END), 0) as mobile_total,
            COALESCE(SUM(CASE WHEN s.payment_status IN ('partial', 'pending') THEN s.amount_due ELSE 0 END), 0) as pending_debt
         FROM sales s
         $where",
        $params
    );
    
    jsonResponse([
        'success' => true,
        'transactions' => $transactions,
        'sales' => $transactions, // Alias for compatibility
        'totals' => [
            'count' => intval($totals['total_transactions']),
            'revenue' => floatval($totals['revenue']),
            'profit' => floatval($totals['profit']),
            'unexpected_profit' => floatval($totals['unexpected_profit']),
            'cash' => floatval($totals['cash_total']),
            'mobile' => floatval($totals['mobile_total']),
            'debt' => floatval($totals['pending_debt'])
        ],
        'count' => count($transactions)
    ]);
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
