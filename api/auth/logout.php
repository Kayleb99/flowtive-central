<?php
/**
 * Flowtive Central ERP - Logout API
 * v3.1: clears HttpOnly cookie + invalidates DB session
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

// Accept token from header or cookie
$token = null;
$headers = getallheaders();
$authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
if ($authHeader) {
    $token = str_replace('Bearer ', '', $authHeader);
}
if (!$token && isset($_COOKIE['flowtive_session'])) {
    $token = $_COOKIE['flowtive_session'];
}

// Clear the HttpOnly cookie regardless
$secure = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
setcookie('flowtive_session', '', [
    'expires'  => time() - 3600,
    'path'     => '/',
    'secure'   => $secure,
    'httponly' => true,
    'samesite' => 'Lax',
]);

if (!$token) {
    jsonResponse(['success' => true, 'message' => 'Logged out']);
}

try {
    $db = getDB();
    $session = $db->fetchOne(
        'SELECT s.user_id FROM sessions s WHERE s.session_token = ?',
        [$token]
    );
    if ($session) {
        logActivity((int)$session['user_id'], 'logout', 'User logged out');
        $db->query('DELETE FROM sessions WHERE session_token = ?', [$token]);
    }
    jsonResponse(['success' => true, 'message' => 'Logged out successfully']);
} catch (\Exception $e) {
    jsonResponse(['success' => true, 'message' => 'Logged out']); // Still succeed client-side
}
