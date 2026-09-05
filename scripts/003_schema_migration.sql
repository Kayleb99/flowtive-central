-- ================================================
-- FLOWTIVE CENTRAL ERP - SCHEMA MIGRATION v3.1
-- ================================================
-- Safe ALTER TABLE migration for existing MySQL databases.
-- Run AFTER scripts/001_main_database.sql
-- ================================================

USE flowtive_erp;

-- ── 1. Fix stock_movements: INT → DECIMAL for fractional stock (e.g. 30.5 metres)
ALTER TABLE stock_movements
    MODIFY COLUMN quantity       DECIMAL(15,3) NOT NULL,
    MODIFY COLUMN previous_stock DECIMAL(15,3) NOT NULL,
    MODIFY COLUMN new_stock      DECIMAL(15,3) NOT NULL;

-- ── 2. Add force_password_reset flag to users
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS force_password_reset TINYINT(1) NOT NULL DEFAULT 0 AFTER status;

-- Force reset for all existing plain-text password users
UPDATE users SET force_password_reset = 1 WHERE force_password_reset = 0;

-- ── 3. Remove stale denormalized counters (use COUNT() queries instead)
ALTER TABLE categories DROP COLUMN IF EXISTS product_count;
ALTER TABLE units       DROP COLUMN IF EXISTS products_using;

-- ── 4. Remove HTML blob columns from sales (receipts generated on-demand now)
ALTER TABLE sales DROP COLUMN IF EXISTS receipt_html;
ALTER TABLE sales DROP COLUMN IF EXISTS invoice_html;

-- ── 5. Add image_path column for file-based image storage (replaces base64 in image col)
ALTER TABLE products
    ADD COLUMN IF NOT EXISTS image_path VARCHAR(500) DEFAULT NULL AFTER image_url;

-- ── 6. password_resets table
CREATE TABLE IF NOT EXISTS password_resets (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    token      VARCHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME    NOT NULL,
    used_at    DATETIME    DEFAULT NULL,
    created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token   (token),
    INDEX idx_user    (user_id),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB;

-- ── 7. login_attempts table (brute-force protection)
CREATE TABLE IF NOT EXISTS login_attempts (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    identifier   VARCHAR(150) NOT NULL,
    ip_address   VARCHAR(45)  NOT NULL,
    attempted_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_identifier (identifier, ip_address),
    INDEX idx_time       (attempted_at)
) ENGINE=InnoDB;

-- ── 8. mpesa_transactions table
CREATE TABLE IF NOT EXISTS mpesa_transactions (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    sale_id      INT,
    mpesa_code   VARCHAR(100),
    amount       DECIMAL(15,2),
    phone        VARCHAR(20),
    source       ENUM('manual','daraja','daraja_pending','daraja_failed') DEFAULT 'manual',
    confirmed_at DATETIME  DEFAULT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE SET NULL,
    INDEX idx_sale   (sale_id),
    INDEX idx_code   (mpesa_code),
    INDEX idx_source (source)
) ENGINE=InnoDB;

-- ── 9. refunds table
CREATE TABLE IF NOT EXISTS refunds (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    original_sale_id INT NOT NULL,
    amount           DECIMAL(15,2) NOT NULL,
    reason           TEXT,
    refund_method    ENUM('cash','mobile','store_credit') DEFAULT 'cash',
    approved_by      INT,
    requested_by     INT,
    status           ENUM('pending','approved','rejected','completed') DEFAULT 'pending',
    notes            TEXT,
    refund_date      DATETIME  DEFAULT NULL,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (original_sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by)      REFERENCES users(id)  ON DELETE SET NULL,
    FOREIGN KEY (requested_by)     REFERENCES users(id)  ON DELETE SET NULL,
    INDEX idx_sale   (original_sale_id),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- ── 10. purchase_orders table
CREATE TABLE IF NOT EXISTS purchase_orders (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    po_number         VARCHAR(50)  NOT NULL UNIQUE,
    supplier_name     VARCHAR(200),
    supplier_contact  VARCHAR(100),
    delivery_address  TEXT,
    expected_delivery DATE,
    status            ENUM('draft','sent','received','cancelled') DEFAULT 'draft',
    total_cost        DECIMAL(15,2) DEFAULT 0,
    notes             TEXT,
    created_by        INT,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status    (status),
    INDEX idx_po_number (po_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_order_items (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    po_id        INT NOT NULL,
    product_id   INT,
    product_name VARCHAR(200) NOT NULL,
    quantity     DECIMAL(15,3) NOT NULL,
    unit_cost    DECIMAL(15,2) DEFAULT 0,
    total        DECIMAL(15,2) DEFAULT 0,
    notes        TEXT,
    FOREIGN KEY (po_id)       REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)  REFERENCES products(id)        ON DELETE SET NULL,
    INDEX idx_po (po_id)
) ENGINE=InnoDB;

-- ── 11. Seed default M-Pesa settings (no-op if already set)
INSERT INTO company_settings (setting_key, setting_value, setting_type)
VALUES ('mpesa_enabled', 'manual', 'string')
ON DUPLICATE KEY UPDATE setting_key = setting_key;

INSERT INTO company_settings (setting_key, setting_value, setting_type)
VALUES ('mpesa_till_number', '', 'string')
ON DUPLICATE KEY UPDATE setting_key = setting_key;

SELECT '========================================' AS '';
SELECT 'MIGRATION v3.1 COMPLETE!' AS message;
SELECT 'Modified : stock_movements (DECIMAL), users (force_password_reset), products (image_path)' AS info;
SELECT 'Removed  : product_count, products_using, receipt_html, invoice_html' AS info;
SELECT 'Added    : password_resets, login_attempts, mpesa_transactions, refunds, purchase_orders' AS info;
SELECT 'ACTION   : All users flagged for force_password_reset. Share reset links via Settings > Users.' AS action;
