<?php
/**
 * Flowtive Central ERP - Token Verification API
 * v3.1: uses shared getAuthenticatedUser() middleware
 */

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { setCORSHeaders(); exit(0); }
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$user = getAuthenticatedUser();
jsonResponse(['success' => true, 'user' => $user]);
