-- ================================================
-- FLOWTIVE CENTRAL ERP - SUPABASE / POSTGRESQL SCHEMA
-- ================================================
-- Version: 3.1 - Full PostgreSQL-compatible schema
-- Converts from MySQL (001 + 003 migrations) to PostgreSQL.
-- Run this once on a fresh Supabase project.
-- ================================================

-- Enable UUID extension (for future use)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── Helper: auto-set updated_at on row update ────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ─── USERS ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id                   SERIAL PRIMARY KEY,
    username             VARCHAR(50)  NOT NULL UNIQUE,
    password             VARCHAR(255) NOT NULL,
    full_name            VARCHAR(100) NOT NULL,
    email                VARCHAR(100),
    mobile               VARCHAR(20),
    phone                VARCHAR(20),
    role                 VARCHAR(50)  NOT NULL DEFAULT 'Cashier'
                         CHECK (role IN ('Super Admin','Admin','Manager','Cashier','Inventory Manager')),
    modules              JSONB,
    profile_image        TEXT DEFAULT NULL,
    status               VARCHAR(20) DEFAULT 'active'
                         CHECK (status IN ('active','inactive','suspended')),
    force_password_reset SMALLINT NOT NULL DEFAULT 1,
    last_login           TIMESTAMP DEFAULT NULL,
    deleted_at           TIMESTAMP DEFAULT NULL,
    created_at           TIMESTAMP DEFAULT NOW(),
    updated_at           TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status   ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_role     ON users(role);
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── CATEGORIES ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    icon        VARCHAR(50)  DEFAULT 'fa-box',
    color       VARCHAR(20)  DEFAULT '#667eea',
    description TEXT,
    deleted_at  TIMESTAMP DEFAULT NULL,
    created_at  TIMESTAMP DEFAULT NOW(),
    updated_at  TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name);
