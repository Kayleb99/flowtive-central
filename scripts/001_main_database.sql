-- ================================================
-- FLOWTIVE CENTRAL ERP - MAIN DATABASE SCHEMA
-- ================================================
-- Version: 3.0 Production Ready for XAMPP
-- Description: Complete database schema with all tables, views, and indexes.
--              Includes multi-unit-of-sale, soft-delete archive, support
--              messages, currency settings, and profile images.
-- Run this script FIRST to create the database structure
-- ================================================

-- Create database
CREATE DATABASE IF NOT EXISTS flowtive_erp
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE flowtive_erp;

-- ================================================
-- CORE TABLES
-- ================================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    mobile VARCHAR(20),
    phone VARCHAR(20),
    role ENUM('Super Admin', 'Admin', 'Manager', 'Cashier', 'Inventory Manager') NOT NULL DEFAULT 'Cashier',
    modules JSON,
    profile_image LONGTEXT DEFAULT NULL,
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    last_login DATETIME DEFAULT NULL,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_status (status),
    INDEX idx_role (role)
) ENGINE=InnoDB;

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50) DEFAULT 'fa-box',
    color VARCHAR(20) DEFAULT '#667eea',
    description TEXT,
    product_count INT DEFAULT 0,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB;

-- Units table
CREATE TABLE IF NOT EXISTS units (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(20),
    abbreviation VARCHAR(20),
    type ENUM('count', 'weight', 'length', 'volume', 'area') DEFAULT 'count',
    description TEXT,
    products_using INT DEFAULT 0,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB;

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    sku VARCHAR(50) UNIQUE,
    barcode VARCHAR(100),
    category_id INT,
    unit_id INT,
    cost_price DECIMAL(15,2) DEFAULT 0.00,
    selling_price DECIMAL(15,2) DEFAULT 0.00,
    minimum_price DECIMAL(15,2) DEFAULT 0.00,
    -- Stock tracked in BASE units; DECIMAL allows fractional stock (e.g. 30.5 metres)
    current_stock DECIMAL(15,3) DEFAULT 0,
    stock_quantity DECIMAL(15,3) DEFAULT 0,
    minimum_stock DECIMAL(15,3) DEFAULT 0,
    low_stock_threshold INT DEFAULT 0,
    maximum_stock INT DEFAULT 0,
    -- Multi-unit-of-sale metadata (see product_units table)
    has_multi_unit TINYINT(1) DEFAULT 0,
    base_unit_label VARCHAR(60) DEFAULT NULL,      -- metre, piece
    package_unit_label VARCHAR(60) DEFAULT NULL,   -- roll, packet
    package_size DECIMAL(15,3) DEFAULT NULL,        -- base units per package
    -- image columns are LONGTEXT to store base64 images
    image LONGTEXT,
    image_url LONGTEXT,
    description TEXT,
    description_color VARCHAR(50),
    description_size VARCHAR(50),
    description_type VARCHAR(100),
    description_dimensions VARCHAR(100),
    description_weight VARCHAR(50),
    brand VARCHAR(100),
    supplier VARCHAR(200),
    total_sold INT DEFAULT 0,
    last_restocked DATETIME,
    storage_location VARCHAR(100),
    status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE SET NULL,
    INDEX idx_name (name),
    INDEX idx_sku (sku),
    INDEX idx_barcode (barcode),
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_stock (current_stock)
) ENGINE=InnoDB;

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    mobile VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    total_purchases DECIMAL(15,2) DEFAULT 0.00,
    total_debt DECIMAL(15,2) DEFAULT 0.00,
    last_purchase_date DATETIME,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_mobile (mobile)
) ENGINE=InnoDB;

-- ================================================
-- SALES TABLES
-- ================================================

