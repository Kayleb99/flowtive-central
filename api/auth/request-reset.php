<?php
/**
 * Flowtive Central ERP - Request Password Reset (Admin endpoint)
 * Generates a 24-hour reset token for any user. Only Admins/Super Admins can call this.
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$actor = getAuthenticatedUser();

if (!in_array($actor['role'], ['Super Admin', 'Admin', 'Manager'], true)) {
    jsonResponse(['success' => false, 'message' => 'Insufficient permissions to trigger password resets'], 403);
}

$input  = json_decode(file_get_contents('php://input'), true);
$userId = (int)($input['user_id'] ?? 0);

if (!$userId) {
    jsonResponse(['success' => false, 'message' => 'user_id is required'], 400);
}

try {
    $db = getDB();

    $user = $db->fetchOne(
        "SELECT id, username, full_name, email FROM users WHERE id = ? AND status = 'active' AND deleted_at IS NULL",
        [$userId]
    );
    if (!$user) {
        jsonResponse(['success' => false, 'message' => 'User not found'], 404);
    }

    // Prevent escalation: Managers cannot reset Admins / Super Admins
    if ($actor['role'] === 'Manager') {
        $target = $db->fetchOne('SELECT role FROM users WHERE id = ?', [$userId]);
        if ($target && in_array($target['role'], ['Admin', 'Super Admin'], true)) {
            jsonResponse(['success' => false, 'message' => 'You cannot reset passwords for Admins'], 403);
        }
    }

    $token   = bin2hex(random_bytes(32));
    $expires = date('Y-m-d H:i:s', strtotime('+24 hours'));

    $db->query(
        'INSERT INTO password_resets (user_id, token, expires_at)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE token = VALUES(token), expires_at = VALUES(expires_at), used_at = NULL',
        [$userId, $token, $expires]
    );
    $db->query('UPDATE users SET force_password_reset = 1 WHERE id = ?', [$userId]);
    $db->query('DELETE FROM sessions WHERE user_id = ?', [$userId]); // Force re-login via reset

    logActivity(
        $actor['id'],
        'request_password_reset',
        "Triggered password reset for user ID {$userId} ({$user['username']})"
    );

    $appUrl   = getenv('APP_URL') ?: 'http://localhost:3000';
    $resetUrl = "{$appUrl}/reset-password?token={$token}";

    jsonResponse([
        'success'    => true,
        'reset_url'  => $resetUrl,
        'expires_at' => $expires,
        'user'       => [
            'id'        => $user['id'],
            'username'  => $user['username'],
            'full_name' => $user['full_name'],
            'email'     => $user['email'],
        ],
        'message' => 'Reset link generated. Share it with the user — it expires in 24 hours.',
    ]);

} catch (\Exception $e) {
    error_log('[Flowtive] Request reset error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Failed to generate reset token.'], 500);
}
