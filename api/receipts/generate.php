<?php
/**
 * Flowtive Central ERP - On-Demand Receipt & Invoice Generator
 * Generates lightweight, structured receipt payload or printable HTML on the fly.
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$authUser = getAuthenticatedUser();

$saleId = intval($_GET['sale_id'] ?? 0);
if (!$saleId) {
    jsonResponse(['success' => false, 'message' => 'sale_id is required'], 400);
}

try {
    $db = getDB();

    $sale = $db->fetchOne(
        "SELECT s.*, u.full_name as cashier_name, c.name as customer_name, c.mobile as customer_mobile
         FROM sales s
         LEFT JOIN users u ON s.user_id = u.id
         LEFT JOIN customers c ON s.customer_id = c.id
         WHERE s.id = ?",
        [$saleId]
    );

    if (!$sale) {
        jsonResponse(['success' => false, 'message' => 'Sale not found'], 404);
    }

    $items = $db->fetchAll(
        "SELECT si.*, p.sku, p.barcode
         FROM sale_items si
         LEFT JOIN products p ON si.product_id = p.id
         WHERE si.sale_id = ?",
        [$saleId]
    );

    $settingsRows = $db->fetchAll(
        "SELECT setting_key, setting_value FROM company_settings
         WHERE setting_key IN ('company_name', 'company_phone', 'company_email', 'company_address', 'currency', 'receipt_header', 'receipt_footer')"
    );

    $settings = [];
    foreach ($settingsRows as $row) {
        $settings[$row['setting_key']] = $row['setting_value'];
    }

    jsonResponse([
        'success'  => true,
        'receipt'  => [
            'company' => [
                'name'    => $settings['company_name'] ?? 'Flowtive Central',
                'phone'   => $settings['company_phone'] ?? '',
                'email'   => $settings['company_email'] ?? '',
                'address' => $settings['company_address'] ?? '',
                'currency'=> $settings['currency'] ?? 'KES',
                'header'  => $settings['receipt_header'] ?? '',
                'footer'  => $settings['receipt_footer'] ?? 'Thank you for your business!'
            ],
            'sale' => [
                'id'             => $sale['id'],
                'order_number'   => $sale['order_number'],
                'sale_date'      => $sale['sale_date'],
                'cashier'        => $sale['cashier_name'] ?? 'Staff',
                'customer_name'  => $sale['customer_name'] ?? $sale['customer_name'] ?? 'Walk-in',
                'customer_phone' => $sale['customer_mobile'] ?? '',
                'subtotal'       => floatval($sale['subtotal']),
                'tax'            => floatval($sale['tax']),
                'discount'       => floatval($sale['discount']),
                'total'          => floatval($sale['total']),
                'amount_paid'    => floatval($sale['amount_paid']),
                'amount_due'     => floatval($sale['amount_due']),
                'payment_method' => $sale['payment_method'],
                'payment_status' => $sale['payment_status'],
                'mpesa_code'     => $sale['mpesa_code'] ?? null,
                'items'          => array_map(function($it) {
                    return [
                        'product_name' => $it['product_name'],
                        'sku'          => $it['sku'] ?? '',
                        'quantity'     => floatval($it['quantity']),
                        'unit_label'   => $it['unit_label'] ?? '',
                        'unit_price'   => floatval($it['unit_price']),
                        'discount'     => floatval($it['discount']),
                        'total'        => floatval($it['total']),
                    ];
                }, $items)
            ]
        ]
    ]);
} catch (\Exception $e) {
    error_log('[Flowtive] Generate receipt error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Failed to generate receipt data.'], 500);
}