-- Sales table
CREATE TABLE IF NOT EXISTS sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    parent_sale_id INT DEFAULT NULL,
    sale_type ENUM('regular', 'debt_followup') DEFAULT 'regular',
    customer_id INT,
    customer_name VARCHAR(100),
    customer_mobile VARCHAR(20),
    user_id INT NOT NULL,
    subtotal DECIMAL(15,2) DEFAULT 0.00,
    tax DECIMAL(15,2) DEFAULT 0.00,
    discount DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) DEFAULT 0.00,
    profit DECIMAL(15,2) DEFAULT 0.00,
    unexpected_profit DECIMAL(15,2) DEFAULT 0.00,
    payment_method ENUM('cash', 'mobile', 'split', 'debt') DEFAULT 'cash',
    mpesa_code VARCHAR(50),
    split_cash DECIMAL(15,2) DEFAULT NULL,
    split_mobile DECIMAL(15,2) DEFAULT NULL,
    payment_status ENUM('paid', 'partial', 'pending', 'cancelled') DEFAULT 'paid',
    amount_paid DECIMAL(15,2) DEFAULT 0.00,
    amount_due DECIMAL(15,2) DEFAULT 0.00,
    notes TEXT,
    receipt_html LONGTEXT,
    invoice_html LONGTEXT,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_sale_id) REFERENCES sales(id) ON DELETE SET NULL,
    INDEX idx_order_number (order_number),
    INDEX idx_sale_date (sale_date),
    INDEX idx_payment_status (payment_status),
    INDEX idx_user (user_id),
    INDEX idx_parent_sale (parent_sale_id),
    INDEX idx_sales_user_date (user_id, sale_date)
) ENGINE=InnoDB;

-- Sale items table
CREATE TABLE IF NOT EXISTS sale_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    quantity DECIMAL(15,3) NOT NULL,
    unit_label VARCHAR(60) DEFAULT NULL,        -- unit-of-sale used (Roll, Metre)
    base_quantity DECIMAL(15,3) DEFAULT NULL,   -- base units deducted from stock
    unit_price DECIMAL(15,2) NOT NULL,
    cost_price DECIMAL(15,2) DEFAULT 0.00,
    minimum_price DECIMAL(15,2) DEFAULT 0.00,
    discount DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) NOT NULL,
    profit DECIMAL(15,2) DEFAULT 0.00,
    unexpected_profit DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_sale (sale_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB;

-- ================================================
-- STOCK MANAGEMENT TABLES
-- ================================================

-- Stock movements table
CREATE TABLE IF NOT EXISTS stock_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    type ENUM('purchase', 'sale', 'adjustment', 'return', 'damage', 'transfer') NOT NULL,
    quantity INT NOT NULL,
    previous_stock INT NOT NULL,
    new_stock INT NOT NULL,
    user_id INT,
    reference_id INT,
    reference_type VARCHAR(50),
    reason TEXT,
    movement_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_product (product_id),
    INDEX idx_type (type),
    INDEX idx_date (movement_date)
) ENGINE=InnoDB;

-- ================================================
-- DEBT MANAGEMENT TABLES
-- ================================================

-- Debt orders table
CREATE TABLE IF NOT EXISTS debt_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    customer_id INT NOT NULL,
    amount_due DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) DEFAULT 0.00,
    due_date DATE NOT NULL,
    status ENUM('pending', 'partial', 'paid', 'overdue') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB;

-- Debt payments table
CREATE TABLE IF NOT EXISTS debt_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    debt_id INT NOT NULL,
    sale_id INT,
    amount DECIMAL(15,2) NOT NULL,
    payment_method ENUM('cash', 'mobile') DEFAULT 'cash',
    mpesa_code VARCHAR(50),
    user_id INT,
    receipt_html LONGTEXT,
    notes TEXT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (debt_id) REFERENCES debt_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_debt (debt_id)
) ENGINE=InnoDB;

-- ================================================
-- MULTI-UNIT OF SALE
-- ================================================

-- Each product can have one or more sellable units. The smallest unit is the
-- "base" unit. current_stock is always tracked in BASE units (e.g. metres,
-- pieces). conversion_to_base says how many base units one of this unit equals
-- (Roll = 100 metres, Packet = 50 pieces, Metre = 1, Piece = 1).
CREATE TABLE IF NOT EXISTS product_units (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    unit_label VARCHAR(60) NOT NULL,          -- Roll, Metre, Packet, Piece
    conversion_to_base DECIMAL(15,3) NOT NULL DEFAULT 1,
    selling_price DECIMAL(15,2) NOT NULL DEFAULT 0,
    minimum_price DECIMAL(15,2) NOT NULL DEFAULT 0,
    is_base TINYINT(1) DEFAULT 0,             -- the smallest unit
    is_default TINYINT(1) DEFAULT 0,          -- default selection in POS
    allow_custom_length TINYINT(1) DEFAULT 0, -- e.g. cut-to-length rolls
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product (product_id)
) ENGINE=InnoDB;

-- ================================================
-- SYSTEM TABLES
-- ================================================

