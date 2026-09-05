<?php
/**
 * Flowtive Central ERP - Products API
 * Handles CRUD operations for products
 */

ini_set('display_errors', 0);
error_reporting(0);
ini_set('memory_limit', '256M');
ini_set('post_max_size', '50M');
ini_set('upload_max_filesize', '50M');

require_once '../config/database.php';

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }

$method = $_SERVER['REQUEST_METHOD'];

try {
    $db = getDB();
    $authUser = getAuthenticatedUser();
    
    switch ($method) {
        case 'GET':
            // Get all products or single product
            if (isset($_GET['id'])) {
                $product = $db->fetchOne(
                    "SELECT p.*, p.current_stock as stock_quantity, c.name as category_name, u.name as unit_name 
                     FROM products p 
                     LEFT JOIN categories c ON p.category_id = c.id 
                     LEFT JOIN units u ON p.unit_id = u.id 
                     WHERE p.id = ?",
                    [$_GET['id']]
                );
                
                if (!$product) {
                    jsonResponse(['success' => false, 'message' => 'Product not found'], 404);
                }
                
                $product['stock_quantity'] = $product['current_stock'];
                $product['low_stock_threshold'] = $product['minimum_stock'];
                $product['min_price'] = $product['minimum_price'];
                $product['image_url'] = $product['image'] ?: $product['image_url'];
                $product['units_of_sale'] = $db->fetchAll(
                    "SELECT * FROM product_units WHERE product_id = ? ORDER BY sort_order ASC, id ASC",
                    [$_GET['id']]
                );
                
                jsonResponse(['success' => true, 'product' => $product, 'data' => $product]);
            } else {
                // Build query with filters
                $where = "WHERE 1=1";
                $params = [];
                
                if (isset($_GET['category_id']) && $_GET['category_id'] !== 'all') {
                    $where .= " AND p.category_id = ?";
                    $params[] = $_GET['category_id'];
                }
                
                if (isset($_GET['status'])) {
                    $where .= " AND p.status = ?";
                    $params[] = $_GET['status'];
                }
                
                if (isset($_GET['search']) && !empty($_GET['search'])) {
                    $search = '%' . $_GET['search'] . '%';
                    $where .= " AND (p.name LIKE ? OR p.sku LIKE ? OR p.barcode LIKE ?)";
                    $params[] = $search;
                    $params[] = $search;
                    $params[] = $search;
                }
                
                if (isset($_GET['low_stock']) && $_GET['low_stock'] === 'true') {
                    $where .= " AND p.current_stock <= p.minimum_stock";
                }
                
                $products = $db->fetchAll(
                    "SELECT p.*, p.current_stock as stock_quantity, p.minimum_stock as low_stock_threshold,
                            c.name as category_name, u.name as unit_name 
                     FROM products p 
                     LEFT JOIN categories c ON p.category_id = c.id 
                     LEFT JOIN units u ON p.unit_id = u.id 
                     $where 
                     ORDER BY p.name ASC",
                    $params
                );
                
                // Fetch all units-of-sale once and group by product (avoids N+1)
                $allUnits = $db->fetchAll("SELECT * FROM product_units ORDER BY sort_order ASC, id ASC");
                $unitsByProduct = [];
                foreach ($allUnits as $u) {
                    $unitsByProduct[$u['product_id']][] = $u;
                }
                
                foreach ($products as &$p) {
                    $p['stock_quantity'] = $p['current_stock'];
                    $p['low_stock_threshold'] = $p['minimum_stock'];
                    $p['stock'] = $p['current_stock'];
                    $p['min_price'] = $p['minimum_price'];
                    $p['image_url'] = $p['image'] ?: $p['image_url'];
                    $p['units_of_sale'] = $unitsByProduct[$p['id']] ?? [];
                }
                unset($p);
                
                jsonResponse([
                    'success' => true, 
                    'products' => $products, 
                    'data' => $products,
                    'count' => count($products)
                ]);
            }
            break;
            
        case 'POST':
            // Create new product
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['name']) || empty($input['name'])) {
                jsonResponse(['success' => false, 'message' => 'Product name is required'], 400);
            }
            
            // Generate SKU if not provided
            if (!isset($input['sku']) || empty($input['sku'])) {
                $input['sku'] = 'PRD-' . strtoupper(substr(md5(time()), 0, 8));
            }
            
            $currentStock = $input['current_stock'] ?? $input['stock_quantity'] ?? 0;
            $minimumStock = $input['minimum_stock'] ?? $input['low_stock_threshold'] ?? 10;
            $minimumPrice = $input['minimum_price'] ?? $input['min_price'] ?? 0;
            
            $imageData = $input['image'] ?? $input['image_url'] ?? null;
            
            $db->query(
                "INSERT INTO products (name, sku, barcode, category_id, unit_id, cost_price, selling_price, 
                 minimum_price, current_stock, minimum_stock, maximum_stock, image, image_url, description_color, 
                 description_size, description_type, brand, supplier, storage_location, status) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active')",
                [
                    $input['name'],
                    $input['sku'],
                    $input['barcode'] ?? null,
                    $input['category_id'] ?? null,
                    $input['unit_id'] ?? null,
                    $input['cost_price'] ?? 0,
                    $input['selling_price'] ?? 0,
                    $minimumPrice,
                    $currentStock,
                    $minimumStock,
                    $input['maximum_stock'] ?? 0,
                    $imageData,
                    $imageData,
                    $input['description_color'] ?? $input['color'] ?? null,
                    $input['description_size'] ?? $input['measurement'] ?? null,
                    $input['description_type'] ?? null,
                    $input['brand'] ?? null,
                    $input['supplier'] ?? null,
                    $input['storage_location'] ?? null
                ]
            );
            
            $productId = $db->lastInsertId();
            
            // Persist multi-unit-of-sale configuration (if provided)
            saveProductUnits($db, $productId, $input);
            
            // Update category product count
            if (isset($input['category_id'])) {
                $db->query(
                    "UPDATE categories SET product_count = (SELECT COUNT(*) FROM products WHERE category_id = ?) WHERE id = ?",
                    [$input['category_id'], $input['category_id']]
                );
            }
            
            // Update unit products using count
            if (isset($input['unit_id'])) {
                $db->query(
                    "UPDATE units SET products_using = (SELECT COUNT(*) FROM products WHERE unit_id = ?) WHERE id = ?",
                    [$input['unit_id'], $input['unit_id']]
                );
            }
            
            $product = $db->fetchOne("SELECT *, current_stock as stock_quantity, minimum_stock as low_stock_threshold FROM products WHERE id = ?", [$productId]);
            $product['min_price'] = $product['minimum_price'];
            $product['image_url'] = $product['image'];
            
            jsonResponse(['success' => true, 'message' => 'Product created successfully', 'product' => $product, 'data' => $product], 201);
            break;
            
        case 'PUT':
            // Update product
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Product ID is required'], 400);
            }
            
            // Get current product for stock movement tracking
            $currentProduct = $db->fetchOne("SELECT * FROM products WHERE id = ?", [$input['id']]);
            
            if (!$currentProduct) {
                jsonResponse(['success' => false, 'message' => 'Product not found'], 404);
            }
            
            $updateFields = [];
            $params = [];
            
            $allowedFields = ['name', 'sku', 'barcode', 'category_id', 'unit_id', 'cost_price', 
                           'selling_price', 'minimum_price', 'current_stock', 'minimum_stock', 
                           'maximum_stock', 'image', 'description_color', 'description_size', 
                           'description_type', 'brand', 'supplier', 'storage_location', 'status'];
            
            $fieldMapping = [
                'stock_quantity'    => 'current_stock',
                'low_stock_threshold' => 'minimum_stock',
                'min_price'         => 'minimum_price',
                'image_url'         => 'image',
                'color'             => 'description_color',
                'measurement'       => 'description_size',
            ];
            
            foreach ($allowedFields as $field) {
                if (isset($input[$field])) {
                    $updateFields[] = "$field = ?";
                    $params[] = $input[$field];
                    
                    if ($field === 'image') {
                        $updateFields[] = "image_url = ?";
                        $params[] = $input[$field];
                    }
                }
            }
            
            // Check for alias fields
            foreach ($fieldMapping as $alias => $realField) {
                if (isset($input[$alias]) && !isset($input[$realField])) {
                    $updateFields[] = "$realField = ?";
                    $params[] = $input[$alias];
                    
                    if ($realField === 'image') {
                        $updateFields[] = "image_url = ?";
                        $params[] = $input[$alias];
                    }
                }
            }
            
            if (empty($updateFields)) {
                jsonResponse(['success' => false, 'message' => 'No fields to update'], 400);
            }
            
            $params[] = $input['id'];
            
            $db->query(
                "UPDATE products SET " . implode(', ', $updateFields) . " WHERE id = ?",
                $params
            );
            
            // Persist multi-unit-of-sale configuration (if provided)
            saveProductUnits($db, $input['id'], $input);
            
            // Track stock movement if stock changed
            $newStock = $input['current_stock'] ?? $input['stock_quantity'] ?? null;
            if ($newStock !== null && $newStock != $currentProduct['current_stock']) {
                $db->query(
                    "INSERT INTO stock_movements (product_id, product_name, type, quantity, previous_stock, new_stock, reason) 
                     VALUES (?, ?, 'adjustment', ?, ?, ?, ?)",
                    [
                        $input['id'],
                        $currentProduct['name'],
                        $newStock - $currentProduct['current_stock'],
                        $currentProduct['current_stock'],
                        $newStock,
                        $input['reason'] ?? 'Manual stock adjustment'
                    ]
                );
            }
            
            $product = $db->fetchOne("SELECT *, current_stock as stock_quantity, minimum_stock as low_stock_threshold FROM products WHERE id = ?", [$input['id']]);
            $product['min_price'] = $product['minimum_price'];
            $product['image_url'] = $product['image'];
            
            jsonResponse(['success' => true, 'message' => 'Product updated successfully', 'product' => $product, 'data' => $product]);
            break;
            
        case 'DELETE':
            // Delete product
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Product ID is required'], 400);
            }
            
            $product = $db->fetchOne("SELECT * FROM products WHERE id = ?", [$input['id']]);
            
            if (!$product) {
                jsonResponse(['success' => false, 'message' => 'Product not found'], 404);
            }
            
            // Soft delete: archive full snapshot (incl. units) before removing
            $product['units_of_sale'] = $db->fetchAll("SELECT * FROM product_units WHERE product_id = ?", [$input['id']]);
            archiveDeletedItem('product', $product['id'], $product['name'], $product, getPerformer($input), $input['reason'] ?? null);
            
            $db->query("DELETE FROM products WHERE id = ?", [$input['id']]);
            
            // Update category count
            if ($product['category_id']) {
                $db->query(
                    "UPDATE categories SET product_count = (SELECT COUNT(*) FROM products WHERE category_id = ?) WHERE id = ?",
                    [$product['category_id'], $product['category_id']]
                );
            }
            
            jsonResponse(['success' => true, 'message' => 'Product deleted successfully']);
            break;
            
        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}