CREATE TRIGGER trg_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── UNITS ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS units (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(50) NOT NULL,
    symbol       VARCHAR(20),
    abbreviation VARCHAR(20),
    type         VARCHAR(20) DEFAULT 'count'
                 CHECK (type IN ('count','weight','length','volume','area')),
    description  TEXT,
    deleted_at   TIMESTAMP DEFAULT NULL,
    created_at   TIMESTAMP DEFAULT NOW(),
    updated_at   TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_units_name ON units(name);
CREATE TRIGGER trg_units_updated_at BEFORE UPDATE ON units
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── PRODUCTS ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    id                     SERIAL PRIMARY KEY,
    name                   VARCHAR(200) NOT NULL,
    sku                    VARCHAR(50)  UNIQUE,
    barcode                VARCHAR(100),
    category_id            INT REFERENCES categories(id) ON DELETE SET NULL,
    unit_id                INT REFERENCES units(id) ON DELETE SET NULL,
    cost_price             NUMERIC(15,2) DEFAULT 0.00,
    selling_price          NUMERIC(15,2) DEFAULT 0.00,
    minimum_price          NUMERIC(15,2) DEFAULT 0.00,
    current_stock          NUMERIC(15,3) DEFAULT 0,
    stock_quantity         NUMERIC(15,3) DEFAULT 0,
    minimum_stock          NUMERIC(15,3) DEFAULT 0,
    low_stock_threshold    INT           DEFAULT 0,
    maximum_stock          INT           DEFAULT 0,
    has_multi_unit         SMALLINT      DEFAULT 0,
    base_unit_label        VARCHAR(60)   DEFAULT NULL,
    package_unit_label     VARCHAR(60)   DEFAULT NULL,
    package_size           NUMERIC(15,3) DEFAULT NULL,
    image                  TEXT,
    image_url              TEXT,
    image_path             VARCHAR(500)  DEFAULT NULL,
    description            TEXT,
    description_color      VARCHAR(50),
    description_size       VARCHAR(50),
    description_type       VARCHAR(100),
    description_dimensions VARCHAR(100),
    description_weight     VARCHAR(50),
    brand                  VARCHAR(100),
    supplier               VARCHAR(200),
    total_sold             INT           DEFAULT 0,
    last_restocked         TIMESTAMP     DEFAULT NULL,
    storage_location       VARCHAR(100),
    status                 VARCHAR(20)   DEFAULT 'active'
                           CHECK (status IN ('active','inactive','discontinued')),
    deleted_at             TIMESTAMP DEFAULT NULL,
    created_at             TIMESTAMP DEFAULT NOW(),
    updated_at             TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_products_name     ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_sku      ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_barcode  ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_status   ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_stock    ON products(current_stock);
CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── CUSTOMERS ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    id                 SERIAL PRIMARY KEY,
    name               VARCHAR(100) NOT NULL,
    mobile             VARCHAR(20),
    email              VARCHAR(100),
    address            TEXT,
    total_purchases    NUMERIC(15,2) DEFAULT 0.00,
    total_debt         NUMERIC(15,2) DEFAULT 0.00,
    last_purchase_date TIMESTAMP DEFAULT NULL,
    deleted_at         TIMESTAMP DEFAULT NULL,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_customers_name   ON customers(name);
CREATE INDEX IF NOT EXISTS idx_customers_mobile ON customers(mobile);
CREATE TRIGGER trg_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── SALES ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sales (
    id                SERIAL PRIMARY KEY,
    order_number      VARCHAR(50)   NOT NULL UNIQUE,
    parent_sale_id    INT           REFERENCES sales(id) ON DELETE SET NULL,
    sale_type         VARCHAR(20)   DEFAULT 'regular'
                      CHECK (sale_type IN ('regular','debt_followup')),
    customer_id       INT           REFERENCES customers(id) ON DELETE SET NULL,
    customer_name     VARCHAR(100),
    customer_mobile   VARCHAR(20),
    user_id           INT           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subtotal          NUMERIC(15,2) DEFAULT 0.00,
    tax               NUMERIC(15,2) DEFAULT 0.00,
    discount          NUMERIC(15,2) DEFAULT 0.00,
    total             NUMERIC(15,2) DEFAULT 0.00,
    profit            NUMERIC(15,2) DEFAULT 0.00,
    unexpected_profit NUMERIC(15,2) DEFAULT 0.00,
    payment_method    VARCHAR(20)   DEFAULT 'cash'
                      CHECK (payment_method IN ('cash','mobile','split','debt')),
    mpesa_code        VARCHAR(50),
    split_cash        NUMERIC(15,2) DEFAULT NULL,
    split_mobile      NUMERIC(15,2) DEFAULT NULL,
    payment_status    VARCHAR(20)   DEFAULT 'paid'
                      CHECK (payment_status IN ('paid','partial','pending','cancelled')),
    amount_paid       NUMERIC(15,2) DEFAULT 0.00,
    amount_due        NUMERIC(15,2) DEFAULT 0.00,
    notes             TEXT,
    sale_date         TIMESTAMP DEFAULT NOW(),
    created_at        TIMESTAMP DEFAULT NOW(),
    updated_at        TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_sales_order_number   ON sales(order_number);
CREATE INDEX IF NOT EXISTS idx_sales_date           ON sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_payment_status ON sales(payment_status);
CREATE INDEX IF NOT EXISTS idx_sales_user           ON sales(user_id);
CREATE INDEX IF NOT EXISTS idx_sales_user_date      ON sales(user_id, sale_date);
CREATE TRIGGER trg_sales_updated_at BEFORE UPDATE ON sales
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── SALE ITEMS ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sale_items (
    id                SERIAL PRIMARY KEY,
    sale_id           INT           NOT NULL REFERENCES sales(id)    ON DELETE CASCADE,
    product_id        INT           NOT NULL REFERENCES products(id)  ON DELETE CASCADE,
    product_name      VARCHAR(200)  NOT NULL,
    quantity          NUMERIC(15,3) NOT NULL,
    unit_label        VARCHAR(60)   DEFAULT NULL,
    base_quantity     NUMERIC(15,3) DEFAULT NULL,
    unit_price        NUMERIC(15,2) NOT NULL,
    cost_price        NUMERIC(15,2) DEFAULT 0.00,
    minimum_price     NUMERIC(15,2) DEFAULT 0.00,
    discount          NUMERIC(15,2) DEFAULT 0.00,
    total             NUMERIC(15,2) NOT NULL,
    profit            NUMERIC(15,2) DEFAULT 0.00,
    unexpected_profit NUMERIC(15,2) DEFAULT 0.00,
    created_at        TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale    ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product ON sale_items(product_id);

-- ─── STOCK MOVEMENTS ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS stock_movements (
    id             SERIAL PRIMARY KEY,
    product_id     INT           NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    product_name   VARCHAR(200)  NOT NULL,
    type           VARCHAR(20)   NOT NULL
                   CHECK (type IN ('purchase','sale','adjustment','return','damage','transfer')),
    quantity       NUMERIC(15,3) NOT NULL,
    previous_stock NUMERIC(15,3) NOT NULL,
    new_stock      NUMERIC(15,3) NOT NULL,
    user_id        INT           REFERENCES users(id) ON DELETE SET NULL,
    reference_id   INT,
    reference_type VARCHAR(50),
    reason         TEXT,
    movement_date  TIMESTAMP DEFAULT NOW(),
    created_at     TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_type    ON stock_movements(type);
CREATE INDEX IF NOT EXISTS idx_stock_movements_date    ON stock_movements(movement_date);

-- ─── DEBT MANAGEMENT ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS debt_orders (
    id           SERIAL PRIMARY KEY,
    sale_id      INT           NOT NULL REFERENCES sales(id)     ON DELETE CASCADE,
    customer_id  INT           NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    amount_due   NUMERIC(15,2) NOT NULL,
    amount_paid  NUMERIC(15,2) DEFAULT 0.00,
    due_date     DATE          NOT NULL,
    status       VARCHAR(20)   DEFAULT 'pending'
                 CHECK (status IN ('pending','partial','paid','overdue')),
    notes        TEXT,
    created_at   TIMESTAMP DEFAULT NOW(),
    updated_at   TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_debt_orders_customer ON debt_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_debt_orders_status   ON debt_orders(status);
CREATE INDEX IF NOT EXISTS idx_debt_orders_due_date ON debt_orders(due_date);
CREATE TRIGGER trg_debt_orders_updated_at BEFORE UPDATE ON debt_orders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS debt_payments (
    id             SERIAL PRIMARY KEY,
    debt_id        INT           NOT NULL REFERENCES debt_orders(id) ON DELETE CASCADE,
    sale_id        INT           REFERENCES sales(id) ON DELETE SET NULL,
    amount         NUMERIC(15,2) NOT NULL,
    payment_method VARCHAR(20)   DEFAULT 'cash'
                   CHECK (payment_method IN ('cash','mobile')),
    mpesa_code     VARCHAR(50),
    user_id        INT           REFERENCES users(id) ON DELETE SET NULL,
    notes          TEXT,
    payment_date   TIMESTAMP DEFAULT NOW(),
    created_at     TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_debt_payments_debt ON debt_payments(debt_id);

-- ─── MULTI-UNIT OF SALE ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_units (
    id                  SERIAL PRIMARY KEY,
    product_id          INT           NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    unit_label          VARCHAR(60)   NOT NULL,
    conversion_to_base  NUMERIC(15,3) NOT NULL DEFAULT 1,
    selling_price       NUMERIC(15,2) NOT NULL DEFAULT 0,
    minimum_price       NUMERIC(15,2) NOT NULL DEFAULT 0,
    is_base             SMALLINT      DEFAULT 0,
    is_default          SMALLINT      DEFAULT 0,
    allow_custom_length SMALLINT      DEFAULT 0,
    sort_order          INT           DEFAULT 0,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_product_units_product ON product_units(product_id);
CREATE TRIGGER trg_product_units_updated_at BEFORE UPDATE ON product_units
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── SYSTEM TABLES ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS deleted_items (
    id              SERIAL PRIMARY KEY,
    entity_type     VARCHAR(50)  NOT NULL,
    entity_id       INT          NOT NULL,
    entity_label    VARCHAR(255),
    data            TEXT,
    deleted_by_id   INT,
    deleted_by_name VARCHAR(150),
    deleted_by_role VARCHAR(50),
    reason          TEXT,
    deleted_at      TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_deleted_items_entity ON deleted_items(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_deleted_items_date   ON deleted_items(deleted_at);

CREATE TABLE IF NOT EXISTS support_messages (
    id           SERIAL PRIMARY KEY,
    user_id      INT,
    sender_name  VARCHAR(150),
    sender_email VARCHAR(150),
    sender_role  VARCHAR(50),
    subject      VARCHAR(255),
    message      TEXT NOT NULL,
    category     VARCHAR(60) DEFAULT 'general',
    status       VARCHAR(20) DEFAULT 'new'
                 CHECK (status IN ('new','read','resolved')),
    emailed      SMALLINT DEFAULT 0,
    created_at   TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_support_status  ON support_messages(status);
CREATE INDEX IF NOT EXISTS idx_support_created ON support_messages(created_at);

CREATE TABLE IF NOT EXISTS notifications (
    id         SERIAL PRIMARY KEY,
    user_id    INT REFERENCES users(id) ON DELETE CASCADE,
    title      VARCHAR(200) NOT NULL,
    message    TEXT NOT NULL,
    type       VARCHAR(20) DEFAULT 'info'
               CHECK (type IN ('info','success','warning','error')),
    is_read    SMALLINT DEFAULT 0,
    action_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);

CREATE TABLE IF NOT EXISTS user_activity (
    id          SERIAL PRIMARY KEY,
    user_id     INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action      VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address  VARCHAR(45),
    user_agent  TEXT,
    created_at  TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_user_activity_user   ON user_activity(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_action ON user_activity(action);
CREATE INDEX IF NOT EXISTS idx_user_activity_date   ON user_activity(created_at);

CREATE TABLE IF NOT EXISTS company_settings (
    id            SERIAL PRIMARY KEY,
    setting_key   VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type  VARCHAR(50) DEFAULT 'string',
    created_at    TIMESTAMP DEFAULT NOW(),
    updated_at    TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_company_settings_key ON company_settings(setting_key);
CREATE TRIGGER trg_company_settings_updated_at BEFORE UPDATE ON company_settings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS sessions (
    id            SERIAL PRIMARY KEY,
    user_id       INT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    ip_address    VARCHAR(45),
    user_agent    TEXT,
    expires_at    TIMESTAMP    NOT NULL,
    created_at    TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_sessions_token   ON sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_user    ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions(expires_at);

-- ─── SECURITY TABLES (v3.1) ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS password_resets (
    id         SERIAL PRIMARY KEY,
    user_id    INT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token      VARCHAR(64)  NOT NULL UNIQUE,
    expires_at TIMESTAMP    NOT NULL,
    used_at    TIMESTAMP    DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_password_resets_token   ON password_resets(token);
CREATE INDEX IF NOT EXISTS idx_password_resets_user    ON password_resets(user_id);
CREATE INDEX IF NOT EXISTS idx_password_resets_expires ON password_resets(expires_at);

CREATE TABLE IF NOT EXISTS login_attempts (
    id           SERIAL PRIMARY KEY,
    identifier   VARCHAR(150) NOT NULL,
    ip_address   VARCHAR(45)  NOT NULL,
    attempted_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_login_attempts_id   ON login_attempts(identifier, ip_address);
CREATE INDEX IF NOT EXISTS idx_login_attempts_time ON login_attempts(attempted_at);

-- ─── M-PESA TABLES (v3.1) ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS mpesa_transactions (
    id           SERIAL PRIMARY KEY,
    sale_id      INT REFERENCES sales(id) ON DELETE SET NULL,
    mpesa_code   VARCHAR(100),
    amount       NUMERIC(15,2),
    phone        VARCHAR(20),
    source       VARCHAR(30) DEFAULT 'manual'
                 CHECK (source IN ('manual','daraja','daraja_pending','daraja_failed')),
    confirmed_at TIMESTAMP DEFAULT NULL,
    created_at   TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_mpesa_sale   ON mpesa_transactions(sale_id);
CREATE INDEX IF NOT EXISTS idx_mpesa_code   ON mpesa_transactions(mpesa_code);
CREATE INDEX IF NOT EXISTS idx_mpesa_source ON mpesa_transactions(source);

-- ─── REFUNDS (v3.1) ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS refunds (
    id               SERIAL PRIMARY KEY,
    original_sale_id INT           NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    amount           NUMERIC(15,2) NOT NULL,
    reason           TEXT,
    refund_method    VARCHAR(20)   DEFAULT 'cash'
                     CHECK (refund_method IN ('cash','mobile','store_credit')),
    approved_by      INT REFERENCES users(id) ON DELETE SET NULL,
    requested_by     INT REFERENCES users(id) ON DELETE SET NULL,
    status           VARCHAR(20)   DEFAULT 'pending'
                     CHECK (status IN ('pending','approved','rejected','completed')),
    notes            TEXT,
    refund_date      TIMESTAMP DEFAULT NULL,
    created_at       TIMESTAMP DEFAULT NOW(),
    updated_at       TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_refunds_sale   ON refunds(original_sale_id);
CREATE INDEX IF NOT EXISTS idx_refunds_status ON refunds(status);
CREATE TRIGGER trg_refunds_updated_at BEFORE UPDATE ON refunds
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── PURCHASE ORDERS (v3.1) ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS purchase_orders (
    id                SERIAL PRIMARY KEY,
    po_number         VARCHAR(50)   NOT NULL UNIQUE,
    supplier_name     VARCHAR(200),
    supplier_contact  VARCHAR(100),
    delivery_address  TEXT,
    expected_delivery DATE,
    status            VARCHAR(20)   DEFAULT 'draft'
                      CHECK (status IN ('draft','sent','received','cancelled')),
    total_cost        NUMERIC(15,2) DEFAULT 0,
    notes             TEXT,
    created_by        INT REFERENCES users(id) ON DELETE SET NULL,
    created_at        TIMESTAMP DEFAULT NOW(),
    updated_at        TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_po_status    ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_po_number    ON purchase_orders(po_number);
CREATE TRIGGER trg_purchase_orders_updated_at BEFORE UPDATE ON purchase_orders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS purchase_order_items (
    id           SERIAL PRIMARY KEY,
    po_id        INT           NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id   INT           REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(200)  NOT NULL,
    quantity     NUMERIC(15,3) NOT NULL,
    unit_cost    NUMERIC(15,2) DEFAULT 0,
    total        NUMERIC(15,2) DEFAULT 0,
    notes        TEXT
);
CREATE INDEX IF NOT EXISTS idx_po_items_po ON purchase_order_items(po_id);

-- ─── VIEWS ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW cashier_performance AS
SELECT
    u.id              AS user_id,
    u.full_name,
    u.username,
    u.role,
    COUNT(s.id)                                  AS total_sales,
    COALESCE(SUM(s.total), 0)                    AS total_revenue,
    COALESCE(SUM(s.profit), 0)                   AS total_profit,
    COALESCE(SUM(s.unexpected_profit), 0)        AS total_unexpected_profit,
    COALESCE(AVG(s.total), 0)                    AS avg_order_value,
    COUNT(DISTINCT DATE(s.sale_date))             AS days_worked,
    MAX(s.sale_date)                              AS last_sale_date
FROM users u
LEFT JOIN sales s ON u.id = s.user_id
WHERE u.role IN ('Cashier','Inventory Manager','Manager','Admin','Super Admin')
GROUP BY u.id, u.full_name, u.username, u.role;

CREATE OR REPLACE VIEW low_stock_products AS
SELECT
    p.id,
    p.name,
    p.sku,
    p.current_stock,
    p.minimum_stock,
    p.selling_price,
    c.name AS category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.current_stock <= p.minimum_stock AND p.status = 'active';

CREATE OR REPLACE VIEW daily_sales_summary AS
SELECT
    DATE(sale_date)                                                              AS sale_day,
    COUNT(*)                                                                     AS total_orders,
    SUM(total)                                                                   AS total_revenue,
    SUM(profit)                                                                  AS total_profit,
    SUM(unexpected_profit)                                                       AS total_unexpected_profit,
    SUM(CASE WHEN payment_method = 'cash'   THEN total ELSE 0 END)              AS cash_sales,
    SUM(CASE WHEN payment_method = 'mobile' THEN total ELSE 0 END)              AS mobile_sales,
    SUM(CASE WHEN payment_status IN ('partial','pending') THEN amount_due ELSE 0 END) AS total_debt
FROM sales
WHERE payment_status != 'cancelled'
GROUP BY DATE(sale_date)
ORDER BY sale_day DESC;

-- ─── DEFAULT SETTINGS ─────────────────────────────────────────────────────────
INSERT INTO company_settings (setting_key, setting_value, setting_type)
VALUES
    ('currency',         'KES',    'string'),
    ('support_email',    '',       'string'),
    ('mpesa_enabled',    'manual', 'string'),
    ('mpesa_till_number','',       'string')
ON CONFLICT (setting_key) DO NOTHING;

-- ─── DEFAULT SUPER ADMIN ──────────────────────────────────────────────────────
-- Password: Admin@123 (bcrypt hash - user will be forced to reset on first login)
INSERT INTO users (username, password, full_name, role, modules, status, force_password_reset)
VALUES (
    'admin',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'System Administrator',
    'Super Admin',
    '["erp","pos","inventory"]',
    'active',
    1
) ON CONFLICT (username) DO NOTHING;

-- ─── DONE ────────────────────────────────────────────────────────────────────
-- Tables  : 23 (including v3.1 additions)
-- Views   : 3
-- Triggers: auto-updated_at on 10 tables
-- Run on Supabase SQL Editor: https://supabase.com/dashboard/project/<id>/sql
