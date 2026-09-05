<?php
/**
 * Flowtive Central ERP - Login API
 * v3.1: password_hash, brute-force protection, auto-migration from plain-text, HttpOnly cookie
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);
if (empty($input['username']) || empty($input['password'])) {
    jsonResponse(['success' => false, 'message' => 'Username and password are required'], 400);
}

$username = trim($input['username']);
$password = trim($input['password']);
$ip       = $_SERVER['REMOTE_ADDR'] ?? 'unknown';

try {
    $db = getDB();

    // ── Brute-force protection ────────────────────────────────────────────────
    $lockMinutes = 15;
    $maxAttempts = 5;
    $since = date('Y-m-d H:i:s', strtotime("-{$lockMinutes} minutes"));

    $attempts = $db->fetchOne(
        'SELECT COUNT(*) AS cnt FROM login_attempts
         WHERE identifier = ? AND ip_address = ? AND attempted_at > ?',
        [$username, $ip, $since]
    );
    if ($attempts && (int)$attempts['cnt'] >= $maxAttempts) {
        jsonResponse([
            'success' => false,
            'locked'  => true,
            'message' => "Too many failed attempts. Please wait {$lockMinutes} minutes before trying again.",
        ], 429);
    }

    // ── Find user ─────────────────────────────────────────────────────────────
    $user = $db->fetchOne(
        "SELECT * FROM users
         WHERE (username = ? OR email = ?) AND status = 'active' AND deleted_at IS NULL",
        [$username, $username]
    );

    $loginFailed = false;

    if (!$user) {
        $loginFailed = true;
    } else {
        $stored   = $user['password'];
        $isHashed = str_starts_with($stored, '$2y$') || str_starts_with($stored, '$2b$');

        if ($isHashed) {
            if (!password_verify($password, $stored)) {
                $loginFailed = true;
            }
        } else {
            // Plain-text still in DB — compare and auto-migrate to bcrypt
            if ($stored !== $password) {
                $loginFailed = true;
            } else {
                $db->query(
                    'UPDATE users SET password = ? WHERE id = ?',
                    [password_hash($password, PASSWORD_BCRYPT), $user['id']]
                );
            }
        }
    }

    if ($loginFailed) {
        $db->query(
            'INSERT INTO login_attempts (identifier, ip_address, attempted_at) VALUES (?, ?, NOW())',
            [$username, $ip]
        );
        // Generic message — don't reveal whether username exists
        jsonResponse(['success' => false, 'message' => 'Invalid username or password'], 401);
    }

    // ── Clear failed attempts on success ──────────────────────────────────────
    $db->query('DELETE FROM login_attempts WHERE identifier = ? AND ip_address = ?', [$username, $ip]);

    // ── Force password reset? ─────────────────────────────────────────────────
    if (!empty($user['force_password_reset'])) {
        $resetToken = bin2hex(random_bytes(32));
        $expires    = date('Y-m-d H:i:s', strtotime('+1 hour'));
        $db->query(
            'INSERT INTO password_resets (user_id, token, expires_at)
             VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE token = VALUES(token), expires_at = VALUES(expires_at), used_at = NULL',
            [$user['id'], $resetToken, $expires]
        );
        jsonResponse([
            'success'              => true,
            'force_password_reset' => true,
            'reset_token'          => $resetToken,
            'message'              => 'Your password must be changed before you can continue.',
        ]);
    }

    // ── Create session ────────────────────────────────────────────────────────
    $sessionToken = bin2hex(random_bytes(32));
    $expiresAt    = date('Y-m-d H:i:s', strtotime('+24 hours'));

    $db->query(
        'INSERT INTO sessions (user_id, session_token, ip_address, user_agent, expires_at)
         VALUES (?, ?, ?, ?, ?)',
        [$user['id'], $sessionToken, $ip, $_SERVER['HTTP_USER_AGENT'] ?? 'unknown', $expiresAt]
    );
    $db->query('UPDATE users SET last_login = NOW() WHERE id = ?', [$user['id']]);
    logActivity($user['id'], 'login', 'User logged in');

    // HttpOnly cookie for Next.js frontend
    $secure = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
    setcookie('flowtive_session', $sessionToken, [
        'expires'  => strtotime('+24 hours'),
        'path'     => '/',
        'secure'   => $secure,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);

    unset($user['password'], $user['force_password_reset']);
    $user['modules'] = json_decode($user['modules'], true) ?? ['pos'];

    jsonResponse([
        'success'    => true,
        'message'    => 'Login successful',
        'user'       => $user,
        'token'      => $sessionToken,   // still returned for vanilla HTML frontend
        'expires_at' => $expiresAt,
    ]);

} catch (\Exception $e) {
    error_log('[Flowtive] Login error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Login failed. Please try again.'], 500);
}
