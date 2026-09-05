<?php
/**
 * Flowtive Central ERP - Categories API
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
                $category = $db->fetchOne("SELECT * FROM categories WHERE id = ?", [$_GET['id']]);
                if (!$category) {
                    jsonResponse(['success' => false, 'message' => 'Category not found'], 404);
                }
                jsonResponse(['success' => true, 'category' => $category, 'data' => $category]);
            } else {
                $categories = $db->fetchAll("SELECT * FROM categories ORDER BY name ASC");
                jsonResponse(['success' => true, 'categories' => $categories, 'data' => $categories, 'count' => count($categories)]);
            }
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['name']) || empty($input['name'])) {
                jsonResponse(['success' => false, 'message' => 'Category name is required'], 400);
            }
            
            $db->query(
                "INSERT INTO categories (name, icon, color, description) VALUES (?, ?, ?, ?)",
                [
                    $input['name'],
                    $input['icon'] ?? 'fa-box',
                    $input['color'] ?? '#667eea',
                    $input['description'] ?? ''
                ]
            );
            
            $categoryId = $db->lastInsertId();
            $category = $db->fetchOne("SELECT * FROM categories WHERE id = ?", [$categoryId]);
            
            jsonResponse(['success' => true, 'message' => 'Category created successfully', 'category' => $category, 'data' => $category], 201);
            break;
            
        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Category ID is required'], 400);
            }
            
            $updateFields = [];
            $params = [];
            
            foreach (['name', 'icon', 'color', 'description'] as $field) {
                if (isset($input[$field])) {
                    $updateFields[] = "$field = ?";
                    $params[] = $input[$field];
                }
            }
            
            if (empty($updateFields)) {
                jsonResponse(['success' => false, 'message' => 'No fields to update'], 400);
            }
            
            $params[] = $input['id'];
            $db->query("UPDATE categories SET " . implode(', ', $updateFields) . " WHERE id = ?", $params);
            
            $category = $db->fetchOne("SELECT * FROM categories WHERE id = ?", [$input['id']]);
            jsonResponse(['success' => true, 'message' => 'Category updated successfully', 'category' => $category, 'data' => $category]);
            break;
            
        case 'DELETE':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Category ID is required'], 400);
            }
            
            // Check if category has products
            $productCount = $db->fetchOne("SELECT COUNT(*) as count FROM products WHERE category_id = ?", [$input['id']]);
            if ($productCount['count'] > 0) {
                jsonResponse(['success' => false, 'message' => 'Cannot delete category with products'], 400);
            }
            
            $category = $db->fetchOne("SELECT * FROM categories WHERE id = ?", [$input['id']]);
            if (!$category) {
                jsonResponse(['success' => false, 'message' => 'Category not found'], 404);
            }
            
            // Soft delete: archive before removing
            archiveDeletedItem('category', $category['id'], $category['name'], $category, getPerformer($input), $input['reason'] ?? null);
            
            $db->query("DELETE FROM categories WHERE id = ?", [$input['id']]);
            jsonResponse(['success' => true, 'message' => 'Category deleted successfully']);
            break;
            
        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
