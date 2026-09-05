<?php
/**
 * Flowtive Central ERP - Settings API
 * Handles company settings CRUD operations
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }

$method = $_SERVER['REQUEST_METHOD'];

try {
    $db = getDB();
    $authUser = getAuthenticatedUser();
    
    switch ($method) {
        case 'GET':
            // Load all settings from company_settings table
            $settings = $db->fetchAll("SELECT setting_key, setting_value FROM company_settings");
            $result = [];
            foreach ($settings as $row) {
                $result[$row['setting_key']] = $row['setting_value'];
            }
            
            $posUsers = $db->fetchOne("SELECT COUNT(*) as count FROM users WHERE status = 'active' AND JSON_CONTAINS(modules, '\"pos\"')");
            $result['pos_user_count'] = $posUsers ? $posUsers['count'] : 1;
            
            jsonResponse(['success' => true, 'data' => $result, 'settings' => $result]);
            break;
            
        case 'POST':
            // Save settings
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input) {
                jsonResponse(['success' => false, 'message' => 'Invalid JSON data'], 400);
            }
            
            $settingsMap = [
                'company_name'              => $input['companyName'] ?? $input['company_name'] ?? null,
                'company_phone'             => $input['phone'] ?? $input['company_phone'] ?? null,
                'company_email'             => $input['email'] ?? $input['company_email'] ?? null,
                'company_address'           => $input['address'] ?? $input['company_address'] ?? null,
                'currency'                  => $input['currency'] ?? null,
                'support_email'             => $input['supportEmail'] ?? $input['support_email'] ?? null,
                'timezone'                  => $input['timezone'] ?? null,
                'daily_target'              => $input['dailyTarget'] ?? $input['daily_target'] ?? null,
                'sync_interval'             => $input['syncInterval'] ?? $input['sync_interval'] ?? null,
                'tax_enabled'               => isset($input['taxEnabled']) ? ($input['taxEnabled'] ? 'true' : 'false') : null,
                'tax_rate'                  => $input['taxRate'] ?? $input['tax_rate'] ?? null,
                'receipt_header'            => $input['receiptHeader'] ?? $input['receipt_header'] ?? null,
                'receipt_footer'            => $input['receiptFooter'] ?? $input['receipt_footer'] ?? null,
                // M-Pesa configuration
                'mpesa_till_number'         => $input['mpesa_till_number'] ?? null,
                'mpesa_enabled'             => $input['mpesa_enabled'] ?? null,  // 'off' | 'manual' | 'daraja'
                'mpesa_daraja_shortcode'    => $input['mpesa_daraja_shortcode'] ?? null,
                'mpesa_daraja_consumer_key' => isset($input['mpesa_daraja_consumer_key']) && $input['mpesa_daraja_consumer_key']
                    ? encryptSetting($input['mpesa_daraja_consumer_key']) : null,
                'mpesa_daraja_consumer_secret' => isset($input['mpesa_daraja_consumer_secret']) && $input['mpesa_daraja_consumer_secret']
                    ? encryptSetting($input['mpesa_daraja_consumer_secret']) : null,
                'mpesa_daraja_passkey'      => isset($input['mpesa_daraja_passkey']) && $input['mpesa_daraja_passkey']
                    ? encryptSetting($input['mpesa_daraja_passkey']) : null,
            ];
            
            foreach ($settingsMap as $key => $value) {
                if ($value !== null) {
                    // Check if setting exists
                    $existing = $db->fetchOne("SELECT id FROM company_settings WHERE setting_key = ?", [$key]);
                    
                    if ($existing) {
                        $db->query(
                            "UPDATE company_settings SET setting_value = ?, updated_at = NOW() WHERE setting_key = ?",
                            [$value, $key]
                        );
                    } else {
                        $db->query(
                            "INSERT INTO company_settings (setting_key, setting_value, setting_type, created_at, updated_at) VALUES (?, ?, 'string', NOW(), NOW())",
                            [$key, $value]
                        );
                    }
                }
            }
            
            jsonResponse(['success' => true, 'message' => 'Settings saved successfully']);
            break;
            
        default:
            jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
    }
    
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
}
?>
