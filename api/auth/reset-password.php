<?php
/**
 * Flowtive Central ERP - Password Reset API
 * Validates a time-limited reset token, sets a new hashed password, revokes all sessions.
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);
$token       = trim($input['token'] ?? '');
$newPassword = trim($input['new_password'] ?? '');

if (empty($token) || empty($newPassword)) {
    jsonResponse(['success' => false, 'message' => 'Reset token and new password are required'], 400);
}
if (strlen($newPassword) < 8) {
    jsonResponse(['success' => false, 'message' => 'Password must be at least 8 characters'], 400);
}

try {
    $db = getDB();

    $reset = $db->fetchOne(
        'SELECT * FROM password_resets WHERE token = ? AND expires_at > NOW() AND used_at IS NULL',
        [$token]
    );
    if (!$reset) {
        jsonResponse(['success' => false, 'message' => 'Invalid or expired reset link. Please request a new one.'], 400);
    }

    $hashed = password_hash($newPassword, PASSWORD_BCRYPT);
    $db->query(
        'UPDATE users SET password = ?, force_password_reset = 0 WHERE id = ?',
        [$hashed, $reset['user_id']]
    );
    $db->query('UPDATE password_resets SET used_at = NOW() WHERE id = ?', [$reset['id']]);

    // Revoke all active sessions so the user must log in fresh
    $db->query('DELETE FROM sessions WHERE user_id = ?', [$reset['user_id']]);

    logActivity((int)$reset['user_id'], 'password_reset', 'Password changed via reset flow');

    jsonResponse([
        'success' => true,
        'message' => 'Password changed successfully. Please log in with your new password.',
    ]);

} catch (\Exception $e) {
    error_log('[Flowtive] Password reset error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Password reset failed. Please try again.'], 500);
}
