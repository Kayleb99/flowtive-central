<?php
/**
 * Flowtive Central ERP - Support Messages API
 * Stores Help & Support contact messages and emails the Super Admin.
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
            // List messages (for Super Admin inbox). Optional ?status= filter.
            $where = "WHERE 1=1";
            $params = [];
            if (isset($_GET['status']) && $_GET['status'] !== 'all') {
                $where .= " AND status = ?";
                $params[] = $_GET['status'];
            }
            $messages = $db->fetchAll(
                "SELECT * FROM support_messages $where ORDER BY created_at DESC",
                $params
            );
            $unread = $db->fetchOne("SELECT COUNT(*) as c FROM support_messages WHERE status = 'new'");
            jsonResponse([
                'success' => true,
                'data' => $messages,
                'messages' => $messages,
                'unread' => $unread ? (int)$unread['c'] : 0,
                'count' => count($messages)
            ]);
            break;

        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);

            if (!isset($input['message']) || trim($input['message']) === '') {
                jsonResponse(['success' => false, 'message' => 'Message is required'], 400);
            }

            $senderName  = $input['sender_name'] ?? $input['name'] ?? 'Anonymous';
            $senderEmail = $input['sender_email'] ?? $input['email'] ?? '';
            $senderRole  = $input['sender_role'] ?? $input['role'] ?? 'User';
            $subject     = $input['subject'] ?? 'Support Request';
            $category    = $input['category'] ?? 'general';
            $userId      = $input['user_id'] ?? null;

            // Resolve the Super Admin destination email
            $supportEmail = getSetting('support_email', '');
            if (!$supportEmail) {
                $admin = $db->fetchOne(
                    "SELECT email FROM users WHERE role = 'Super Admin' AND email IS NOT NULL AND email != '' ORDER BY id ASC LIMIT 1"
                );
                $supportEmail = $admin['email'] ?? '';
            }

            $emailed = 0;
            if ($supportEmail) {
                $body = "New support message from Flowtive Central ERP\n\n"
                      . "Name: {$senderName}\n"
                      . "Role: {$senderRole}\n"
                      . "Email: {$senderEmail}\n"
                      . "Category: {$category}\n"
                      . "Subject: {$subject}\n\n"
                      . "Message:\n" . $input['message'] . "\n\n"
                      . "Sent: " . date('Y-m-d H:i:s');

                $headers  = "From: Flowtive ERP <no-reply@flowtive.local>\r\n";
                if ($senderEmail) {
                    $headers .= "Reply-To: {$senderEmail}\r\n";
                }
                $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

                // PHP mail() - requires the host (e.g. XAMPP) to have mail configured.
                $emailed = @mail($supportEmail, "[Support] {$subject}", $body, $headers) ? 1 : 0;
            }

            $db->query(
                "INSERT INTO support_messages (user_id, sender_name, sender_email, sender_role, subject, message, category, emailed)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                [$userId, $senderName, $senderEmail, $senderRole, $subject, $input['message'], $category, $emailed]
            );

            jsonResponse([
                'success' => true,
                'message' => 'Your message has been sent to support.',
                'emailed' => (bool)$emailed,
                'destination' => $supportEmail ?: null
            ], 201);
            break;

        case 'PUT':
            // Mark a message read/resolved
            $input = json_decode(file_get_contents('php://input'), true);
            if (!isset($input['id'])) {
                jsonResponse(['success' => false, 'message' => 'Message ID is required'], 400);
            }
            $status = $input['status'] ?? 'read';
            $db->query("UPDATE support_messages SET status = ? WHERE id = ?", [$status, $input['id']]);
            jsonResponse(['success' => true, 'message' => 'Message updated']);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }

} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
