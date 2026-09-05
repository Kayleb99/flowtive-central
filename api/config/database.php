<?php
/**
 * Flowtive Central ERP - Database Configuration
 * Version: 3.1 - Security hardened
 */

// Database configuration
define('DB_HOST',    getenv('DB_HOST')    ?: 'localhost');
define('DB_NAME',    getenv('DB_NAME')    ?: 'flowtive_erp');
define('DB_USER',    getenv('DB_USER')    ?: 'root');
define('DB_PASS',    getenv('DB_PASS')    ?: '');
define('DB_CHARSET', 'utf8mb4');
define('DB_DRIVER',  getenv('DB_DRIVER')  ?: 'mysql'); // 'mysql' or 'pgsql'

// Application configuration
define('APP_NAME',    'Flowtive Central');
define('APP_VERSION', '3.1.0');
define('APP_SECRET',  getenv('APP_SECRET') ?: 'flowtive-secret-key-change-in-production');
define('TIMEZONE',    getenv('APP_TIMEZONE') ?: 'Africa/Nairobi');

date_default_timezone_set(TIMEZONE);

// Error reporting — never expose errors to clients
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors',     1);

// Session cookie hardening
ini_set('session.cookie_httponly', 1);
ini_set('session.use_only_cookies', 1);

// ─── CORS ────────────────────────────────────────────────────────────────────

/**
 * Set CORS headers, locking down to allowed origins.
 * Allowed origins are comma-separated in the ALLOWED_ORIGINS env var.
 * Falls back to localhost on both port 80 and 3000 for development.
 */
function setCORSHeaders(): void {
    $default = 'http://localhost,http://localhost:3000,http://localhost:80,http://127.0.0.1';
    $allowed = array_filter(array_map('trim', explode(',', getenv('ALLOWED_ORIGINS') ?: $default)));
    $origin  = $_SERVER['HTTP_ORIGIN'] ?? '';

    if (in_array($origin, $allowed, true)) {
        header('Access-Control-Allow-Origin: ' . $origin);
    } elseif (empty($origin)) {
        // Same-origin or curl — allow
        header('Access-Control-Allow-Origin: *');
    }
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Access-Control-Allow-Credentials: true');
    header('Vary: Origin');
}

// ─── Database ─────────────────────────────────────────────────────────────────

class Database {
    private static ?Database $instance = null;
    private \PDO $connection;

    private function __construct() {
        try {
            if (DB_DRIVER === 'pgsql') {
                $dsn = 'pgsql:host=' . DB_HOST . ';dbname=' . DB_NAME;
            } else {
                $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;
            }
            $options = [
                \PDO::ATTR_ERRMODE            => \PDO::ERRMODE_EXCEPTION,
                \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
                \PDO::ATTR_EMULATE_PREPARES   => false,
            ];
            if (DB_DRIVER !== 'pgsql') {
                $options[\PDO::MYSQL_ATTR_INIT_COMMAND] = 'SET NAMES ' . DB_CHARSET;
            }
            $this->connection = new \PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (\PDOException $e) {
            // Do NOT expose $e->getMessage() to clients
            error_log('[Flowtive] DB connection failed: ' . $e->getMessage());
            setCORSHeaders();
            http_response_code(503);
            header('Content-Type: application/json');
            echo json_encode(['success' => false, 'message' => 'Service temporarily unavailable.']);
            exit;
        }
    }

    public static function getInstance(): Database {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection(): \PDO { return $this->connection; }

    public function query(string $sql, array $params = []): \PDOStatement {
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);
            return $stmt;
        } catch (\PDOException $e) {
            error_log('[Flowtive] Query failed: ' . $e->getMessage() . ' | SQL: ' . $sql);
            throw new \Exception('Database operation failed.');
        }
    }

    public function fetchOne(string $sql, array $params = []): array|false {
        return $this->query($sql, $params)->fetch();
    }

    public function fetchAll(string $sql, array $params = []): array {
        return $this->query($sql, $params)->fetchAll();
    }

    public function lastInsertId(): string { return $this->connection->lastInsertId(); }
    public function beginTransaction(): bool { return $this->connection->beginTransaction(); }
    public function commit(): bool { return $this->connection->commit(); }
    public function rollback(): bool { return $this->connection->rollBack(); }

    private function __clone() {}
    public function __wakeup() { throw new \Exception('Cannot unserialize singleton'); }
}

function getDB(): Database {
    return Database::getInstance();
}

// ─── Response helpers ─────────────────────────────────────────────────────────