/**
 * Persist multi-unit-of-sale configuration for a product.
 * Updates product-level package metadata and rebuilds the product_units rows.
 * Expects $input['units_of_sale'] = [
 *   { unit_label, conversion_to_base, selling_price, minimum_price,
 *     is_base, is_default, allow_custom_length }
 * ]
 */
function saveProductUnits($db, $productId, $input) {
    if (!array_key_exists('units_of_sale', $input)) {
        return; // nothing to change
    }

    $units = is_array($input['units_of_sale']) ? $input['units_of_sale'] : [];
    $hasMulti = count($units) > 1 ? 1 : (!empty($input['has_multi_unit']) ? 1 : 0);

    $db->query(
        "UPDATE products SET has_multi_unit = ?, base_unit_label = ?, package_unit_label = ?, package_size = ? WHERE id = ?",
        [
            $hasMulti,
            $input['base_unit_label'] ?? null,
            $input['package_unit_label'] ?? null,
            isset($input['package_size']) && $input['package_size'] !== '' ? $input['package_size'] : null,
            $productId
        ]
    );

    // Rebuild unit rows
    $db->query("DELETE FROM product_units WHERE product_id = ?", [$productId]);

    $sort = 0;
    foreach ($units as $u) {
        if (empty($u['unit_label'])) continue;
        $db->query(
            "INSERT INTO product_units (product_id, unit_label, conversion_to_base, selling_price, minimum_price, is_base, is_default, allow_custom_length, sort_order)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
            [
                $productId,
                $u['unit_label'],
                $u['conversion_to_base'] ?? 1,
                $u['selling_price'] ?? 0,
                $u['minimum_price'] ?? 0,
                !empty($u['is_base']) ? 1 : 0,
                !empty($u['is_default']) ? 1 : 0,
                !empty($u['allow_custom_length']) ? 1 : 0,
                $sort++
            ]
        );
    }
}
?>
