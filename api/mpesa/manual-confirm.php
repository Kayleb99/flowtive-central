<?php
/**
 * Flowtive Central ERP - M-Pesa Manual Confirmation
 *
 * Cashier manually types the M-Pesa confirmation code after the customer
 * pays via the business till number. Zero-cost, works immediately.
 */

require_once '../../api/config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$authUser = getAuthenticatedUser();

$input  = json_decode(file_get_contents('php://input'), true);
$saleId = (int)($input['sale_id'] ?? 0);
$code   = strtoupper(trim($input['mpesa_code'] ?? ''));
$amount = $input['amount'] ?? null;
$phone  = $input['phone'] ?? null;

if (!$saleId || !$code) {
    jsonResponse(['success' => false, 'message' => 'sale_id and mpesa_code are required'], 400);
}

// Validate M-Pesa confirmation code format: 6–12 alphanumeric uppercase chars (e.g., QH38KL9F21)
if (!preg_match('/^[A-Z0-9]{6,12}$/', $code)) {
    jsonResponse([
        'success' => false,
        'message' => 'Invalid M-Pesa code format. Expected 6–12 uppercase letters/digits (e.g., QH38KL9F21).',
    ], 400);
}

try {
    $db = getDB();

    $sale = $db->fetchOne('SELECT * FROM sales WHERE id = ?', [$saleId]);
    if (!$sale) {
        jsonResponse(['success' => false, 'message' => 'Sale not found'], 404);
    }
    if ($sale['payment_status'] === 'paid') {
        jsonResponse(['success' => false, 'message' => 'This sale has already been paid'], 400);
    }

    $paidAmount = $amount ?? $sale['total'];

    $db->beginTransaction();
    try {
        // Record in mpesa_transactions
        $db->query(
            "INSERT INTO mpesa_transactions (sale_id, mpesa_code, amount, phone, source, confirmed_at)
             VALUES (?, ?, ?, ?, 'manual', NOW())",
            [$saleId, $code, $paidAmount, $phone]
        );

        // Update sale payment status
        $db->query(
            "UPDATE sales
             SET mpesa_code = ?, payment_method = 'mobile', payment_status = 'paid',
                 amount_paid = total, amount_due = 0
             WHERE id = ?",
            [$code, $saleId]
        );

        $db->commit();
    } catch (\Exception $e) {
        $db->rollback();
        throw $e;
    }

    logActivity(
        $authUser['id'],
        'mpesa_manual_confirm',
        "M-Pesa code {$code} confirmed for sale #{$sale['order_number']} — Amount: {$paidAmount}"
    );

    jsonResponse([
        'success'      => true,
        'message'      => 'M-Pesa payment confirmed successfully',
        'mpesa_code'   => $code,
        'order_number' => $sale['order_number'],
        'amount'       => $paidAmount,
    ]);

} catch (\Exception $e) {
    error_log('[Flowtive] M-Pesa confirm error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Failed to confirm payment. Please try again.'], 500);
}