-- Soft-delete archive: full JSON snapshot of any deleted entity
CREATE TABLE IF NOT EXISTS deleted_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,         -- product, category, unit, user, sale
    entity_id INT NOT NULL,                   -- original primary key
    entity_label VARCHAR(255),                -- human readable name/order number
    data LONGTEXT,                            -- full JSON snapshot of the deleted row(s)
    deleted_by_id INT,                        -- user id who performed the delete
    deleted_by_name VARCHAR(150),             -- performer full name
    deleted_by_role VARCHAR(50),              -- performer role
    reason TEXT,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB;

-- Support messages (Help & Support contact form)
CREATE TABLE IF NOT EXISTS support_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    sender_name VARCHAR(150),
    sender_email VARCHAR(150),
    sender_role VARCHAR(50),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    category VARCHAR(60) DEFAULT 'general',
    status ENUM('new', 'read', 'resolved') DEFAULT 'new',
    emailed TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'success', 'warning', 'error') DEFAULT 'info',
    is_read TINYINT(1) DEFAULT 0,
    action_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read)
) ENGINE=InnoDB;

-- User activity log table
CREATE TABLE IF NOT EXISTS user_activity (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_date (created_at)
) ENGINE=InnoDB;

-- Company settings table
CREATE TABLE IF NOT EXISTS company_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type VARCHAR(50) DEFAULT 'string',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_key (setting_key)
) ENGINE=InnoDB;

-- Sessions table for login management
CREATE TABLE IF NOT EXISTS sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (session_token),
    INDEX idx_user (user_id),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB;

-- ================================================
-- VIEWS
-- ================================================

-- Cashier performance view
CREATE OR REPLACE VIEW cashier_performance AS
SELECT 
    u.id as user_id,
    u.full_name,
    u.username,
    u.role,
    COUNT(s.id) as total_sales,
    COALESCE(SUM(s.total), 0) as total_revenue,
    COALESCE(SUM(s.profit), 0) as total_profit,
    COALESCE(SUM(s.unexpected_profit), 0) as total_unexpected_profit,
    COALESCE(AVG(s.total), 0) as avg_order_value,
    COUNT(DISTINCT DATE(s.sale_date)) as days_worked,
    MAX(s.sale_date) as last_sale_date
FROM users u
LEFT JOIN sales s ON u.id = s.user_id
WHERE u.role IN ('Cashier', 'Inventory Manager', 'Manager', 'Admin', 'Super Admin')
GROUP BY u.id, u.full_name, u.username, u.role;

-- Low stock products view
CREATE OR REPLACE VIEW low_stock_products AS
SELECT 
    p.id,
    p.name,
    p.sku,
    p.current_stock,
    p.minimum_stock,
    p.selling_price,
    c.name as category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.current_stock <= p.minimum_stock AND p.status = 'active';

-- Daily sales summary view
CREATE OR REPLACE VIEW daily_sales_summary AS
SELECT 
    DATE(sale_date) as sale_day,
    COUNT(*) as total_orders,
    SUM(total) as total_revenue,
    SUM(profit) as total_profit,
    SUM(unexpected_profit) as total_unexpected_profit,
    SUM(CASE WHEN payment_method = 'cash' THEN total ELSE 0 END) as cash_sales,
    SUM(CASE WHEN payment_method = 'mobile' THEN total ELSE 0 END) as mobile_sales,
    SUM(CASE WHEN payment_status IN ('partial', 'pending') THEN amount_due ELSE 0 END) as total_debt
FROM sales
WHERE payment_status != 'cancelled'
GROUP BY DATE(sale_date)
ORDER BY sale_day DESC;

-- ================================================
-- DEFAULT SETTINGS
-- ================================================
-- Seed currency + support email so the app has sane defaults on a fresh install.
INSERT INTO company_settings (setting_key, setting_value, setting_type)
VALUES ('currency', 'KES', 'string')
ON DUPLICATE KEY UPDATE setting_key = setting_key;

INSERT INTO company_settings (setting_key, setting_value, setting_type)
VALUES ('support_email', '', 'string')
ON DUPLICATE KEY UPDATE setting_key = setting_key;

-- ================================================
-- END OF SCHEMA
-- ================================================
SELECT '========================================' AS '';
SELECT 'FLOWTIVE CENTRAL ERP DATABASE CREATED!' AS message;
SELECT '========================================' AS '';
SELECT 'Tables created: 17' AS info;
SELECT 'Views created: 3' AS info;
SELECT 'Next step: Run 002_sample_database.sql' AS info;
