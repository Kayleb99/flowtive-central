<?php
/**
 * Flowtive Central ERP - Safaricom Daraja STK Callback Handler
 */

require_once '../config/database.php';

header('Content-Type: application/json');

$rawInput = file_get_contents('php://input');
$callbackData = json_decode($rawInput, true);

if (!$callbackData) {
    http_response_code(400);
    echo json_encode(['ResultCode' => 1, 'ResultDesc' => 'Malformed payload']);
    exit;
}

try {
    $db = getDB();
    $stkCallback = $callbackData['Body']['stkCallback'] ?? null;

    if (!$stkCallback) {
        http_response_code(400);
        echo json_encode(['ResultCode' => 1, 'ResultDesc' => 'Invalid callback body']);
        exit;
    }

    $resultCode        = intval($stkCallback['ResultCode'] ?? -1);
    $checkoutRequestId = $stkCallback['CheckoutRequestID'] ?? '';

    if ($resultCode === 0) {
        $items = $stkCallback['CallbackMetadata']['Item'] ?? [];
        $mpesaCode = '';
        $amount    = null;
        $phone     = null;

        foreach ($items as $item) {
            if (($item['Name'] ?? '') === 'MpesaReceiptNumber') $mpesaCode = $item['Value'];
            if (($item['Name'] ?? '') === 'Amount')             $amount    = $item['Value'];
            if (($item['Name'] ?? '') === 'PhoneNumber')        $phone     = $item['Value'];
        }

        $db->beginTransaction();
        try {
            $txn = $db->fetchOne("SELECT * FROM mpesa_transactions WHERE mpesa_code = ?", [$checkoutRequestId]);

            if ($txn) {
                $db->query(
                    "UPDATE mpesa_transactions
                     SET mpesa_code = ?, amount = COALESCE(?, amount), phone = COALESCE(?, phone),
                         source = 'daraja', confirmed_at = NOW()
                     WHERE id = ?",
                    [$mpesaCode, $amount, $phone, $txn['id']]
                );

                if ($txn['sale_id']) {
                    $db->query(
                        "UPDATE sales
                         SET mpesa_code = ?, payment_status = 'paid', payment_method = 'mobile',
                             amount_paid = total, amount_due = 0
                         WHERE id = ?",
                        [$mpesaCode, $txn['sale_id']]
                    );
                }
            }
            $db->commit();
        } catch (\Exception $e) {
            $db->rollback();
            throw $e;
        }
    } else {
        $db->query(
            "UPDATE mpesa_transactions SET source = 'daraja_failed' WHERE mpesa_code = ?",
            [$checkoutRequestId]
        );
    }

    echo json_encode(['ResultCode' => 0, 'ResultDesc' => 'Success']);
} catch (\Exception $e) {
    error_log('[Flowtive] Daraja callback error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ResultCode' => 1, 'ResultDesc' => 'Internal error']);
}
