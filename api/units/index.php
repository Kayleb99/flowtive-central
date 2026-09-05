<?php
/**
 * Flowtive Central ERP - Units API
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
                $unit = $db->fetchOne("SELECT * FROM units WHERE id = ?", [$_GET['id']]);
                if (!$unit) {
                    jsonResponse(['success' => false, 'message' => 'Unit not found'], 404);
                }
                $unit['abbreviation'] = $unit['symbol'];
                jsonResponse(['success' => true, 'unit' => $unit, 'data' => $unit]);
            } else {
                $units = $db->fetchAll("SELECT * FROM units ORDER BY name ASC");
                foreach ($units as &$u) {
                    $u['abbreviation'] = $u['symbol'];
                }
                jsonResponse(['success' => true, 'units' => $units, 'data' => $units, 'count' => count($units)]);
            }
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['name']) || empty($input['name'])) {
                jsonResponse(['success' => false, 'message' => 'Unit name is required'], 400);
            }
            
            $db->query(
                "INSERT INTO units (name, symbol, type, description) VALUES (?, ?, ?, ?)",
                [
                    $input['name'],
                    $input['symbol'] ?? $input['abbreviation'] ?? '',
                    $input['type'] ?? 'count',
                    $input['description'] ?? ''
                ]
            );
            
            $unitId = $db->lastInsertId();
            $unit = $db->fetchOne("SELECT * FROM units WHERE id = ?", [$unitId]);
            $unit['abbreviation'] = $unit['symbol'];
            
            jsonResponse(['success' => true, 'message' => 'Unit created successfully', 'unit' => $unit, 'data' => $unit], 201);
            break;
            
        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Unit ID is required'], 400);
            }
            
            $updateFields = [];
            $params = [];
            
            foreach (['name', 'symbol', 'type', 'description'] as $field) {
                if (isset($input[$field])) {
                    $updateFields[] = "$field = ?";
                    $params[] = $input[$field];
                }
            }
            
            if (isset($input['abbreviation']) && !isset($input['symbol'])) {
                $updateFields[] = "symbol = ?";
                $params[] = $input['abbreviation'];
            }
            
            if (empty($updateFields)) {
                jsonResponse(['success' => false, 'message' => 'No fields to update'], 400);
            }
            
            $params[] = $input['id'];
            $db->query("UPDATE units SET " . implode(', ', $updateFields) . " WHERE id = ?", $params);
            
            $unit = $db->fetchOne("SELECT * FROM units WHERE id = ?", [$input['id']]);
            $unit['abbreviation'] = $unit['symbol'];
            jsonResponse(['success' => true, 'message' => 'Unit updated successfully', 'unit' => $unit, 'data' => $unit]);
            break;
            
        case 'DELETE':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Unit ID is required'], 400);
            }
            
            $productCount = $db->fetchOne("SELECT COUNT(*) as count FROM products WHERE unit_id = ?", [$input['id']]);
            if ($productCount['count'] > 0) {
                jsonResponse(['success' => false, 'message' => 'Cannot delete unit in use by products'], 400);
            }
            
            $unit = $db->fetchOne("SELECT * FROM units WHERE id = ?", [$input['id']]);
            if (!$unit) {
                jsonResponse(['success' => false, 'message' => 'Unit not found'], 404);
            }
            
            // Soft delete: archive before removing
            archiveDeletedItem('unit', $unit['id'], $unit['name'], $unit, getPerformer($input), $input['reason'] ?? null);
            
            $db->query("DELETE FROM units WHERE id = ?", [$input['id']]);
            jsonResponse(['success' => true, 'message' => 'Unit deleted successfully']);
            break;
            
        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
