<?php
/**
 * Flowtive Central ERP - Active Sessions API
 * GET  - list all active sessions for the current user
 * DELETE - revoke a specific session (or all sessions)
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }

$user = getAuthenticatedUser();

try {
    $db = getDB();

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $sessions = $db->fetchAll(
            'SELECT id, ip_address, user_agent, created_at, expires_at,
                    (session_token = ?) AS is_current
             FROM sessions
             WHERE user_id = ? AND expires_at > NOW()
             ORDER BY created_at DESC',
            [$user['session_token'], $user['id']]
        );

        // Parse browser/device info from user_agent
        foreach ($sessions as &$s) {
            $ua = $s['user_agent'] ?? '';
            $s['device']  = str_contains($ua, 'Mobile') ? 'Mobile' : 'Desktop';
            $s['browser'] = 'Unknown';
            foreach (['Chrome', 'Firefox', 'Safari', 'Edge', 'Opera'] as $b) {
                if (str_contains($ua, $b)) { $s['browser'] = $b; break; }
            }
            $s['is_current'] = (bool)$s['is_current'];
            unset($s['user_agent']); // Don't expose raw UA to client
        }

        jsonResponse(['success' => true, 'sessions' => $sessions, 'count' => count($sessions)]);

    } elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
        $input     = json_decode(file_get_contents('php://input'), true) ?? [];
        $revokeAll = !empty($input['revoke_all']);
        $sessionId = (int)($input['session_id'] ?? 0);

        if ($revokeAll) {
            $db->query('DELETE FROM sessions WHERE user_id = ?', [$user['id']]);
            // Clear cookie
            setcookie('flowtive_session', '', ['expires' => time() - 3600, 'path' => '/', 'httponly' => true, 'samesite' => 'Lax']);
            logActivity($user['id'], 'revoke_all_sessions', 'All sessions revoked');
            jsonResponse(['success' => true, 'message' => 'All sessions revoked. Please log in again.']);
        } elseif ($sessionId) {
            $db->query('DELETE FROM sessions WHERE id = ? AND user_id = ?', [$sessionId, $user['id']]);
            logActivity($user['id'], 'revoke_session', "Revoked session ID {$sessionId}");
            jsonResponse(['success' => true, 'message' => 'Session revoked']);
        } else {
            jsonResponse(['success' => false, 'message' => 'Provide session_id or revoke_all: true'], 400);
        }

    } else {
        jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }

} catch (\Exception $e) {
    error_log('[Flowtive] Sessions error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Session operation failed.'], 500);
}
