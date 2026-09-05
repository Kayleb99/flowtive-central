<?php
/**
 * Flowtive Central ERP - Stock Movements API
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }

$method = $_SERVER['REQUEST_METHOD'];

try {
    $db = getDB();
    $authUser = getAuthenticatedUser();
    
    switch ($method) {
        case 'GET':
            $where = "WHERE 1=1";
            $params = [];
            
            if (isset($_GET['product_id'])) {
                $where .= " AND sm.product_id = ?";
                $params[] = $_GET['product_id'];
            }
            
            if (isset($_GET['type'])) {
                $where .= " AND sm.type = ?";
                $params[] = $_GET['type'];
            }
            
            if (isset($_GET['date_from'])) {
                $where .= " AND DATE(sm.movement_date) >= ?";
                $params[] = $_GET['date_from'];
            }
            
            if (isset($_GET['date_to'])) {
                $where .= " AND DATE(sm.movement_date) <= ?";
                $params[] = $_GET['date_to'];
            }
            
            $movements = $db->fetchAll(
                "SELECT sm.*, u.full_name as user_name 
                 FROM stock_movements sm 
                 LEFT JOIN users u ON sm.user_id = u.id 
                 $where 
                 ORDER BY sm.movement_date DESC 
                 LIMIT 100",
                $params
            );
            
            jsonResponse(['success' => true, 'movements' => $movements, 'count' => count($movements)]);
            break;
            
        case 'POST':
            // Manual stock adjustment
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['product_id']) || !isset($input['quantity']) || !isset($input['type'])) {
                jsonResponse(['success' => false, 'message' => 'Product ID, quantity, and type are required'], 400);
            }
            
            $db->beginTransaction();
            
            try {
                $product = $db->fetchOne("SELECT * FROM products WHERE id = ?", [$input['product_id']]);
                
                if (!$product) {
                    jsonResponse(['success' => false, 'message' => 'Product not found'], 404);
                }
                
                $quantity = floatval($input['quantity']); // floatval supports fractional stock (e.g. 30.5 metres)
                $previousStock = floatval($product['current_stock']);
                
                switch ($input['type']) {
                    case 'purchase':
                    case 'return':
                        $newStock = $previousStock + abs($quantity);
                        $movementQty = abs($quantity);
                        break;
                    case 'sale':
                    case 'damage':
                        $newStock = $previousStock - abs($quantity);
                        $movementQty = -abs($quantity);
                        break;
                    case 'adjustment':
                        $newStock = $quantity; // Direct set
                        $movementQty = $quantity - $previousStock;
                        break;
                    default:
                        jsonResponse(['success' => false, 'message' => 'Invalid movement type'], 400);
                }
                
                if ($newStock < 0) {
                    jsonResponse(['success' => false, 'message' => 'Insufficient stock'], 400);
                }
                
                // Update product stock
                $db->query("UPDATE products SET current_stock = ? WHERE id = ?", [$newStock, $input['product_id']]);
                
                // Record movement
                $db->query(
                    "INSERT INTO stock_movements (product_id, product_name, type, quantity, previous_stock, 
                     new_stock, user_id, reason) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    [
                        $input['product_id'],
                        $product['name'],
                        $input['type'],
                        $movementQty,
                        $previousStock,
                        $newStock,
                        $input['user_id'] ?? null,
                        $input['reason'] ?? 'Manual adjustment'
                    ]
                );
                
                $db->commit();
                
                jsonResponse([
                    'success' => true, 
                    'message' => 'Stock updated successfully',
                    'previous_stock' => $previousStock,
                    'new_stock' => $newStock
                ]);
                
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
?>
