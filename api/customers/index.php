<?php
/**
 * Flowtive Central ERP - Customers API
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    exit(0);
}

$method = $_SERVER['REQUEST_METHOD'];

try {
    $db = getDB();
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                $customer = $db->fetchOne("SELECT * FROM customers WHERE id = ?", [$_GET['id']]);
                if (!$customer) {
                    jsonResponse(['success' => false, 'message' => 'Customer not found'], 404);
                }
                
                // Get customer's purchase history
                $purchases = $db->fetchAll(
                    "SELECT * FROM sales WHERE customer_id = ? ORDER BY sale_date DESC LIMIT 10",
                    [$_GET['id']]
                );
                $customer['recent_purchases'] = $purchases;
                
                // Get debt orders
                $debts = $db->fetchAll(
                    "SELECT * FROM debt_orders WHERE customer_id = ? AND status != 'paid' ORDER BY due_date ASC",
                    [$_GET['id']]
                );
                $customer['pending_debts'] = $debts;
                
                jsonResponse(['success' => true, 'customer' => $customer]);
            } else {
                $search = isset($_GET['search']) ? '%' . $_GET['search'] . '%' : null;
                
                if ($search) {
                    $customers = $db->fetchAll(
                        "SELECT * FROM customers WHERE name LIKE ? OR mobile LIKE ? OR email LIKE ? ORDER BY name ASC",
                        [$search, $search, $search]
                    );
                } else {
                    $customers = $db->fetchAll("SELECT * FROM customers ORDER BY name ASC");
                }
                
                jsonResponse(['success' => true, 'customers' => $customers, 'count' => count($customers)]);
            }
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['name']) || empty($input['name'])) {
                jsonResponse(['success' => false, 'message' => 'Customer name is required'], 400);
            }
            
            $db->query(
                "INSERT INTO customers (name, mobile, email, address) VALUES (?, ?, ?, ?)",
                [
                    $input['name'],
                    $input['mobile'] ?? '',
                    $input['email'] ?? '',
                    $input['address'] ?? ''
                ]
            );
            
            $customerId = $db->lastInsertId();
            $customer = $db->fetchOne("SELECT * FROM customers WHERE id = ?", [$customerId]);
            
            jsonResponse(['success' => true, 'message' => 'Customer created successfully', 'customer' => $customer], 201);
            break;
            
        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Customer ID is required'], 400);
            }
            
            $updateFields = [];
            $params = [];
            
            foreach (['name', 'mobile', 'email', 'address'] as $field) {
                if (isset($input[$field])) {
                    $updateFields[] = "$field = ?";
                    $params[] = $input[$field];
                }
            }
            
            if (empty($updateFields)) {
                jsonResponse(['success' => false, 'message' => 'No fields to update'], 400);
            }
            
            $params[] = $input['id'];
            $db->query("UPDATE customers SET " . implode(', ', $updateFields) . " WHERE id = ?", $params);
            
            $customer = $db->fetchOne("SELECT * FROM customers WHERE id = ?", [$input['id']]);
            jsonResponse(['success' => true, 'message' => 'Customer updated successfully', 'customer' => $customer]);
            break;
            
        case 'DELETE':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Customer ID is required'], 400);
            }
            
            // Check for pending debts
            $debts = $db->fetchOne("SELECT COUNT(*) as count FROM debt_orders WHERE customer_id = ? AND status != 'paid'", [$input['id']]);
            if ($debts['count'] > 0) {
                jsonResponse(['success' => false, 'message' => 'Cannot delete customer with pending debts'], 400);
            }
            
            $customer = $db->fetchOne("SELECT * FROM customers WHERE id = ?", [$input['id']]);
            if (!$customer) {
                jsonResponse(['success' => false, 'message' => 'Customer not found'], 404);
            }
            
            // Soft delete: archive before removing
            archiveDeletedItem('customer', $customer['id'], $customer['name'], $customer, getPerformer($input), $input['reason'] ?? null);
            
            $db->query("DELETE FROM customers WHERE id = ?", [$input['id']]);
            jsonResponse(['success' => true, 'message' => 'Customer deleted successfully']);
            break;
            
        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
