<?php
/**
 * Flowtive Central ERP - User Activity API
 * Returns all system activity: logins, sales, inventory changes, settings, etc.
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
    $db     = getDB();
    $userId = requireAuth($db);
    $user   = $db->fetchOne("SELECT role FROM users WHERE id = ?", [$userId]);

    // Only Admins / Super Admins see all users; others see their own activity only
    $isAdmin = in_array($user['role'] ?? '', ['Admin', 'Super Admin', 'Manager']);

    $limit  = min((int)($_GET['limit'] ?? 50), 200);
    $offset = (int)($_GET['offset'] ?? 0);
    $search = trim($_GET['search'] ?? '');
    $type   = trim($_GET['type'] ?? '');  // filter by action type
    $start  = $_GET['start'] ?? null;
    $end    = $_GET['end']   ?? null;

    $where  = [];
    $params = [];

    if (!$isAdmin) {
        $where[]  = 'ua.user_id = ?';
        $params[] = $userId;
    }
    if ($search) {
        $where[]  = '(ua.action LIKE ? OR ua.description LIKE ? OR u.full_name LIKE ? OR u.username LIKE ?)';
        $like = "%$search%";
        array_push($params, $like, $like, $like, $like);
    }
    if ($type) {
        $where[]  = 'ua.action = ?';
        $params[] = $type;
    }
    if ($start) {
        $where[]  = 'DATE(ua.created_at) >= ?';
        $params[] = $start;
    }
    if ($end) {
        $where[]  = 'DATE(ua.created_at) <= ?';
        $params[] = $end;
    }

    $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

    $rows = $db->fetchAll(
        "SELECT ua.id, ua.user_id, ua.action, ua.description, ua.ip_address,
                ua.created_at,
                u.full_name, u.username, u.role AS user_role
         FROM user_activity ua
         LEFT JOIN users u ON ua.user_id = u.id
         $whereClause
         ORDER BY ua.created_at DESC
         LIMIT ? OFFSET ?",
        array_merge($params, [$limit, $offset])
    );

    $countRow = $db->fetchOne(
        "SELECT COUNT(*) as total FROM user_activity ua LEFT JOIN users u ON ua.user_id = u.id $whereClause",
        $params
    );

    // Also pull distinct action types for the filter dropdown
    $actionTypes = $db->fetchAll(
        "SELECT DISTINCT action FROM user_activity ORDER BY action ASC",
        []
    );

    jsonResponse([
        'success'      => true,
        'activity'     => $rows,
        'total'        => (int)($countRow['total'] ?? 0),
        'limit'        => $limit,
        'offset'       => $offset,
        'action_types' => array_column($actionTypes, 'action'),
    ]);

} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
