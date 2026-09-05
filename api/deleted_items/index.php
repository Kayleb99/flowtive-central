<?php
/**
 * Flowtive Central ERP - Deleted Items API
 * Read-only access to the soft-delete archive (deleted_items table).
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    exit(0);
}

$method = $_SERVER['REQUEST_METHOD'];

try {
    $db = getDB();

    switch ($method) {
        case 'GET':
            $where = "WHERE 1=1";
            $params = [];

            if (isset($_GET['entity_type']) && $_GET['entity_type'] !== 'all') {
                $where .= " AND entity_type = ?";
                $params[] = $_GET['entity_type'];
            }
            if (isset($_GET['search']) && $_GET['search'] !== '') {
                $where .= " AND (entity_label LIKE ? OR deleted_by_name LIKE ?)";
                $params[] = '%' . $_GET['search'] . '%';
                $params[] = '%' . $_GET['search'] . '%';
            }

            $items = $db->fetchAll(
                "SELECT id, entity_type, entity_id, entity_label, deleted_by_id, deleted_by_name,
                        deleted_by_role, reason, deleted_at, data
                 FROM deleted_items $where ORDER BY deleted_at DESC",
                $params
            );

            // Decode the JSON snapshot for convenience
            foreach ($items as &$it) {
                $it['snapshot'] = json_decode($it['data'], true);
                unset($it['data']);
            }
            unset($it);

            // Summary counts per entity type
            $counts = $db->fetchAll("SELECT entity_type, COUNT(*) as c FROM deleted_items GROUP BY entity_type");
            $summary = [];
            foreach ($counts as $c) {
                $summary[$c['entity_type']] = (int)$c['c'];
            }

            jsonResponse([
                'success' => true,
                'data' => $items,
                'items' => $items,
                'summary' => $summary,
                'count' => count($items)
            ]);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }

} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