function jsonResponse(array $data, int $statusCode = 200): never {
    setCORSHeaders();
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

// ─── Authentication middleware ────────────────────────────────────────────────

/**
 * Validate the current request's session and return the user array.
 * Sends a 401 JSON response and exits if not authenticated.
 * Reads token from: Authorization: Bearer <token> header, OR flowtive_session cookie.
 */
function getAuthenticatedUser(): array {
    $token = null;

    // 1. Authorization header (used by vanilla HTML frontend & API clients)
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    if ($authHeader) {
        $token = str_replace('Bearer ', '', $authHeader);
    }

    // 2. HttpOnly cookie (used by Next.js frontend)
    if (!$token && isset($_COOKIE['flowtive_session'])) {
        $token = $_COOKIE['flowtive_session'];
    }

    if (!$token) {
        jsonResponse(['success' => false, 'message' => 'Authentication required. Please log in.'], 401);
    }

    $db = getDB();
    $session = $db->fetchOne(
        "SELECT s.id as session_id, s.session_token, s.expires_at,
                u.id as uid, u.username, u.full_name, u.email, u.mobile,
                u.role, u.modules, u.status, u.force_password_reset
         FROM sessions s
         JOIN users u ON s.user_id = u.id
         WHERE s.session_token = ? AND s.expires_at > NOW() AND u.status = 'active'
           AND u.deleted_at IS NULL",
        [$token]
    );

    if (!$session) {
        jsonResponse(['success' => false, 'message' => 'Session expired or invalid. Please log in again.'], 401);
    }

    return [
        'id'                   => (int)$session['uid'],
        'session_id'           => (int)$session['session_id'],
        'session_token'        => $session['session_token'],
        'username'             => $session['username'],
        'full_name'            => $session['full_name'],
        'email'                => $session['email'],
        'mobile'               => $session['mobile'],
        'role'                 => $session['role'],
        'modules'              => json_decode($session['modules'], true) ?? ['pos'],
        'status'               => $session['status'],
        'force_password_reset' => (bool)$session['force_password_reset'],
    ];
}

// ─── Utilities ────────────────────────────────────────────────────────────────

function formatCurrency(float $amount): string {
    $currency = getSetting('currency', 'KES');
    return $currency . ' ' . number_format($amount, 2);
}

/**
 * Generate a unique order number: date (Ymd) + random hex suffix.
 * Uses random bytes to avoid the COUNT+1 race condition under concurrent writes.
 */
function generateOrderNumber(): string {
    return date('Ymd') . strtoupper(bin2hex(random_bytes(3)));
}

function getSetting(string $key, mixed $default = null): mixed {
    try {
        $db  = getDB();
        $row = $db->fetchOne('SELECT setting_value FROM company_settings WHERE setting_key = ?', [$key]);
        return ($row && $row['setting_value'] !== null && $row['setting_value'] !== '')
            ? $row['setting_value']
            : $default;
    } catch (\Exception $e) {
        return $default;
    }
}

function archiveDeletedItem(
    string $entityType,
    int    $entityId,
    string $label,
    mixed  $data,
    array  $performer = [],
    ?string $reason = null
): int {
    $db = getDB();
    $db->query(
        'INSERT INTO deleted_items
             (entity_type, entity_id, entity_label, data, deleted_by_id, deleted_by_name, deleted_by_role, reason)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
            $entityType,
            $entityId,
            $label,
            is_string($data) ? $data : json_encode($data),
            $performer['id']   ?? null,
            $performer['name'] ?? 'Unknown',
            $performer['role'] ?? 'Unknown',
            $reason,
        ]
    );
    return (int)$db->lastInsertId();
}

function getPerformer(array $input = []): array {
    return [
        'id'   => $input['performed_by_id']   ?? $input['user_id']   ?? null,
        'name' => $input['performed_by_name'] ?? $input['user_name'] ?? 'Unknown',
        'role' => $input['performed_by_role'] ?? $input['user_role'] ?? 'Unknown',
    ];
}

function logActivity(int $userId, string $action, string $description = ''): void {
    try {
        $db = getDB();
        $db->query(
            'INSERT INTO user_activity (user_id, action, description, ip_address, user_agent) VALUES (?, ?, ?, ?, ?)',
            [
                $userId,
                $action,
                $description,
                $_SERVER['REMOTE_ADDR']     ?? 'unknown',
                $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
            ]
        );
    } catch (\Exception $e) {
        // Non-fatal — don't propagate
        error_log('[Flowtive] logActivity failed: ' . $e->getMessage());
    }
}

/**
 * Encrypt a string for storage (M-Pesa credentials, etc.)
 */
function encryptSetting(string $value): string {
    $key = APP_SECRET;
    $iv  = substr(md5($key), 0, 16);
    return base64_encode(openssl_encrypt($value, 'AES-256-CBC', $key, 0, $iv));
}

/**
 * Decrypt a stored encrypted setting.
 */
function decryptSetting(string $value): string {
    $key = APP_SECRET;
    $iv  = substr(md5($key), 0, 16);
    return openssl_decrypt(base64_decode($value), 'AES-256-CBC', $key, 0, $iv) ?: '';
}
