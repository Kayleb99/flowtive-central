<?php
/**
 * Flowtive Central ERP - Sales API
 * Enhanced with receipt storage, debt tracking, and unexpected profit calculation
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }

$method = $_SERVER['REQUEST_METHOD'];

try {
    $db = getDB();
    $authUser = getAuthenticatedUser();
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Get single sale with items
                $sale = $db->fetchOne(
                    "SELECT s.*, u.full_name as cashier_name, c.name as cust_name 
                     FROM sales s 
                     LEFT JOIN users u ON s.user_id = u.id 
                     LEFT JOIN customers c ON s.customer_id = c.id 
                     WHERE s.id = ?",
                    [$_GET['id']]
                );
                
                if (!$sale) {
                    jsonResponse(['success' => false, 'message' => 'Sale not found'], 404);
                }
                
                $items = $db->fetchAll(
                    "SELECT si.*, p.minimum_price 
                     FROM sale_items si 
                     LEFT JOIN products p ON si.product_id = p.id 
                     WHERE si.sale_id = ?",
                    [$_GET['id']]
                );
                
                $sale['items'] = $items;
                
                // Get linked receipts for debt payments
                if ($sale['payment_status'] !== 'paid') {
                    $debtPayments = $db->fetchAll(
                        "SELECT dp.* FROM debt_payments dp 
                         INNER JOIN debt_orders do ON dp.debt_id = do.id 
                         WHERE do.sale_id = ? 
                         ORDER BY dp.payment_date DESC",
                        [$_GET['id']]
                    );
                    $sale['debt_payments'] = $debtPayments;
                }
                
                jsonResponse(['success' => true, 'sale' => $sale]);
            } else {
                // Get all sales with filters
                $where = "WHERE 1=1";
                $params = [];
                
                if (isset($_GET['date_from'])) {
                    $where .= " AND DATE(s.sale_date) >= ?";
                    $params[] = $_GET['date_from'];
                }
                
                if (isset($_GET['date_to'])) {
                    $where .= " AND DATE(s.sale_date) <= ?";
                    $params[] = $_GET['date_to'];
                }
                
                if (isset($_GET['payment_status'])) {
                    $where .= " AND s.payment_status = ?";
                    $params[] = $_GET['payment_status'];
                }
                
                if (isset($_GET['user_id'])) {
                    $where .= " AND s.user_id = ?";
                    $params[] = $_GET['user_id'];
                }
                
                // Today's sales by default
                if (!isset($_GET['date_from']) && !isset($_GET['date_to']) && !isset($_GET['all'])) {
                    $where .= " AND DATE(s.sale_date) = CURDATE()";
                }
                
                $sales = $db->fetchAll(
                    "SELECT s.*, u.full_name as cashier_name, c.name as cust_name,
                     (SELECT COUNT(*) FROM sale_items WHERE sale_id = s.id) as item_count
                     FROM sales s 
                     LEFT JOIN users u ON s.user_id = u.id 
                     LEFT JOIN customers c ON s.customer_id = c.id 
                     $where 
                     ORDER BY s.sale_date DESC",
                    $params
                );
                
                // Calculate totals
                $totals = $db->fetchOne(
                    "SELECT COUNT(*) as count, COALESCE(SUM(total), 0) as revenue, 
                     COALESCE(SUM(profit), 0) as profit,
                     COALESCE(SUM(unexpected_profit), 0) as unexpected_profit
                     FROM sales s $where",
                    $params
                );
                
                jsonResponse([
                    'success' => true, 
                    'sales' => $sales, 
                    'count' => count($sales),
                    'totals' => $totals
                ]);
            }
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (isset($input['action']) && $input['action'] === 'complete_debt') {
                return handleDebtPayment($db, $input);
            }
            
            // Create new sale
            if (!isset($input['items']) || empty($input['items'])) {
                jsonResponse(['success' => false, 'message' => 'Sale items are required'], 400);
            }
            
            if (!isset($input['user_id'])) {
                jsonResponse(['success' => false, 'message' => 'User ID is required'], 400);
            }
            
            $db->beginTransaction();
            
            try {
                $orderNumber = generateOrderNumber();
                
                // Calculate totals including unexpected profit
                $subtotal = 0;
                $totalProfit = 0;
                $unexpectedProfit = 0;
                
                foreach ($input['items'] as $item) {
                    $itemTotal = $item['quantity'] * $item['unit_price'];
                    $costPrice = $item['cost_price'] ?? 0;
                    $minPrice = $item['minimum_price'] ?? $item['unit_price'];
                    
                    // Normal profit = selling price - cost price
                    $itemProfit = ($item['unit_price'] - $costPrice) * $item['quantity'];
                    
                    $itemUnexpectedProfit = ($item['unit_price'] - $minPrice) * $item['quantity'];
                    
                    $subtotal += $itemTotal;
                    $totalProfit += $itemProfit;
                    $unexpectedProfit += $itemUnexpectedProfit;
                }
                
                $tax = $input['tax'] ?? 0;
                $discount = $input['discount'] ?? 0;
                $total = $subtotal + $tax - $discount;
                $amountPaid = $input['amount_paid'] ?? $total;
                $amountDue = $total - $amountPaid;
                
                // Determine payment status
                $paymentStatus = 'paid';
                $paymentMethod = $input['payment_method'] ?? 'cash';
                
                if ($amountDue > 0) {
                    $paymentStatus = $amountPaid > 0 ? 'partial' : 'pending';
                    $paymentMethod = 'debt';
                }
                
                // Save split payment amounts when method is 'split'
                $splitCash   = ($paymentMethod === 'split') ? ($input['split_cash']   ?? null) : null;
                $splitMobile = ($paymentMethod === 'split') ? ($input['split_mobile'] ?? null) : null;

                // Insert sale with cashier tagging and customer info
                $db->query(
                    "INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, 
                     subtotal, tax, discount, total, profit, unexpected_profit, payment_method, mpesa_code,
                     split_cash, split_mobile,
                     payment_status, amount_paid, amount_due, notes, receipt_html) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    [
                        $orderNumber,
                        $input['customer_id'] ?? null,
                        $input['customer_name'] ?? null,
                        $input['customer_mobile'] ?? null,
                        $input['user_id'],
                        $subtotal,
                        $tax,
                        $discount,
                        $total,
                        $totalProfit,
                        $unexpectedProfit,
                        $paymentMethod,
                        $input['mpesa_code'] ?? null,
                        $splitCash,
                        $splitMobile,
                        $paymentStatus,
                        $amountPaid,
                        $amountDue,
                        $input['notes'] ?? null,
                        $input['receipt_html'] ?? null
                    ]
                );
                
                $saleId = $db->lastInsertId();
                
                // Insert sale items and update stock
                foreach ($input['items'] as $item) {
                    $itemTotal = $item['quantity'] * $item['unit_price'];
                    $itemProfit = ($item['unit_price'] - ($item['cost_price'] ?? 0)) * $item['quantity'];
                    
                    // Base quantity is the amount deducted from stock (in base units).
                    // For multi-unit items the frontend sends base_quantity; otherwise
                    // it equals the sold quantity.
                    $baseQty = isset($item['base_quantity']) && $item['base_quantity'] !== null && $item['base_quantity'] !== ''
                        ? $item['base_quantity'] : $item['quantity'];
                    $unitLabel = $item['unit_label'] ?? null;
                    
                    $db->query(
                        "INSERT INTO sale_items (sale_id, product_id, product_name, quantity, unit_label, base_quantity, unit_price, 
                         cost_price, discount, total, profit) 
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        [
                            $saleId,
                            $item['product_id'],
                            $item['product_name'],
                            $item['quantity'],
                            $unitLabel,
                            $baseQty,
                            $item['unit_price'],
                            $item['cost_price'] ?? 0,
                            $item['discount'] ?? 0,
                            $itemTotal,
                            $itemProfit
                        ]
                    );
                    
                    // Update product stock (deduct base quantity)
                    $product = $db->fetchOne("SELECT * FROM products WHERE id = ?", [$item['product_id']]);
                    if ($product) {
                        $newStock = $product['current_stock'] - $baseQty;
                        $db->query(
                            "UPDATE products SET current_stock = ?, total_sold = total_sold + ? WHERE id = ?",
                            [$newStock, $baseQty, $item['product_id']]
                        );
                        
                        $db->query(
                            "INSERT INTO stock_movements (product_id, product_name, type, quantity, 
                             previous_stock, new_stock, user_id, reference_id, reference_type, reason) 
                             VALUES (?, ?, 'sale', ?, ?, ?, ?, ?, 'sale', ?)",
                            [
                                $item['product_id'],
                                $item['product_name'],
                                -$baseQty,
                                $product['current_stock'],
                                $newStock,
                                $input['user_id'],
                                $saleId,
                                "Sale - Order #$orderNumber" . ($unitLabel ? " ({$item['quantity']} {$unitLabel})" : "")
                            ]
                        );
                    }
                }
                
                if ($amountDue > 0 && ($input['customer_name'] || $input['customer_id'])) {
                    $dueDate = date('Y-m-d', strtotime('+30 days'));
                    
                    // Create or find customer
                    $customerId = $input['customer_id'];
                    if (!$customerId && $input['customer_name']) {
                        // Check if customer exists by mobile
                        if ($input['customer_mobile']) {
                            $existing = $db->fetchOne(
                                "SELECT id FROM customers WHERE mobile = ?",
                                [$input['customer_mobile']]
                            );
                            if ($existing) {
                                $customerId = $existing['id'];
                            }
                        }
                        
                        if (!$customerId) {
                            $db->query(
                                "INSERT INTO customers (name, mobile) VALUES (?, ?)",
                                [$input['customer_name'], $input['customer_mobile'] ?? null]
                            );
                            $customerId = $db->lastInsertId();
                        }
                        
                        // Update sale with customer ID
                        $db->query(
                            "UPDATE sales SET customer_id = ? WHERE id = ?",
                            [$customerId, $saleId]
                        );
                    }
                    
                    $db->query(
                        "INSERT INTO debt_orders (sale_id, customer_id, amount_due, amount_paid, due_date, status) 
                         VALUES (?, ?, ?, ?, ?, ?)",
                        [$saleId, $customerId, $amountDue, 0, $dueDate, $paymentStatus]
                    );
                    
                    // Update customer debt
                    $db->query(
                        "UPDATE customers SET total_debt = total_debt + ? WHERE id = ?",
                        [$amountDue, $customerId]
                    );
                }
                
                // Update customer total purchases
                if (isset($input['customer_id']) && $input['customer_id']) {
                    $db->query(
                        "UPDATE customers SET total_purchases = total_purchases + ? WHERE id = ?",
                        [$total, $input['customer_id']]
                    );
                }
                
                $db->commit();
                
                $sale = $db->fetchOne("SELECT * FROM sales WHERE id = ?", [$saleId]);
                $sale['items'] = $db->fetchAll("SELECT * FROM sale_items WHERE sale_id = ?", [$saleId]);
                
                // Get cashier name
                $cashier = $db->fetchOne("SELECT full_name FROM users WHERE id = ?", [$input['user_id']]);
                $sale['cashier_name'] = $cashier ? $cashier['full_name'] : 'Unknown';
                
                jsonResponse([
                    'success' => true, 
                    'message' => 'Sale completed successfully', 
                    'sale' => $sale
                ], 201);
                
            } catch (Exception $e) {
                $db->rollback();
                throw $e;
            }
            break;
            
        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (isset($input['id']) && isset($input['receipt_html'])) {
                $db->query(
                    "UPDATE sales SET receipt_html = ? WHERE id = ?",
                    [$input['receipt_html'], $input['id']]
                );
                jsonResponse(['success' => true, 'message' => 'Receipt saved']);
            }
            
            jsonResponse(['success' => false, 'message' => 'Invalid request'], 400);
            break;
            
        case 'DELETE':
            if (!isset($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'Sale ID required'], 400);
            }
            
            $saleId = $_GET['id'];
            $sale = $db->fetchOne("SELECT * FROM sales WHERE id = ?", [$saleId]);
            if (!$sale) {
                jsonResponse(['success' => false, 'message' => 'Sale not found'], 404);
            }
            
            $db->beginTransaction();
            try {
                // Restore stock for each sold item
                $items = $db->fetchAll("SELECT * FROM sale_items WHERE sale_id = ?", [$saleId]);
                
                // Soft delete: archive full sale snapshot (with items) before removing
                $saleSnapshot = $sale;
                $saleSnapshot['items'] = $items;
                $performer = [
                    'id'   => $_GET['performed_by_id'] ?? null,
                    'name' => $_GET['performed_by_name'] ?? 'Unknown',
                    'role' => $_GET['performed_by_role'] ?? 'Unknown',
                ];
                archiveDeletedItem('sale', $sale['id'], $sale['order_number'], $saleSnapshot, $performer, $_GET['reason'] ?? null);
                
                foreach ($items as $it) {
                    if (!empty($it['product_id'])) {
                        // Restore the actual base quantity that was deducted when possible
                        $restoreQty = isset($it['base_quantity']) && $it['base_quantity'] !== null
                            ? $it['base_quantity'] : $it['quantity'];
                        $db->query(
                            "UPDATE products SET current_stock = current_stock + ?, 
                             total_sold = GREATEST(total_sold - ?, 0) WHERE id = ?",
                            [$restoreQty, $restoreQty, $it['product_id']]
                        );
                    }
                }
                
                // Reverse any associated debts
                $debtOrders = $db->fetchAll("SELECT * FROM debt_orders WHERE sale_id = ?", [$saleId]);
                foreach ($debtOrders as $d) {
                    $db->query("DELETE FROM debt_payments WHERE debt_id = ?", [$d['id']]);
                    $outstanding = floatval($d['amount_due']) - floatval($d['amount_paid']);
                    if (!empty($d['customer_id']) && $outstanding > 0) {
                        $db->query(
                            "UPDATE customers SET total_debt = GREATEST(total_debt - ?, 0) WHERE id = ?",
                            [$outstanding, $d['customer_id']]
                        );
                    }
                }
                $db->query("DELETE FROM debt_orders WHERE sale_id = ?", [$saleId]);
                
                // Clean up movements and items, then the sale itself
                $db->query("DELETE FROM stock_movements WHERE reference_id = ? AND reference_type = 'sale'", [$saleId]);
                $db->query("DELETE FROM sale_items WHERE sale_id = ?", [$saleId]);
                $db->query("DELETE FROM sales WHERE id = ?", [$saleId]);
                
                $db->commit();
                jsonResponse(['success' => true, 'message' => 'Order deleted successfully']);
            } catch (Exception $e) {
                $db->rollback();
                throw $e;
            }
            break;
            
        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}

function handleDebtPayment($db, $input) {
    if (!isset($input['sale_id']) || !isset($input['amount'])) {
        jsonResponse(['success' => false, 'message' => 'Sale ID and amount required'], 400);
    }
    
    $db->beginTransaction();
    
    try {
        $sale = $db->fetchOne("SELECT * FROM sales WHERE id = ?", [$input['sale_id']]);
        if (!$sale) {
            jsonResponse(['success' => false, 'message' => 'Sale not found'], 404);
        }
        
        $debtOrder = $db->fetchOne(
            "SELECT * FROM debt_orders WHERE sale_id = ?",
            [$input['sale_id']]
        );
        
        if (!$debtOrder) {
            jsonResponse(['success' => false, 'message' => 'No debt found for this sale'], 404);
        }
        
        $paymentAmount = floatval($input['amount']);
        $newAmountPaid = floatval($sale['amount_paid']) + $paymentAmount;
        $newAmountDue = floatval($sale['total']) - $newAmountPaid;
        
        $newStatus = $newAmountDue <= 0 ? 'paid' : 'partial';
        
        // Update sale
        $db->query(
            "UPDATE sales SET amount_paid = ?, amount_due = ?, payment_status = ? WHERE id = ?",
            [$newAmountPaid, max(0, $newAmountDue), $newStatus, $input['sale_id']]
        );
        
        // Update debt order
        $db->query(
            "UPDATE debt_orders SET amount_paid = amount_paid + ?, status = ? WHERE sale_id = ?",
            [$paymentAmount, $newStatus, $input['sale_id']]
        );
        
        // Record debt payment
        $db->query(
            "INSERT INTO debt_payments (debt_id, amount, payment_method, user_id, notes) 
             VALUES (?, ?, ?, ?, ?)",
            [
                $debtOrder['id'],
                $paymentAmount,
                $input['payment_method'] ?? 'cash',
                $input['user_id'] ?? null,
                $input['notes'] ?? 'Debt payment'
            ]
        );
        
        // Update customer debt
        if ($sale['customer_id']) {
            $db->query(
                "UPDATE customers SET total_debt = total_debt - ? WHERE id = ?",
                [$paymentAmount, $sale['customer_id']]
            );
        }
        
        $db->commit();
        
        $updatedSale = $db->fetchOne("SELECT * FROM sales WHERE id = ?", [$input['sale_id']]);
        
        jsonResponse([
            'success' => true,
            'message' => $newStatus === 'paid' ? 'Debt fully paid!' : 'Payment recorded',
            'sale' => $updatedSale,
            'new_status' => $newStatus
        ]);
        
    } catch (Exception $e) {
        $db->rollback();
        throw $e;
    }
}
?>
