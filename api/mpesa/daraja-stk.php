<?php
/**
 * Flowtive Central ERP - M-Pesa Daraja STK Push Initiation
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$authUser = getAuthenticatedUser();

$mpesaMode = getSetting('mpesa_enabled', 'manual');
if ($mpesaMode !== 'daraja') {
    jsonResponse([
        'success' => false,
        'message' => 'Daraja STK Push is not enabled. Please switch to Daraja in Settings or use manual confirmation.',
        'mode'    => $mpesaMode
    ], 400);
}

$input   = json_decode(file_get_contents('php://input'), true);
$phone   = trim($input['phone'] ?? '');
$amount  = floatval($input['amount'] ?? 0);
$saleId  = intval($input['sale_id'] ?? 0);

if (!$phone || $amount <= 0 || !$saleId) {
    jsonResponse(['success' => false, 'message' => 'phone, amount, and sale_id are required'], 400);
}

try {
    $db = getDB();

    $consumerKey    = decryptSetting(getSetting('mpesa_daraja_consumer_key', ''));
    $consumerSecret = decryptSetting(getSetting('mpesa_daraja_consumer_secret', ''));
    $shortcode      = getSetting('mpesa_daraja_shortcode', '');
    $passkey        = decryptSetting(getSetting('mpesa_daraja_passkey', ''));

    if (empty($consumerKey) || empty($consumerSecret) || empty($shortcode) || empty($passkey)) {
        jsonResponse(['success' => false, 'message' => 'Daraja API credentials are not configured in Settings.'], 400);
    }

    $credentials = base64_encode($consumerKey . ':' . $consumerSecret);
    $authUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';

    $authContext = stream_context_create([
        'http' => [
            'method' => 'GET',
            'header' => "Authorization: Basic {$credentials}\r\n",
            'timeout' => 15
        ]
    ]);

    $authResp = @file_get_contents($authUrl, false, $authContext);
    if (!$authResp) {
        jsonResponse(['success' => false, 'message' => 'Failed to connect to Safaricom Daraja auth service.'], 502);
    }

    $authData = json_decode($authResp, true);
    $accessToken = $authData['access_token'] ?? null;
    if (!$accessToken) {
        jsonResponse(['success' => false, 'message' => 'Could not obtain Daraja access token. Check credentials.'], 500);
    }

    $timestamp = date('YmdHis');
    $password  = base64_encode($shortcode . $passkey . $timestamp);
    $callback  = (getenv('BACKEND_URL') ?: 'http://localhost/flowtive-central') . '/api/mpesa/callback.php';

    $formattedPhone = preg_replace('/^0/', '254', preg_replace('/^\+/', '', $phone));

    $stkPayload = json_encode([
        'BusinessShortCode' => $shortcode,
        'Password'          => $password,
        'Timestamp'         => $timestamp,
        'TransactionType'   => 'CustomerPayBillOnline',
        'Amount'            => intval(ceil($amount)),
        'PartyA'            => $formattedPhone,
        'PartyB'            => $shortcode,
        'PhoneNumber'       => $formattedPhone,
        'CallBackURL'       => $callback,
        'AccountReference'  => 'Sale-' . $saleId,
        'TransactionDesc'   => 'Payment for sale #' . $saleId
    ]);

    $stkContext = stream_context_create([
        'http' => [
            'method'  => 'POST',
            'header'  => "Authorization: Bearer {$accessToken}\r\nContent-Type: application/json\r\n",
            'content' => $stkPayload,
            'timeout' => 20
        ]
    ]);

    $stkResp = @file_get_contents('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest', false, $stkContext);
    $stkData = json_decode($stkResp, true);

    if (isset($stkData['ResponseCode']) && $stkData['ResponseCode'] === '0') {
        $checkoutRequestId = $stkData['CheckoutRequestID'];
        $db->query(
            "INSERT INTO mpesa_transactions (sale_id, mpesa_code, amount, phone, source, confirmed_at)
             VALUES (?, ?, ?, ?, 'daraja_pending', NULL)",
            [$saleId, $checkoutRequestId, $amount, $formattedPhone]
        );

        jsonResponse([
            'success'             => true,
            'message'             => 'STK Push sent to customer phone.',
            'checkout_request_id' => $checkoutRequestId
        ]);
    } else {
        jsonResponse([
            'success' => false,
            'message' => $stkData['errorMessage'] ?? 'STK push rejected by Daraja gateway.'
        ], 502);
    }
} catch (\Exception $e) {
    error_log('[Flowtive] Daraja STK error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Daraja STK push error.'], 500);
}
