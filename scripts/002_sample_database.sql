-- ================================================
-- FLOWTIVE ERP - COMPREHENSIVE SAMPLE DATABASE
-- 2 YEARS DATA (June 2024 - May 2026)
-- ================================================
-- Completely static SQL - no RAND(), no procedural generation
-- Compatible with all MySQL/MariaDB parsers including XAMPP
-- Shows business growth progression over 24 months
-- ================================================

USE flowtive_erp;

-- Clear existing sample data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE user_activity;
TRUNCATE TABLE notifications;
TRUNCATE TABLE support_messages;
TRUNCATE TABLE deleted_items;
TRUNCATE TABLE debt_payments;
TRUNCATE TABLE debt_orders;
TRUNCATE TABLE stock_movements;
TRUNCATE TABLE sale_items;
TRUNCATE TABLE sales;
TRUNCATE TABLE product_units;
TRUNCATE TABLE customers;
TRUNCATE TABLE products;
TRUNCATE TABLE units;
TRUNCATE TABLE categories;
TRUNCATE TABLE users;
TRUNCATE TABLE company_settings;
SET FOREIGN_KEY_CHECKS = 1;

-- ================================================
-- USERS - 8 users with all roles
-- ================================================
INSERT INTO users (username, password, full_name, email, mobile, phone, role, modules, status) VALUES
('superadmin', 'super123', 'Caleb Magaju', 'calebmagaju@lilyjoe.com', '+254707516393', '+254707516393', 'Super Admin', '["erp","pos","inventory"]', 'active'),
('admin', 'admin123', 'Sarah Njeri', 'sarah@lilyjoe.com', '+254700000002', '+254700000002', 'Admin', '["erp","pos","inventory"]', 'active'),
('manager', 'manage123', 'John Kamau', 'john@lilyjoe.com', '+254700000003', '+254700000003', 'Manager', '["erp","pos","inventory"]', 'active'),
('cashier1', 'cash123', 'Mary Wanjiku', 'mary@lilyjoe.com', '+254700000004', '+254700000004', 'Cashier', '["pos"]', 'active'),
('cashier2', 'cash123', 'Peter Omondi', 'peter@lilyjoe.com', '+254700000005', '+254700000005', 'Cashier', '["pos"]', 'active'),
('cashier3', 'cash123', 'Grace Achieng', 'grace@lilyjoe.com', '+254700000006', '+254700000006', 'Cashier', '["pos"]', 'active'),
('inventory1', 'invent123', 'David Otieno', 'david@lilyjoe.com', '+254700000007', '+254700000007', 'Inventory Manager', '["inventory"]', 'active'),
('inventory2', 'invent123', 'Jane Mutua', 'jane@lilyjoe.com', '+254700000008', '+254700000008', 'Inventory Manager', '["inventory","pos"]', 'active');

-- ================================================
-- COMPANY SETTINGS
-- ================================================
INSERT INTO company_settings (setting_key, setting_value, setting_type) VALUES
('company_name', 'LilyJoe Textiles', 'string'),
('company_address', 'Tom Mboya Street, Nairobi, Kenya', 'string'),
('company_mobile', '+254712345678', 'string'),
('company_email', 'info@lilyjoetextiles.com', 'string'),
('company_website', 'www.lilyjoetextiles.com', 'string'),
('tax_rate', '16', 'number'),
('currency', 'KES', 'string'),
('daily_target', '75000', 'number'),
('support_email', 'calebmagaju@lilyjoe.com', 'string'),
('receipt_footer', 'Thank you for your business!', 'string');

-- ================================================
-- CATEGORIES - 8 textile categories
-- ================================================
INSERT INTO categories (name, icon, color, product_count) VALUES
('Fabrics', 'fa-scroll', '#3b82f6', 0),
('Threads', 'fa-spool', '#10b981', 0),
('Zippers & Fasteners', 'fa-link', '#f59e0b', 0),
('Buttons & Accessories', 'fa-circle-dot', '#8b5cf6', 0),
('Elastic & Trim', 'fa-wave-square', '#ec4899', 0),
('Lining Materials', 'fa-layer-group', '#14b8a6', 0),
('Interfacing', 'fa-square', '#6366f1', 0),
('Patches & Embellishments', 'fa-star', '#f43f5e', 0);

-- ================================================
-- UNITS - 10 measurement units
-- ================================================
INSERT INTO units (name, symbol, products_using) VALUES
('Meters', 'm', 0),
('Yards', 'yd', 0),
('Pieces', 'pcs', 0),
('Rolls', 'roll', 0),
('Spools', 'spool', 0),
('Packets', 'pkt', 0),
('Dozens', 'dz', 0),
('Sets', 'set', 0),
('Kilograms', 'kg', 0),
('Boxes', 'box', 0);

-- ================================================
-- PRODUCTS - 44 products across all categories
-- ================================================
INSERT INTO products (name, category_id, unit_id, cost_price, selling_price, minimum_price, current_stock, minimum_stock, description, total_sold, last_restocked) VALUES
-- Fabrics (1-8)
('Cotton Plain White', 1, 1, 200.00, 250.00, 220.00, 450, 100, 'Premium quality plain white cotton fabric', 0, NOW()),
('Cotton Printed Floral', 1, 1, 220.00, 280.00, 240.00, 380, 80, 'Vibrant floral print cotton', 0, NOW()),
('Denim Classic Blue', 1, 1, 350.00, 450.00, 380.00, 280, 50, 'Heavy duty denim fabric', 0, NOW()),
('Silk Charmeuse White', 1, 1, 800.00, 1000.00, 850.00, 120, 30, 'Luxurious silk charmeuse', 0, NOW()),
('Polyester Satin', 1, 1, 180.00, 240.00, 200.00, 420, 100, 'Glossy polyester satin', 0, NOW()),
('Linen Natural Beige', 1, 1, 400.00, 520.00, 440.00, 220, 50, 'Natural linen fabric', 0, NOW()),
('Wool Blend Grey', 1, 1, 600.00, 780.00, 640.00, 150, 40, 'Warm wool blend fabric', 0, NOW()),
('Velvet Navy Blue', 1, 1, 450.00, 580.00, 480.00, 180, 40, 'Soft velvet fabric', 0, NOW()),
-- Threads (9-14)
('Cotton Thread White', 2, 5, 15.00, 25.00, 18.00, 800, 200, '100% cotton sewing thread', 0, NOW()),
('Cotton Thread Black', 2, 5, 15.00, 25.00, 18.00, 750, 200, '100% cotton sewing thread', 0, NOW()),
('Polyester Thread Assorted', 2, 5, 12.00, 20.00, 15.00, 650, 150, 'Multi-color polyester thread pack', 0, NOW()),
('Heavy Duty Thread', 2, 5, 20.00, 30.00, 22.00, 420, 100, 'Extra strong thread for denim', 0, NOW()),
('Embroidery Thread Gold', 2, 5, 35.00, 50.00, 38.00, 280, 80, 'Metallic embroidery thread', 0, NOW()),
('Silk Thread Premium', 2, 5, 45.00, 65.00, 48.00, 220, 60, 'Pure silk thread', 0, NOW()),
-- Zippers & Fasteners (15-20)
('Metal Zippers 20cm', 3, 3, 12.00, 20.00, 15.00, 850, 200, 'Durable metal zippers', 0, NOW()),
('Plastic Zippers 30cm', 3, 3, 8.00, 15.00, 10.00, 920, 250, 'Lightweight plastic zippers', 0, NOW()),
('Invisible Zippers', 3, 3, 15.00, 25.00, 18.00, 680, 150, 'Hidden zip for dresses', 0, NOW()),
('Two-Way Zippers', 3, 3, 25.00, 40.00, 28.00, 450, 100, 'Reversible zippers for jackets', 0, NOW()),
('Hook and Eye Sets', 3, 8, 5.00, 10.00, 6.00, 1200, 300, 'Metal hook and eye fasteners', 0, NOW()),
('Snap Fasteners', 3, 3, 3.00, 8.00, 4.00, 1500, 400, 'Press stud fasteners', 0, NOW()),
-- Buttons & Accessories (21-25)
('Plastic Buttons White', 4, 7, 20.00, 35.00, 22.00, 780, 150, '2-hole plastic buttons', 0, NOW()),
('Wooden Buttons Natural', 4, 7, 30.00, 50.00, 35.00, 520, 120, 'Eco-friendly wooden buttons', 0, NOW()),
('Metal Buttons Silver', 4, 7, 40.00, 65.00, 45.00, 420, 100, 'Elegant metal buttons', 0, NOW()),
('Decorative Beads', 4, 6, 80.00, 120.00, 90.00, 320, 80, 'Assorted decorative beads', 0, NOW()),
('Sequins Pack', 4, 6, 25.00, 40.00, 28.00, 480, 100, 'Shiny sequins for embellishment', 0, NOW()),
-- Elastic & Trim (26-30)
('Elastic Band 2cm', 5, 1, 25.00, 40.00, 28.00, 650, 150, 'Standard elastic band', 0, NOW()),
('Elastic Band 4cm', 5, 1, 35.00, 55.00, 38.00, 520, 120, 'Wide elastic band', 0, NOW()),
('Lace Trim White', 5, 1, 30.00, 50.00, 35.00, 420, 100, 'Delicate lace trim', 0, NOW()),
('Ribbon Satin Assorted', 5, 4, 15.00, 25.00, 18.00, 780, 200, 'Colorful satin ribbons', 0, NOW()),
('Bias Tape Cotton', 5, 4, 20.00, 35.00, 22.00, 620, 150, 'Cotton bias tape', 0, NOW()),
-- Lining Materials (31-33)
('Cotton Lining White', 6, 1, 120.00, 160.00, 130.00, 380, 80, 'Soft cotton lining', 0, NOW()),
('Polyester Lining Black', 6, 1, 100.00, 140.00, 110.00, 420, 100, 'Durable polyester lining', 0, NOW()),
('Satin Lining Ivory', 6, 1, 150.00, 200.00, 160.00, 280, 60, 'Smooth satin lining', 0, NOW()),
-- Interfacing (34-36)
('Fusible Interfacing Light', 7, 1, 80.00, 120.00, 90.00, 350, 80, 'Iron-on interfacing', 0, NOW()),
('Fusible Interfacing Heavy', 7, 1, 100.00, 150.00, 110.00, 280, 60, 'Heavy duty interfacing', 0, NOW()),
('Non-Fusible Interfacing', 7, 1, 70.00, 110.00, 80.00, 320, 70, 'Sew-in interfacing', 0, NOW()),
-- Patches & Embellishments (37-44)
('Iron-On Patches Assorted', 8, 3, 15.00, 30.00, 18.00, 620, 150, 'Fun iron-on patches', 0, NOW()),
('Rhinestone Strips', 8, 1, 80.00, 120.00, 90.00, 280, 60, 'Glamorous rhinestone trim', 0, NOW()),
('Embroidered Appliques', 8, 3, 40.00, 65.00, 45.00, 380, 100, 'Decorative embroidered patches', 0, NOW()),
('Fabric Paint Set', 8, 8, 120.00, 180.00, 130.00, 220, 50, 'Permanent fabric paint', 0, NOW()),
('Transfer Paper Pack', 8, 6, 60.00, 95.00, 65.00, 320, 80, 'Heat transfer paper', 0, NOW()),
('Embroidery Hoops Set', 8, 8, 150.00, 220.00, 170.00, 180, 40, 'Wooden embroidery hoops', 0, NOW()),
('Fabric Glue Tube', 8, 3, 50.00, 80.00, 55.00, 420, 100, 'Strong fabric adhesive', 0, NOW()),
('Needle Threader Pack', 8, 6, 25.00, 45.00, 30.00, 580, 120, 'Easy needle threading tool', 0, NOW());

-- ================================================
-- MULTI-UNIT OF SALE
-- ================================================
-- Convert 4 representative products to multi-unit selling. Stock is tracked in
-- BASE units; note the fractional metre stock to exercise DECIMAL quantities.
--   #1  Cotton Plain White  -> Metre (base) / Roll (50 m)   - cut-to-length
--   #3  Denim Classic Blue  -> Metre (base) / Roll (50 m)   - cut-to-length
--   #9  Cotton Thread White -> Spool (base) / Box (12 spools)
--   #15 Metal Zippers 20cm  -> Piece (base) / Packet (10 pcs)
UPDATE products SET has_multi_unit = 1, base_unit_label = 'Metre', package_unit_label = 'Roll', package_size = 50, current_stock = 447.5  WHERE id = 1;
UPDATE products SET has_multi_unit = 1, base_unit_label = 'Metre', package_unit_label = 'Roll', package_size = 50, current_stock = 277.25 WHERE id = 3;
UPDATE products SET has_multi_unit = 1, base_unit_label = 'Spool', package_unit_label = 'Box',  package_size = 12, current_stock = 800    WHERE id = 9;
UPDATE products SET has_multi_unit = 1, base_unit_label = 'Piece', package_unit_label = 'Packet', package_size = 10, current_stock = 850  WHERE id = 15;

-- product_units: one row per sellable unit. conversion_to_base = base units per unit.
-- is_base marks the smallest unit; is_default is the POS default selection.
INSERT INTO product_units (product_id, unit_label, conversion_to_base, selling_price, minimum_price, is_base, is_default, allow_custom_length, sort_order) VALUES
-- Cotton Plain White (#1): sold per metre (cut-to-length) or by the roll
(1, 'Metre', 1,  250.00,   220.00,   1, 1, 1, 0),
(1, 'Roll',  50, 12000.00, 11000.00, 0, 0, 0, 1),
-- Denim Classic Blue (#3)
(3, 'Metre', 1,  450.00,   380.00,   1, 1, 1, 0),
(3, 'Roll',  50, 21500.00, 19000.00, 0, 0, 0, 1),
-- Cotton Thread White (#9): sold per spool or by the box
(9, 'Spool', 1,  25.00,    18.00,    1, 1, 0, 0),
(9, 'Box',   12, 270.00,   240.00,   0, 0, 0, 1),
-- Metal Zippers 20cm (#15): sold per piece or by the packet
(15, 'Piece',  1,  20.00,  15.00,    1, 1, 0, 0),
(15, 'Packet', 10, 180.00, 160.00,   0, 0, 0, 1);

-- ================================================
-- CUSTOMERS - 15 customers
-- ================================================
INSERT INTO customers (name, mobile, email, address, total_purchases, total_debt, last_purchase_date) VALUES
('Walk-in Customer', '', '', '', 0, 0, NULL),
('John Mwangi', '+254712345678', 'john.m@email.com', 'Westlands, Nairobi', 0, 0, NULL),
('Jane Akinyi', '+254723456789', 'jane.a@email.com', 'Kilimani, Nairobi', 0, 0, NULL),
('Textile Mart Ltd', '+254734567890', 'info@textilemart.co.ke', 'Industrial Area, Nairobi', 0, 0, NULL),
('Fashion Hub Kenya', '+254745678901', 'orders@fashionhub.ke', 'Tom Mboya Street, Nairobi', 0, 0, NULL),
('Mary Wambui', '+254756789012', 'mary.w@email.com', 'Ngara, Nairobi', 0, 0, NULL),
('Peter Kamau', '+254767890123', 'peter.k@email.com', 'South B, Nairobi', 0, 0, NULL),
('Stitch & Style', '+254778901234', 'info@stitchstyle.com', 'River Road, Nairobi', 0, 0, NULL),
('Elegant Tailors', '+254789012345', 'elegant@tailors.ke', 'Moi Avenue, Nairobi', 0, 0, NULL),
('David Ochieng', '+254790123456', 'david.o@email.com', 'Embakasi, Nairobi', 0, 0, NULL),
('Grace Njeri', '+254701234567', 'grace.n@email.com', 'Kasarani, Nairobi', 0, 0, NULL),
('Mombasa Fabrics', '+254712345670', 'orders@mombasafabrics.com', 'Mombasa Road, Nairobi', 0, 0, NULL),
('Kisumu Textiles', '+254723456701', 'sales@kisumutextiles.com', 'CBD, Kisumu', 0, 0, NULL),
('Sarah Mutua', '+254734567012', 'sarah.m@email.com', 'Thika Road, Nairobi', 0, 0, NULL),
('Quick Stitch Tailors', '+254745670123', 'quickstitch@email.com', 'Gikomba, Nairobi', 0, 0, NULL);

-- ================================================
-- SALES - YEAR 1: JUNE 2024 - MAY 2025 (GROWTH PHASE)
-- ================================================

-- JUNE 2024 - Business Start (Lower Volume)
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202406050001', 1, 'Walk-in Customer', '', 4, 1200.00, 1200.00, 264.00, 0.00, 'cash', NULL, 'paid', 1200.00, 0.00, '2024-06-05 10:30:00'),
('202406080001', 2, 'John Mwangi', '+254712345678', 5, 2800.00, 2800.00, 616.00, 0.00, 'cash', NULL, 'paid', 2800.00, 0.00, '2024-06-08 14:15:00'),
('202406120001', 4, 'Textile Mart Ltd', '+254734567890', 6, 15000.00, 15000.00, 3300.00, 0.00, 'mobile', 'RA24001', 'paid', 15000.00, 0.00, '2024-06-12 11:00:00'),
('202406180001', 1, 'Walk-in Customer', '', 4, 980.00, 980.00, 215.60, 0.00, 'cash', NULL, 'paid', 980.00, 0.00, '2024-06-18 09:45:00'),
('202406220001', 3, 'Jane Akinyi', '+254723456789', 5, 3400.00, 3400.00, 748.00, 50.00, 'cash', NULL, 'paid', 3400.00, 0.00, '2024-06-22 15:30:00'),
('202406280001', 5, 'Fashion Hub Kenya', '+254745678901', 6, 22000.00, 22000.00, 4840.00, 0.00, 'mobile', 'RA24002', 'partial', 15000.00, 7000.00, '2024-06-28 10:15:00');

-- JULY 2024
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202407030001', 1, 'Walk-in Customer', '', 4, 1450.00, 1450.00, 319.00, 0.00, 'cash', NULL, 'paid', 1450.00, 0.00, '2024-07-03 11:20:00'),
('202407070001', 6, 'Mary Wambui', '+254756789012', 5, 4200.00, 4200.00, 924.00, -40.00, 'cash', NULL, 'paid', 4200.00, 0.00, '2024-07-07 13:45:00'),
('202407110001', 8, 'Stitch & Style', '+254778901234', 6, 28000.00, 28000.00, 6160.00, 0.00, 'mobile', 'RA24003', 'paid', 28000.00, 0.00, '2024-07-11 09:30:00'),
('202407150001', 1, 'Walk-in Customer', '', 4, 1680.00, 1680.00, 369.60, 0.00, 'cash', NULL, 'paid', 1680.00, 0.00, '2024-07-15 14:00:00'),
('202407190001', 7, 'Peter Kamau', '+254767890123', 5, 5600.00, 5600.00, 1232.00, 80.00, 'mobile', 'RA24004', 'paid', 5600.00, 0.00, '2024-07-19 10:45:00'),
('202407230001', 4, 'Textile Mart Ltd', '+254734567890', 6, 32000.00, 32000.00, 7040.00, 0.00, 'mobile', 'RA24005', 'paid', 32000.00, 0.00, '2024-07-23 11:15:00'),
('202407270001', 1, 'Walk-in Customer', '', 4, 2100.00, 2100.00, 462.00, 0.00, 'cash', NULL, 'paid', 2100.00, 0.00, '2024-07-27 16:00:00'),
('202407310001', 9, 'Elegant Tailors', '+254789012345', 5, 18000.00, 18000.00, 3960.00, 0.00, 'mobile', 'RA24006', 'partial', 12000.00, 6000.00, '2024-07-31 12:30:00');

-- AUGUST 2024
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202408040001', 2, 'John Mwangi', '+254712345678', 6, 3200.00, 3200.00, 704.00, 0.00, 'cash', NULL, 'paid', 3200.00, 0.00, '2024-08-04 10:00:00'),
('202408080001', 1, 'Walk-in Customer', '', 4, 1920.00, 1920.00, 422.40, 0.00, 'cash', NULL, 'paid', 1920.00, 0.00, '2024-08-08 14:30:00'),
('202408120001', 12, 'Mombasa Fabrics', '+254712345670', 5, 45000.00, 45000.00, 9900.00, 0.00, 'mobile', 'RA24007', 'paid', 45000.00, 0.00, '2024-08-12 09:15:00'),
('202408160001', 3, 'Jane Akinyi', '+254723456789', 6, 4800.00, 4800.00, 1056.00, 60.00, 'cash', NULL, 'paid', 4800.00, 0.00, '2024-08-16 11:45:00'),
('202408200001', 1, 'Walk-in Customer', '', 4, 2350.00, 2350.00, 517.00, 0.00, 'cash', NULL, 'paid', 2350.00, 0.00, '2024-08-20 13:00:00'),
('202408240001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 38000.00, 38000.00, 8360.00, 0.00, 'mobile', 'RA24008', 'paid', 38000.00, 0.00, '2024-08-24 10:30:00'),
('202408280001', 10, 'David Ochieng', '+254790123456', 6, 6200.00, 6200.00, 1364.00, -50.00, 'mobile', 'RA24009', 'paid', 6200.00, 0.00, '2024-08-28 15:15:00');

-- SEPTEMBER 2024
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202409020001', 1, 'Walk-in Customer', '', 4, 1780.00, 1780.00, 391.60, 0.00, 'cash', NULL, 'paid', 1780.00, 0.00, '2024-09-02 10:45:00'),
('202409060001', 8, 'Stitch & Style', '+254778901234', 5, 42000.00, 42000.00, 9240.00, 0.00, 'mobile', 'RA24010', 'paid', 42000.00, 0.00, '2024-09-06 11:30:00'),
('202409100001', 6, 'Mary Wambui', '+254756789012', 6, 5400.00, 5400.00, 1188.00, 70.00, 'cash', NULL, 'paid', 5400.00, 0.00, '2024-09-10 14:00:00'),
('202409140001', 1, 'Walk-in Customer', '', 4, 2680.00, 2680.00, 589.60, 0.00, 'cash', NULL, 'paid', 2680.00, 0.00, '2024-09-14 09:30:00'),
('202409180001', 13, 'Kisumu Textiles', '+254723456701', 5, 35000.00, 35000.00, 7700.00, 0.00, 'mobile', 'RA24011', 'partial', 25000.00, 10000.00, '2024-09-18 12:15:00'),
('202409220001', 11, 'Grace Njeri', '+254701234567', 6, 4600.00, 4600.00, 1012.00, 0.00, 'cash', NULL, 'paid', 4600.00, 0.00, '2024-09-22 15:45:00'),
('202409260001', 4, 'Textile Mart Ltd', '+254734567890', 4, 48000.00, 48000.00, 10560.00, 0.00, 'mobile', 'RA24012', 'paid', 48000.00, 0.00, '2024-09-26 10:00:00'),
('202409300001', 1, 'Walk-in Customer', '', 5, 2100.00, 2100.00, 462.00, 0.00, 'cash', NULL, 'paid', 2100.00, 0.00, '2024-09-30 13:30:00');

-- OCTOBER 2024
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202410040001', 7, 'Peter Kamau', '+254767890123', 6, 6800.00, 6800.00, 1496.00, 90.00, 'mobile', 'RA24013', 'paid', 6800.00, 0.00, '2024-10-04 11:00:00'),
('202410080001', 1, 'Walk-in Customer', '', 4, 2450.00, 2450.00, 539.00, 0.00, 'cash', NULL, 'paid', 2450.00, 0.00, '2024-10-08 14:15:00'),
('202410120001', 9, 'Elegant Tailors', '+254789012345', 5, 32000.00, 32000.00, 7040.00, 0.00, 'mobile', 'RA24014', 'paid', 32000.00, 0.00, '2024-10-12 09:45:00'),
('202410160001', 2, 'John Mwangi', '+254712345678', 6, 4200.00, 4200.00, 924.00, 0.00, 'cash', NULL, 'paid', 4200.00, 0.00, '2024-10-16 12:30:00'),
('202410200001', 1, 'Walk-in Customer', '', 4, 1960.00, 1960.00, 431.20, 0.00, 'cash', NULL, 'paid', 1960.00, 0.00, '2024-10-20 10:15:00'),
('202410240001', 12, 'Mombasa Fabrics', '+254712345670', 5, 52000.00, 52000.00, 11440.00, 0.00, 'mobile', 'RA24015', 'paid', 52000.00, 0.00, '2024-10-24 11:45:00'),
('202410280001', 3, 'Jane Akinyi', '+254723456789', 6, 5200.00, 5200.00, 1144.00, -60.00, 'cash', NULL, 'paid', 5200.00, 0.00, '2024-10-28 15:00:00');

-- NOVEMBER 2024
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202411020001', 1, 'Walk-in Customer', '', 4, 2780.00, 2780.00, 611.60, 0.00, 'cash', NULL, 'paid', 2780.00, 0.00, '2024-11-02 10:30:00'),
('202411060001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 58000.00, 58000.00, 12760.00, 0.00, 'mobile', 'RA24016', 'paid', 58000.00, 0.00, '2024-11-06 09:15:00'),
('202411100001', 14, 'Sarah Mutua', '+254734567012', 6, 7200.00, 7200.00, 1584.00, 100.00, 'mobile', 'RA24017', 'paid', 7200.00, 0.00, '2024-11-10 13:45:00'),
('202411140001', 1, 'Walk-in Customer', '', 4, 3100.00, 3100.00, 682.00, 0.00, 'cash', NULL, 'paid', 3100.00, 0.00, '2024-11-14 11:00:00'),
('202411180001', 8, 'Stitch & Style', '+254778901234', 5, 48000.00, 48000.00, 10560.00, 0.00, 'mobile', 'RA24018', 'partial', 35000.00, 13000.00, '2024-11-18 14:30:00'),
('202411220001', 10, 'David Ochieng', '+254790123456', 6, 5800.00, 5800.00, 1276.00, 0.00, 'cash', NULL, 'paid', 5800.00, 0.00, '2024-11-22 10:45:00'),
('202411260001', 4, 'Textile Mart Ltd', '+254734567890', 4, 62000.00, 62000.00, 13640.00, 0.00, 'mobile', 'RA24019', 'paid', 62000.00, 0.00, '2024-11-26 12:15:00'),
('202411300001', 1, 'Walk-in Customer', '', 5, 2450.00, 2450.00, 539.00, 0.00, 'cash', NULL, 'paid', 2450.00, 0.00, '2024-11-30 15:30:00');

-- DECEMBER 2024 (Peak Season)
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202412020001', 6, 'Mary Wambui', '+254756789012', 6, 8200.00, 8200.00, 1804.00, 120.00, 'mobile', 'RA24020', 'paid', 8200.00, 0.00, '2024-12-02 09:30:00'),
('202412040001', 1, 'Walk-in Customer', '', 4, 3800.00, 3800.00, 836.00, 0.00, 'cash', NULL, 'paid', 3800.00, 0.00, '2024-12-04 11:15:00'),
('202412060001', 12, 'Mombasa Fabrics', '+254712345670', 5, 75000.00, 75000.00, 16500.00, 0.00, 'mobile', 'RA24021', 'paid', 75000.00, 0.00, '2024-12-06 10:00:00'),
('202412080001', 3, 'Jane Akinyi', '+254723456789', 6, 6400.00, 6400.00, 1408.00, 80.00, 'cash', NULL, 'paid', 6400.00, 0.00, '2024-12-08 14:45:00'),
('202412100001', 1, 'Walk-in Customer', '', 4, 4200.00, 4200.00, 924.00, 0.00, 'cash', NULL, 'paid', 4200.00, 0.00, '2024-12-10 12:30:00'),
('202412120001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 85000.00, 85000.00, 18700.00, 0.00, 'mobile', 'RA24022', 'paid', 85000.00, 0.00, '2024-12-12 09:15:00'),
('202412140001', 9, 'Elegant Tailors', '+254789012345', 6, 42000.00, 42000.00, 9240.00, 0.00, 'mobile', 'RA24023', 'paid', 42000.00, 0.00, '2024-12-14 11:45:00'),
('202412160001', 1, 'Walk-in Customer', '', 4, 5100.00, 5100.00, 1122.00, 0.00, 'cash', NULL, 'paid', 5100.00, 0.00, '2024-12-16 13:00:00'),
('202412180001', 7, 'Peter Kamau', '+254767890123', 5, 9200.00, 9200.00, 2024.00, 150.00, 'mobile', 'RA24024', 'paid', 9200.00, 0.00, '2024-12-18 10:30:00'),
('202412200001', 13, 'Kisumu Textiles', '+254723456701', 6, 68000.00, 68000.00, 14960.00, 0.00, 'mobile', 'RA24025', 'partial', 50000.00, 18000.00, '2024-12-20 14:15:00'),
('202412220001', 1, 'Walk-in Customer', '', 4, 4800.00, 4800.00, 1056.00, 0.00, 'cash', NULL, 'paid', 4800.00, 0.00, '2024-12-22 11:00:00'),
('202412240001', 8, 'Stitch & Style', '+254778901234', 5, 55000.00, 55000.00, 12100.00, 0.00, 'mobile', 'RA24026', 'paid', 55000.00, 0.00, '2024-12-24 09:45:00'),
('202412260001', 2, 'John Mwangi', '+254712345678', 6, 5600.00, 5600.00, 1232.00, 0.00, 'cash', NULL, 'paid', 5600.00, 0.00, '2024-12-26 15:30:00'),
('202412280001', 15, 'Quick Stitch Tailors', '+254745670123', 4, 38000.00, 38000.00, 8360.00, 0.00, 'mobile', 'RA24027', 'paid', 38000.00, 0.00, '2024-12-28 12:00:00'),
('202412300001', 1, 'Walk-in Customer', '', 5, 3200.00, 3200.00, 704.00, 0.00, 'cash', NULL, 'paid', 3200.00, 0.00, '2024-12-30 10:15:00');

-- JANUARY 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202501030001', 4, 'Textile Mart Ltd', '+254734567890', 6, 52000.00, 52000.00, 11440.00, 0.00, 'mobile', 'RA25001', 'paid', 52000.00, 0.00, '2025-01-03 09:30:00'),
('202501060001', 1, 'Walk-in Customer', '', 4, 2850.00, 2850.00, 627.00, 0.00, 'cash', NULL, 'paid', 2850.00, 0.00, '2025-01-06 11:00:00'),
('202501090001', 11, 'Grace Njeri', '+254701234567', 5, 6800.00, 6800.00, 1496.00, 90.00, 'mobile', 'RA25002', 'paid', 6800.00, 0.00, '2025-01-09 14:15:00'),
('202501120001', 5, 'Fashion Hub Kenya', '+254745678901', 6, 48000.00, 48000.00, 10560.00, 0.00, 'mobile', 'RA25003', 'partial', 30000.00, 18000.00, '2025-01-12 10:45:00'),
('202501150001', 1, 'Walk-in Customer', '', 4, 3400.00, 3400.00, 748.00, 0.00, 'cash', NULL, 'paid', 3400.00, 0.00, '2025-01-15 13:30:00'),
('202501180001', 9, 'Elegant Tailors', '+254789012345', 5, 35000.00, 35000.00, 7700.00, 0.00, 'mobile', 'RA25004', 'paid', 35000.00, 0.00, '2025-01-18 09:15:00'),
('202501210001', 3, 'Jane Akinyi', '+254723456789', 6, 5200.00, 5200.00, 1144.00, -40.00, 'cash', NULL, 'paid', 5200.00, 0.00, '2025-01-21 15:00:00'),
('202501240001', 12, 'Mombasa Fabrics', '+254712345670', 4, 62000.00, 62000.00, 13640.00, 0.00, 'mobile', 'RA25005', 'paid', 62000.00, 0.00, '2025-01-24 11:30:00'),
('202501270001', 1, 'Walk-in Customer', '', 5, 2680.00, 2680.00, 589.60, 0.00, 'cash', NULL, 'paid', 2680.00, 0.00, '2025-01-27 12:45:00'),
('202501300001', 8, 'Stitch & Style', '+254778901234', 6, 45000.00, 45000.00, 9900.00, 0.00, 'mobile', 'RA25006', 'paid', 45000.00, 0.00, '2025-01-30 10:00:00');

-- FEBRUARY 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202502020001', 6, 'Mary Wambui', '+254756789012', 4, 7400.00, 7400.00, 1628.00, 100.00, 'mobile', 'RA25007', 'paid', 7400.00, 0.00, '2025-02-02 09:45:00'),
('202502050001', 1, 'Walk-in Customer', '', 5, 3100.00, 3100.00, 682.00, 0.00, 'cash', NULL, 'paid', 3100.00, 0.00, '2025-02-05 11:15:00'),
('202502080001', 4, 'Textile Mart Ltd', '+254734567890', 6, 58000.00, 58000.00, 12760.00, 0.00, 'mobile', 'RA25008', 'paid', 58000.00, 0.00, '2025-02-08 14:00:00'),
('202502110001', 7, 'Peter Kamau', '+254767890123', 4, 8200.00, 8200.00, 1804.00, 120.00, 'mobile', 'RA25009', 'paid', 8200.00, 0.00, '2025-02-11 10:30:00'),
('202502140001', 1, 'Walk-in Customer', '', 5, 4200.00, 4200.00, 924.00, 0.00, 'cash', NULL, 'paid', 4200.00, 0.00, '2025-02-14 13:45:00'),
('202502170001', 13, 'Kisumu Textiles', '+254723456701', 6, 42000.00, 42000.00, 9240.00, 0.00, 'mobile', 'RA25010', 'partial', 30000.00, 12000.00, '2025-02-17 09:00:00'),
('202502200001', 10, 'David Ochieng', '+254790123456', 4, 6200.00, 6200.00, 1364.00, -50.00, 'cash', NULL, 'paid', 6200.00, 0.00, '2025-02-20 15:30:00'),
('202502230001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 72000.00, 72000.00, 15840.00, 0.00, 'mobile', 'RA25011', 'paid', 72000.00, 0.00, '2025-02-23 11:00:00'),
('202502260001', 1, 'Walk-in Customer', '', 6, 2950.00, 2950.00, 649.00, 0.00, 'cash', NULL, 'paid', 2950.00, 0.00, '2025-02-26 12:15:00');

-- MARCH 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202503020001', 9, 'Elegant Tailors', '+254789012345', 4, 38000.00, 38000.00, 8360.00, 0.00, 'mobile', 'RA25012', 'paid', 38000.00, 0.00, '2025-03-02 10:15:00'),
('202503050001', 2, 'John Mwangi', '+254712345678', 5, 5400.00, 5400.00, 1188.00, 70.00, 'cash', NULL, 'paid', 5400.00, 0.00, '2025-03-05 14:30:00'),
('202503080001', 1, 'Walk-in Customer', '', 6, 3600.00, 3600.00, 792.00, 0.00, 'cash', NULL, 'paid', 3600.00, 0.00, '2025-03-08 11:45:00'),
('202503110001', 12, 'Mombasa Fabrics', '+254712345670', 4, 68000.00, 68000.00, 14960.00, 0.00, 'mobile', 'RA25013', 'paid', 68000.00, 0.00, '2025-03-11 09:30:00'),
('202503140001', 14, 'Sarah Mutua', '+254734567012', 5, 7800.00, 7800.00, 1716.00, 90.00, 'mobile', 'RA25014', 'paid', 7800.00, 0.00, '2025-03-14 13:00:00'),
('202503170001', 1, 'Walk-in Customer', '', 6, 4100.00, 4100.00, 902.00, 0.00, 'cash', NULL, 'paid', 4100.00, 0.00, '2025-03-17 10:45:00'),
('202503200001', 8, 'Stitch & Style', '+254778901234', 4, 55000.00, 55000.00, 12100.00, 0.00, 'mobile', 'RA25015', 'partial', 40000.00, 15000.00, '2025-03-20 15:15:00'),
('202503230001', 3, 'Jane Akinyi', '+254723456789', 5, 6000.00, 6000.00, 1320.00, -30.00, 'cash', NULL, 'paid', 6000.00, 0.00, '2025-03-23 11:30:00'),
('202503260001', 4, 'Textile Mart Ltd', '+254734567890', 6, 75000.00, 75000.00, 16500.00, 0.00, 'mobile', 'RA25016', 'paid', 75000.00, 0.00, '2025-03-26 09:00:00'),
('202503290001', 1, 'Walk-in Customer', '', 4, 3200.00, 3200.00, 704.00, 0.00, 'cash', NULL, 'paid', 3200.00, 0.00, '2025-03-29 14:00:00');

-- APRIL 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202504010001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 62000.00, 62000.00, 13640.00, 0.00, 'mobile', 'RA25017', 'paid', 62000.00, 0.00, '2025-04-01 10:30:00'),
('202504040001', 1, 'Walk-in Customer', '', 6, 3800.00, 3800.00, 836.00, 0.00, 'cash', NULL, 'paid', 3800.00, 0.00, '2025-04-04 12:15:00'),
('202504070001', 11, 'Grace Njeri', '+254701234567', 4, 7600.00, 7600.00, 1672.00, 80.00, 'mobile', 'RA25018', 'paid', 7600.00, 0.00, '2025-04-07 09:45:00'),
('202504100001', 9, 'Elegant Tailors', '+254789012345', 5, 42000.00, 42000.00, 9240.00, 0.00, 'mobile', 'RA25019', 'paid', 42000.00, 0.00, '2025-04-10 14:00:00'),
('202504130001', 1, 'Walk-in Customer', '', 6, 4500.00, 4500.00, 990.00, 0.00, 'cash', NULL, 'paid', 4500.00, 0.00, '2025-04-13 11:30:00'),
('202504160001', 15, 'Quick Stitch Tailors', '+254745670123', 4, 35000.00, 35000.00, 7700.00, 0.00, 'mobile', 'RA25020', 'partial', 25000.00, 10000.00, '2025-04-16 10:15:00'),
('202504190001', 6, 'Mary Wambui', '+254756789012', 5, 8400.00, 8400.00, 1848.00, 110.00, 'mobile', 'RA25021', 'paid', 8400.00, 0.00, '2025-04-19 13:45:00'),
('202504220001', 12, 'Mombasa Fabrics', '+254712345670', 6, 78000.00, 78000.00, 17160.00, 0.00, 'mobile', 'RA25022', 'paid', 78000.00, 0.00, '2025-04-22 09:30:00'),
('202504250001', 1, 'Walk-in Customer', '', 4, 3400.00, 3400.00, 748.00, 0.00, 'cash', NULL, 'paid', 3400.00, 0.00, '2025-04-25 15:00:00'),
('202504280001', 7, 'Peter Kamau', '+254767890123', 5, 9000.00, 9000.00, 1980.00, 130.00, 'mobile', 'RA25023', 'paid', 9000.00, 0.00, '2025-04-28 11:45:00');

-- MAY 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202505020001', 4, 'Textile Mart Ltd', '+254734567890', 6, 68000.00, 68000.00, 14960.00, 0.00, 'mobile', 'RA25024', 'paid', 68000.00, 0.00, '2025-05-02 10:00:00'),
('202505050001', 1, 'Walk-in Customer', '', 4, 4200.00, 4200.00, 924.00, 0.00, 'cash', NULL, 'paid', 4200.00, 0.00, '2025-05-05 12:30:00'),
('202505080001', 8, 'Stitch & Style', '+254778901234', 5, 52000.00, 52000.00, 11440.00, 0.00, 'mobile', 'RA25025', 'paid', 52000.00, 0.00, '2025-05-08 09:15:00'),
('202505110001', 3, 'Jane Akinyi', '+254723456789', 6, 6800.00, 6800.00, 1496.00, -40.00, 'cash', NULL, 'paid', 6800.00, 0.00, '2025-05-11 14:45:00'),
('202505140001', 1, 'Walk-in Customer', '', 4, 3600.00, 3600.00, 792.00, 0.00, 'cash', NULL, 'paid', 3600.00, 0.00, '2025-05-14 11:00:00'),
('202505170001', 13, 'Kisumu Textiles', '+254723456701', 5, 58000.00, 58000.00, 12760.00, 0.00, 'mobile', 'RA25026', 'paid', 58000.00, 0.00, '2025-05-17 10:30:00'),
('202505200001', 10, 'David Ochieng', '+254790123456', 6, 7200.00, 7200.00, 1584.00, 70.00, 'mobile', 'RA25027', 'paid', 7200.00, 0.00, '2025-05-20 13:15:00'),
('202505230001', 5, 'Fashion Hub Kenya', '+254745678901', 4, 85000.00, 85000.00, 18700.00, 0.00, 'mobile', 'RA25028', 'partial', 60000.00, 25000.00, '2025-05-23 09:45:00'),
('202505260001', 1, 'Walk-in Customer', '', 5, 4800.00, 4800.00, 1056.00, 0.00, 'cash', NULL, 'paid', 4800.00, 0.00, '2025-05-26 15:30:00'),
('202505290001', 9, 'Elegant Tailors', '+254789012345', 6, 45000.00, 45000.00, 9900.00, 0.00, 'mobile', 'RA25029', 'paid', 45000.00, 0.00, '2025-05-29 11:15:00');

-- ================================================
-- SALES - YEAR 2: JUNE 2025 - MAY 2026 (ESTABLISHED PHASE - HIGHER VOLUMES)
-- ================================================

-- JUNE 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202506020001', 12, 'Mombasa Fabrics', '+254712345670', 4, 72000.00, 72000.00, 15840.00, 0.00, 'mobile', 'RA25030', 'paid', 72000.00, 0.00, '2025-06-02 09:30:00'),
('202506040001', 1, 'Walk-in Customer', '', 5, 4600.00, 4600.00, 1012.00, 0.00, 'cash', NULL, 'paid', 4600.00, 0.00, '2025-06-04 11:45:00'),
('202506060001', 6, 'Mary Wambui', '+254756789012', 6, 9200.00, 9200.00, 2024.00, 120.00, 'mobile', 'RA25031', 'paid', 9200.00, 0.00, '2025-06-06 14:00:00'),
('202506090001', 4, 'Textile Mart Ltd', '+254734567890', 4, 82000.00, 82000.00, 18040.00, 0.00, 'mobile', 'RA25032', 'paid', 82000.00, 0.00, '2025-06-09 10:15:00'),
('202506110001', 1, 'Walk-in Customer', '', 5, 5200.00, 5200.00, 1144.00, 0.00, 'cash', NULL, 'paid', 5200.00, 0.00, '2025-06-11 12:30:00'),
('202506130001', 8, 'Stitch & Style', '+254778901234', 6, 62000.00, 62000.00, 13640.00, 0.00, 'mobile', 'RA25033', 'partial', 45000.00, 17000.00, '2025-06-13 09:00:00'),
('202506160001', 2, 'John Mwangi', '+254712345678', 4, 6400.00, 6400.00, 1408.00, 80.00, 'cash', NULL, 'paid', 6400.00, 0.00, '2025-06-16 15:15:00'),
('202506180001', 15, 'Quick Stitch Tailors', '+254745670123', 5, 42000.00, 42000.00, 9240.00, 0.00, 'mobile', 'RA25034', 'paid', 42000.00, 0.00, '2025-06-18 11:00:00'),
('202506200001', 1, 'Walk-in Customer', '', 6, 3800.00, 3800.00, 836.00, 0.00, 'cash', NULL, 'paid', 3800.00, 0.00, '2025-06-20 13:45:00'),
('202506230001', 5, 'Fashion Hub Kenya', '+254745678901', 4, 78000.00, 78000.00, 17160.00, 0.00, 'mobile', 'RA25035', 'paid', 78000.00, 0.00, '2025-06-23 10:30:00'),
('202506250001', 11, 'Grace Njeri', '+254701234567', 5, 8600.00, 8600.00, 1892.00, 100.00, 'mobile', 'RA25036', 'paid', 8600.00, 0.00, '2025-06-25 14:15:00'),
('202506280001', 9, 'Elegant Tailors', '+254789012345', 6, 55000.00, 55000.00, 12100.00, 0.00, 'mobile', 'RA25037', 'paid', 55000.00, 0.00, '2025-06-28 09:45:00'),
('202506300001', 1, 'Walk-in Customer', '', 4, 4200.00, 4200.00, 924.00, 0.00, 'cash', NULL, 'paid', 4200.00, 0.00, '2025-06-30 12:00:00');

-- JULY 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202507030001', 13, 'Kisumu Textiles', '+254723456701', 5, 65000.00, 65000.00, 14300.00, 0.00, 'mobile', 'RA25038', 'paid', 65000.00, 0.00, '2025-07-03 10:00:00'),
('202507050001', 1, 'Walk-in Customer', '', 6, 5400.00, 5400.00, 1188.00, 0.00, 'cash', NULL, 'paid', 5400.00, 0.00, '2025-07-05 11:30:00'),
('202507080001', 7, 'Peter Kamau', '+254767890123', 4, 10200.00, 10200.00, 2244.00, 140.00, 'mobile', 'RA25039', 'paid', 10200.00, 0.00, '2025-07-08 14:45:00'),
('202507100001', 4, 'Textile Mart Ltd', '+254734567890', 5, 88000.00, 88000.00, 19360.00, 0.00, 'mobile', 'RA25040', 'paid', 88000.00, 0.00, '2025-07-10 09:15:00'),
('202507120001', 1, 'Walk-in Customer', '', 6, 4800.00, 4800.00, 1056.00, 0.00, 'cash', NULL, 'paid', 4800.00, 0.00, '2025-07-12 12:00:00'),
('202507150001', 3, 'Jane Akinyi', '+254723456789', 4, 7400.00, 7400.00, 1628.00, -50.00, 'cash', NULL, 'paid', 7400.00, 0.00, '2025-07-15 15:30:00'),
('202507170001', 12, 'Mombasa Fabrics', '+254712345670', 5, 92000.00, 92000.00, 20240.00, 0.00, 'mobile', 'RA25041', 'partial', 70000.00, 22000.00, '2025-07-17 10:45:00'),
('202507200001', 1, 'Walk-in Customer', '', 6, 5800.00, 5800.00, 1276.00, 0.00, 'cash', NULL, 'paid', 5800.00, 0.00, '2025-07-20 11:15:00'),
('202507220001', 8, 'Stitch & Style', '+254778901234', 4, 68000.00, 68000.00, 14960.00, 0.00, 'mobile', 'RA25042', 'paid', 68000.00, 0.00, '2025-07-22 09:30:00'),
('202507250001', 14, 'Sarah Mutua', '+254734567012', 5, 9400.00, 9400.00, 2068.00, 110.00, 'mobile', 'RA25043', 'paid', 9400.00, 0.00, '2025-07-25 14:00:00'),
('202507280001', 5, 'Fashion Hub Kenya', '+254745678901', 6, 85000.00, 85000.00, 18700.00, 0.00, 'mobile', 'RA25044', 'paid', 85000.00, 0.00, '2025-07-28 10:30:00'),
('202507300001', 1, 'Walk-in Customer', '', 4, 4600.00, 4600.00, 1012.00, 0.00, 'cash', NULL, 'paid', 4600.00, 0.00, '2025-07-30 13:15:00');

-- AUGUST 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202508020001', 9, 'Elegant Tailors', '+254789012345', 5, 52000.00, 52000.00, 11440.00, 0.00, 'mobile', 'RA25045', 'paid', 52000.00, 0.00, '2025-08-02 09:45:00'),
('202508050001', 1, 'Walk-in Customer', '', 6, 6200.00, 6200.00, 1364.00, 0.00, 'cash', NULL, 'paid', 6200.00, 0.00, '2025-08-05 11:00:00'),
('202508070001', 6, 'Mary Wambui', '+254756789012', 4, 10800.00, 10800.00, 2376.00, 130.00, 'mobile', 'RA25046', 'paid', 10800.00, 0.00, '2025-08-07 14:30:00'),
('202508100001', 4, 'Textile Mart Ltd', '+254734567890', 5, 95000.00, 95000.00, 20900.00, 0.00, 'mobile', 'RA25047', 'paid', 95000.00, 0.00, '2025-08-10 10:15:00'),
('202508120001', 1, 'Walk-in Customer', '', 6, 5200.00, 5200.00, 1144.00, 0.00, 'cash', NULL, 'paid', 5200.00, 0.00, '2025-08-12 12:45:00'),
('202508150001', 10, 'David Ochieng', '+254790123456', 4, 8400.00, 8400.00, 1848.00, -60.00, 'mobile', 'RA25048', 'paid', 8400.00, 0.00, '2025-08-15 09:30:00'),
('202508180001', 15, 'Quick Stitch Tailors', '+254745670123', 5, 48000.00, 48000.00, 10560.00, 0.00, 'mobile', 'RA25049', 'partial', 35000.00, 13000.00, '2025-08-18 15:00:00'),
('202508200001', 1, 'Walk-in Customer', '', 6, 4400.00, 4400.00, 968.00, 0.00, 'cash', NULL, 'paid', 4400.00, 0.00, '2025-08-20 11:30:00'),
('202508230001', 13, 'Kisumu Textiles', '+254723456701', 4, 72000.00, 72000.00, 15840.00, 0.00, 'mobile', 'RA25050', 'paid', 72000.00, 0.00, '2025-08-23 10:00:00'),
('202508250001', 2, 'John Mwangi', '+254712345678', 5, 7200.00, 7200.00, 1584.00, 90.00, 'cash', NULL, 'paid', 7200.00, 0.00, '2025-08-25 14:15:00'),
('202508280001', 8, 'Stitch & Style', '+254778901234', 6, 75000.00, 75000.00, 16500.00, 0.00, 'mobile', 'RA25051', 'paid', 75000.00, 0.00, '2025-08-28 09:45:00'),
('202508300001', 1, 'Walk-in Customer', '', 4, 5600.00, 5600.00, 1232.00, 0.00, 'cash', NULL, 'paid', 5600.00, 0.00, '2025-08-30 12:30:00');

-- SEPTEMBER 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202509020001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 92000.00, 92000.00, 20240.00, 0.00, 'mobile', 'RA25052', 'paid', 92000.00, 0.00, '2025-09-02 10:30:00'),
('202509050001', 1, 'Walk-in Customer', '', 6, 6800.00, 6800.00, 1496.00, 0.00, 'cash', NULL, 'paid', 6800.00, 0.00, '2025-09-05 11:45:00'),
('202509080001', 3, 'Jane Akinyi', '+254723456789', 4, 8200.00, 8200.00, 1804.00, 100.00, 'cash', NULL, 'paid', 8200.00, 0.00, '2025-09-08 14:00:00'),
('202509100001', 12, 'Mombasa Fabrics', '+254712345670', 5, 98000.00, 98000.00, 21560.00, 0.00, 'mobile', 'RA25053', 'paid', 98000.00, 0.00, '2025-09-10 09:15:00'),
('202509130001', 1, 'Walk-in Customer', '', 6, 5400.00, 5400.00, 1188.00, 0.00, 'cash', NULL, 'paid', 5400.00, 0.00, '2025-09-13 12:30:00'),
('202509150001', 11, 'Grace Njeri', '+254701234567', 4, 9800.00, 9800.00, 2156.00, 120.00, 'mobile', 'RA25054', 'paid', 9800.00, 0.00, '2025-09-15 15:45:00'),
('202509180001', 4, 'Textile Mart Ltd', '+254734567890', 5, 105000.00, 105000.00, 23100.00, 0.00, 'mobile', 'RA25055', 'partial', 80000.00, 25000.00, '2025-09-18 10:00:00'),
('202509200001', 1, 'Walk-in Customer', '', 6, 4800.00, 4800.00, 1056.00, 0.00, 'cash', NULL, 'paid', 4800.00, 0.00, '2025-09-20 11:15:00'),
('202509230001', 9, 'Elegant Tailors', '+254789012345', 4, 62000.00, 62000.00, 13640.00, 0.00, 'mobile', 'RA25056', 'paid', 62000.00, 0.00, '2025-09-23 14:30:00'),
('202509250001', 7, 'Peter Kamau', '+254767890123', 5, 11200.00, 11200.00, 2464.00, 150.00, 'mobile', 'RA25057', 'paid', 11200.00, 0.00, '2025-09-25 09:45:00'),
('202509280001', 8, 'Stitch & Style', '+254778901234', 6, 82000.00, 82000.00, 18040.00, 0.00, 'mobile', 'RA25058', 'paid', 82000.00, 0.00, '2025-09-28 12:00:00'),
('202509300001', 1, 'Walk-in Customer', '', 4, 6200.00, 6200.00, 1364.00, 0.00, 'cash', NULL, 'paid', 6200.00, 0.00, '2025-09-30 15:30:00');

-- OCTOBER 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202510030001', 13, 'Kisumu Textiles', '+254723456701', 5, 78000.00, 78000.00, 17160.00, 0.00, 'mobile', 'RA25059', 'paid', 78000.00, 0.00, '2025-10-03 10:15:00'),
('202510060001', 1, 'Walk-in Customer', '', 6, 7200.00, 7200.00, 1584.00, 0.00, 'cash', NULL, 'paid', 7200.00, 0.00, '2025-10-06 11:30:00'),
('202510080001', 6, 'Mary Wambui', '+254756789012', 4, 11800.00, 11800.00, 2596.00, 140.00, 'mobile', 'RA25060', 'paid', 11800.00, 0.00, '2025-10-08 14:45:00'),
('202510110001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 102000.00, 102000.00, 22440.00, 0.00, 'mobile', 'RA25061', 'paid', 102000.00, 0.00, '2025-10-11 09:00:00'),
('202510130001', 1, 'Walk-in Customer', '', 6, 5800.00, 5800.00, 1276.00, 0.00, 'cash', NULL, 'paid', 5800.00, 0.00, '2025-10-13 12:15:00'),
('202510160001', 14, 'Sarah Mutua', '+254734567012', 4, 10400.00, 10400.00, 2288.00, -70.00, 'mobile', 'RA25062', 'paid', 10400.00, 0.00, '2025-10-16 15:30:00'),
('202510180001', 12, 'Mombasa Fabrics', '+254712345670', 5, 108000.00, 108000.00, 23760.00, 0.00, 'mobile', 'RA25063', 'partial', 85000.00, 23000.00, '2025-10-18 10:45:00'),
('202510210001', 1, 'Walk-in Customer', '', 6, 6400.00, 6400.00, 1408.00, 0.00, 'cash', NULL, 'paid', 6400.00, 0.00, '2025-10-21 11:00:00'),
('202510230001', 4, 'Textile Mart Ltd', '+254734567890', 4, 95000.00, 95000.00, 20900.00, 0.00, 'mobile', 'RA25064', 'paid', 95000.00, 0.00, '2025-10-23 14:15:00'),
('202510260001', 2, 'John Mwangi', '+254712345678', 5, 8400.00, 8400.00, 1848.00, 110.00, 'cash', NULL, 'paid', 8400.00, 0.00, '2025-10-26 09:30:00'),
('202510280001', 9, 'Elegant Tailors', '+254789012345', 6, 68000.00, 68000.00, 14960.00, 0.00, 'mobile', 'RA25065', 'paid', 68000.00, 0.00, '2025-10-28 12:45:00'),
('202510310001', 1, 'Walk-in Customer', '', 4, 7400.00, 7400.00, 1628.00, 0.00, 'cash', NULL, 'paid', 7400.00, 0.00, '2025-10-31 15:00:00');

-- NOVEMBER 2025
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202511020001', 8, 'Stitch & Style', '+254778901234', 5, 88000.00, 88000.00, 19360.00, 0.00, 'mobile', 'RA25066', 'paid', 88000.00, 0.00, '2025-11-02 10:00:00'),
('202511050001', 1, 'Walk-in Customer', '', 6, 7800.00, 7800.00, 1716.00, 0.00, 'cash', NULL, 'paid', 7800.00, 0.00, '2025-11-05 11:15:00'),
('202511070001', 3, 'Jane Akinyi', '+254723456789', 4, 9200.00, 9200.00, 2024.00, 90.00, 'cash', NULL, 'paid', 9200.00, 0.00, '2025-11-07 14:30:00'),
('202511100001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 115000.00, 115000.00, 25300.00, 0.00, 'mobile', 'RA25067', 'paid', 115000.00, 0.00, '2025-11-10 09:45:00'),
('202511130001', 1, 'Walk-in Customer', '', 6, 6600.00, 6600.00, 1452.00, 0.00, 'cash', NULL, 'paid', 6600.00, 0.00, '2025-11-13 12:00:00'),
('202511150001', 15, 'Quick Stitch Tailors', '+254745670123', 4, 55000.00, 55000.00, 12100.00, 0.00, 'mobile', 'RA25068', 'partial', 40000.00, 15000.00, '2025-11-15 15:15:00'),
('202511180001', 10, 'David Ochieng', '+254790123456', 5, 9600.00, 9600.00, 2112.00, 80.00, 'mobile', 'RA25069', 'paid', 9600.00, 0.00, '2025-11-18 10:30:00'),
('202511200001', 13, 'Kisumu Textiles', '+254723456701', 6, 85000.00, 85000.00, 18700.00, 0.00, 'mobile', 'RA25070', 'paid', 85000.00, 0.00, '2025-11-20 11:45:00'),
('202511230001', 1, 'Walk-in Customer', '', 4, 8200.00, 8200.00, 1804.00, 0.00, 'cash', NULL, 'paid', 8200.00, 0.00, '2025-11-23 14:00:00'),
('202511250001', 4, 'Textile Mart Ltd', '+254734567890', 5, 108000.00, 108000.00, 23760.00, 0.00, 'mobile', 'RA25071', 'paid', 108000.00, 0.00, '2025-11-25 09:15:00'),
('202511280001', 11, 'Grace Njeri', '+254701234567', 6, 12200.00, 12200.00, 2684.00, 160.00, 'mobile', 'RA25072', 'paid', 12200.00, 0.00, '2025-11-28 12:30:00'),
('202511300001', 1, 'Walk-in Customer', '', 4, 7200.00, 7200.00, 1584.00, 0.00, 'cash', NULL, 'paid', 7200.00, 0.00, '2025-11-30 15:45:00');

-- DECEMBER 2025 (Peak Season - Highest Volume)
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202512020001', 12, 'Mombasa Fabrics', '+254712345670', 5, 125000.00, 125000.00, 27500.00, 0.00, 'mobile', 'RA25073', 'paid', 125000.00, 0.00, '2025-12-02 09:30:00'),
('202512040001', 1, 'Walk-in Customer', '', 6, 9200.00, 9200.00, 2024.00, 0.00, 'cash', NULL, 'paid', 9200.00, 0.00, '2025-12-04 11:00:00'),
('202512060001', 6, 'Mary Wambui', '+254756789012', 4, 14200.00, 14200.00, 3124.00, 180.00, 'mobile', 'RA25074', 'paid', 14200.00, 0.00, '2025-12-06 14:15:00'),
('202512080001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 135000.00, 135000.00, 29700.00, 0.00, 'mobile', 'RA25075', 'paid', 135000.00, 0.00, '2025-12-08 10:45:00'),
('202512100001', 1, 'Walk-in Customer', '', 6, 8400.00, 8400.00, 1848.00, 0.00, 'cash', NULL, 'paid', 8400.00, 0.00, '2025-12-10 12:30:00'),
('202512120001', 9, 'Elegant Tailors', '+254789012345', 4, 78000.00, 78000.00, 17160.00, 0.00, 'mobile', 'RA25076', 'paid', 78000.00, 0.00, '2025-12-12 09:00:00'),
('202512140001', 7, 'Peter Kamau', '+254767890123', 5, 13600.00, 13600.00, 2992.00, 170.00, 'mobile', 'RA25077', 'paid', 13600.00, 0.00, '2025-12-14 15:30:00'),
('202512160001', 8, 'Stitch & Style', '+254778901234', 6, 98000.00, 98000.00, 21560.00, 0.00, 'mobile', 'RA25078', 'partial', 75000.00, 23000.00, '2025-12-16 10:15:00'),
('202512180001', 1, 'Walk-in Customer', '', 4, 10200.00, 10200.00, 2244.00, 0.00, 'cash', NULL, 'paid', 10200.00, 0.00, '2025-12-18 11:45:00'),
('202512200001', 4, 'Textile Mart Ltd', '+254734567890', 5, 142000.00, 142000.00, 31240.00, 0.00, 'mobile', 'RA25079', 'paid', 142000.00, 0.00, '2025-12-20 14:00:00'),
('202512220001', 3, 'Jane Akinyi', '+254723456789', 6, 11400.00, 11400.00, 2508.00, -80.00, 'cash', NULL, 'paid', 11400.00, 0.00, '2025-12-22 09:30:00'),
('202512240001', 13, 'Kisumu Textiles', '+254723456701', 4, 95000.00, 95000.00, 20900.00, 0.00, 'mobile', 'RA25080', 'paid', 95000.00, 0.00, '2025-12-24 12:15:00'),
('202512260001', 1, 'Walk-in Customer', '', 5, 8800.00, 8800.00, 1936.00, 0.00, 'cash', NULL, 'paid', 8800.00, 0.00, '2025-12-26 10:00:00'),
('202512280001', 14, 'Sarah Mutua', '+254734567012', 6, 12800.00, 12800.00, 2816.00, 140.00, 'mobile', 'RA25081', 'paid', 12800.00, 0.00, '2025-12-28 15:00:00'),
('202512300001', 15, 'Quick Stitch Tailors', '+254745670123', 4, 68000.00, 68000.00, 14960.00, 0.00, 'mobile', 'RA25082', 'paid', 68000.00, 0.00, '2025-12-30 11:30:00');

-- JANUARY 2026
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202601030001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 98000.00, 98000.00, 21560.00, 0.00, 'mobile', 'RA26001', 'paid', 98000.00, 0.00, '2026-01-03 10:00:00'),
('202601060001', 1, 'Walk-in Customer', '', 6, 7600.00, 7600.00, 1672.00, 0.00, 'cash', NULL, 'paid', 7600.00, 0.00, '2026-01-06 11:30:00'),
('202601080001', 2, 'John Mwangi', '+254712345678', 4, 9800.00, 9800.00, 2156.00, 120.00, 'cash', NULL, 'paid', 9800.00, 0.00, '2026-01-08 14:45:00'),
('202601110001', 12, 'Mombasa Fabrics', '+254712345670', 5, 112000.00, 112000.00, 24640.00, 0.00, 'mobile', 'RA26002', 'paid', 112000.00, 0.00, '2026-01-11 09:15:00'),
('202601130001', 1, 'Walk-in Customer', '', 6, 6200.00, 6200.00, 1364.00, 0.00, 'cash', NULL, 'paid', 6200.00, 0.00, '2026-01-13 12:00:00'),
('202601160001', 8, 'Stitch & Style', '+254778901234', 4, 75000.00, 75000.00, 16500.00, 0.00, 'mobile', 'RA26003', 'partial', 55000.00, 20000.00, '2026-01-16 15:30:00'),
('202601180001', 11, 'Grace Njeri', '+254701234567', 5, 11400.00, 11400.00, 2508.00, 100.00, 'mobile', 'RA26004', 'paid', 11400.00, 0.00, '2026-01-18 10:45:00'),
('202601210001', 4, 'Textile Mart Ltd', '+254734567890', 6, 105000.00, 105000.00, 23100.00, 0.00, 'mobile', 'RA26005', 'paid', 105000.00, 0.00, '2026-01-21 11:15:00'),
('202601230001', 1, 'Walk-in Customer', '', 4, 8200.00, 8200.00, 1804.00, 0.00, 'cash', NULL, 'paid', 8200.00, 0.00, '2026-01-23 14:00:00'),
('202601260001', 9, 'Elegant Tailors', '+254789012345', 5, 62000.00, 62000.00, 13640.00, 0.00, 'mobile', 'RA26006', 'paid', 62000.00, 0.00, '2026-01-26 09:30:00'),
('202601280001', 6, 'Mary Wambui', '+254756789012', 6, 12600.00, 12600.00, 2772.00, 150.00, 'mobile', 'RA26007', 'paid', 12600.00, 0.00, '2026-01-28 12:45:00'),
('202601300001', 1, 'Walk-in Customer', '', 4, 7400.00, 7400.00, 1628.00, 0.00, 'cash', NULL, 'paid', 7400.00, 0.00, '2026-01-30 15:15:00');

-- FEBRUARY 2026
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202602020001', 13, 'Kisumu Textiles', '+254723456701', 5, 82000.00, 82000.00, 18040.00, 0.00, 'mobile', 'RA26008', 'paid', 82000.00, 0.00, '2026-02-02 10:30:00'),
('202602050001', 1, 'Walk-in Customer', '', 6, 8400.00, 8400.00, 1848.00, 0.00, 'cash', NULL, 'paid', 8400.00, 0.00, '2026-02-05 11:45:00'),
('202602070001', 7, 'Peter Kamau', '+254767890123', 4, 13200.00, 13200.00, 2904.00, 160.00, 'mobile', 'RA26009', 'paid', 13200.00, 0.00, '2026-02-07 14:15:00'),
('202602100001', 5, 'Fashion Hub Kenya', '+254745678901', 5, 118000.00, 118000.00, 25960.00, 0.00, 'mobile', 'RA26010', 'paid', 118000.00, 0.00, '2026-02-10 09:00:00'),
('202602120001', 1, 'Walk-in Customer', '', 6, 6800.00, 6800.00, 1496.00, 0.00, 'cash', NULL, 'paid', 6800.00, 0.00, '2026-02-12 12:30:00'),
('202602150001', 3, 'Jane Akinyi', '+254723456789', 4, 10200.00, 10200.00, 2244.00, -60.00, 'cash', NULL, 'paid', 10200.00, 0.00, '2026-02-15 15:45:00'),
('202602170001', 12, 'Mombasa Fabrics', '+254712345670', 5, 125000.00, 125000.00, 27500.00, 0.00, 'mobile', 'RA26011', 'partial', 100000.00, 25000.00, '2026-02-17 10:15:00'),
('202602200001', 1, 'Walk-in Customer', '', 6, 7600.00, 7600.00, 1672.00, 0.00, 'cash', NULL, 'paid', 7600.00, 0.00, '2026-02-20 11:00:00'),
('202602220001', 4, 'Textile Mart Ltd', '+254734567890', 4, 98000.00, 98000.00, 21560.00, 0.00, 'mobile', 'RA26012', 'paid', 98000.00, 0.00, '2026-02-22 14:30:00'),
('202602250001', 10, 'David Ochieng', '+254790123456', 5, 11800.00, 11800.00, 2596.00, 90.00, 'mobile', 'RA26013', 'paid', 11800.00, 0.00, '2026-02-25 09:45:00'),
('202602280001', 8, 'Stitch & Style', '+254778901234', 6, 85000.00, 85000.00, 18700.00, 0.00, 'mobile', 'RA26014', 'paid', 85000.00, 0.00, '2026-02-28 12:00:00');

-- MARCH 2026
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202603030001', 9, 'Elegant Tailors', '+254789012345', 4, 72000.00, 72000.00, 15840.00, 0.00, 'mobile', 'RA26015', 'paid', 72000.00, 0.00, '2026-03-03 10:00:00'),
('202603050001', 1, 'Walk-in Customer', '', 5, 9200.00, 9200.00, 2024.00, 0.00, 'cash', NULL, 'paid', 9200.00, 0.00, '2026-03-05 11:30:00'),
('202603080001', 15, 'Quick Stitch Tailors', '+254745670123', 6, 58000.00, 58000.00, 12760.00, 0.00, 'mobile', 'RA26016', 'paid', 58000.00, 0.00, '2026-03-08 14:45:00'),
('202603100001', 5, 'Fashion Hub Kenya', '+254745678901', 4, 108000.00, 108000.00, 23760.00, 0.00, 'mobile', 'RA26017', 'partial', 80000.00, 28000.00, '2026-03-10 09:15:00'),
('202603130001', 1, 'Walk-in Customer', '', 5, 7800.00, 7800.00, 1716.00, 0.00, 'cash', NULL, 'paid', 7800.00, 0.00, '2026-03-13 12:15:00'),
('202603150001', 6, 'Mary Wambui', '+254756789012', 6, 14800.00, 14800.00, 3256.00, 180.00, 'mobile', 'RA26018', 'paid', 14800.00, 0.00, '2026-03-15 15:30:00'),
('202603180001', 13, 'Kisumu Textiles', '+254723456701', 4, 92000.00, 92000.00, 20240.00, 0.00, 'mobile', 'RA26019', 'paid', 92000.00, 0.00, '2026-03-18 10:45:00'),
('202603200001', 1, 'Walk-in Customer', '', 5, 8600.00, 8600.00, 1892.00, 0.00, 'cash', NULL, 'paid', 8600.00, 0.00, '2026-03-20 11:00:00'),
('202603230001', 4, 'Textile Mart Ltd', '+254734567890', 6, 115000.00, 115000.00, 25300.00, 0.00, 'mobile', 'RA26020', 'paid', 115000.00, 0.00, '2026-03-23 14:00:00'),
('202603250001', 2, 'John Mwangi', '+254712345678', 4, 11200.00, 11200.00, 2464.00, 130.00, 'cash', NULL, 'paid', 11200.00, 0.00, '2026-03-25 09:30:00'),
('202603280001', 12, 'Mombasa Fabrics', '+254712345670', 5, 135000.00, 135000.00, 29700.00, 0.00, 'mobile', 'RA26021', 'paid', 135000.00, 0.00, '2026-03-28 12:45:00'),
('202603300001', 1, 'Walk-in Customer', '', 6, 9800.00, 9800.00, 2156.00, 0.00, 'cash', NULL, 'paid', 9800.00, 0.00, '2026-03-30 15:15:00');

-- APRIL 2026
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202604020001', 8, 'Stitch & Style', '+254778901234', 4, 95000.00, 95000.00, 20900.00, 0.00, 'mobile', 'RA26022', 'paid', 95000.00, 0.00, '2026-04-02 10:15:00'),
('202604050001', 1, 'Walk-in Customer', '', 5, 10200.00, 10200.00, 2244.00, 0.00, 'cash', NULL, 'paid', 10200.00, 0.00, '2026-04-05 11:45:00'),
('202604070001', 3, 'Jane Akinyi', '+254723456789', 6, 12400.00, 12400.00, 2728.00, 110.00, 'cash', NULL, 'paid', 12400.00, 0.00, '2026-04-07 14:30:00'),
('202604100001', 5, 'Fashion Hub Kenya', '+254745678901', 4, 122000.00, 122000.00, 26840.00, 0.00, 'mobile', 'RA26023', 'paid', 122000.00, 0.00, '2026-04-10 09:00:00'),
('202604120001', 1, 'Walk-in Customer', '', 5, 8400.00, 8400.00, 1848.00, 0.00, 'cash', NULL, 'paid', 8400.00, 0.00, '2026-04-12 12:00:00'),
('202604150001', 11, 'Grace Njeri', '+254701234567', 6, 13800.00, 13800.00, 3036.00, 170.00, 'mobile', 'RA26024', 'paid', 13800.00, 0.00, '2026-04-15 15:45:00'),
('202604170001', 9, 'Elegant Tailors', '+254789012345', 4, 82000.00, 82000.00, 18040.00, 0.00, 'mobile', 'RA26025', 'partial', 60000.00, 22000.00, '2026-04-17 10:30:00'),
('202604200001', 1, 'Walk-in Customer', '', 5, 9600.00, 9600.00, 2112.00, 0.00, 'cash', NULL, 'paid', 9600.00, 0.00, '2026-04-20 11:15:00'),
('202604220001', 4, 'Textile Mart Ltd', '+254734567890', 6, 128000.00, 128000.00, 28160.00, 0.00, 'mobile', 'RA26026', 'paid', 128000.00, 0.00, '2026-04-22 14:00:00'),
('202604250001', 7, 'Peter Kamau', '+254767890123', 4, 15200.00, 15200.00, 3344.00, 190.00, 'mobile', 'RA26027', 'paid', 15200.00, 0.00, '2026-04-25 09:45:00'),
('202604270001', 13, 'Kisumu Textiles', '+254723456701', 5, 98000.00, 98000.00, 21560.00, 0.00, 'mobile', 'RA26028', 'paid', 98000.00, 0.00, '2026-04-27 12:30:00'),
('202604300001', 1, 'Walk-in Customer', '', 6, 11200.00, 11200.00, 2464.00, 0.00, 'cash', NULL, 'paid', 11200.00, 0.00, '2026-04-30 15:00:00');

-- MAY 2026 (Current Month - Up to Today)
INSERT INTO sales (order_number, customer_id, customer_name, customer_mobile, user_id, subtotal, total, profit, unexpected_profit, payment_method, mpesa_code, payment_status, amount_paid, amount_due, sale_date) VALUES
('202605020001', 12, 'Mombasa Fabrics', '+254712345670', 4, 142000.00, 142000.00, 31240.00, 0.00, 'mobile', 'RA26029', 'paid', 142000.00, 0.00, '2026-05-02 10:00:00'),
('202605050001', 1, 'Walk-in Customer', '', 5, 10800.00, 10800.00, 2376.00, 0.00, 'cash', NULL, 'paid', 10800.00, 0.00, '2026-05-05 11:30:00'),
('202605070001', 6, 'Mary Wambui', '+254756789012', 6, 16200.00, 16200.00, 3564.00, 200.00, 'mobile', 'RA26030', 'paid', 16200.00, 0.00, '2026-05-07 14:15:00'),
('202605100001', 5, 'Fashion Hub Kenya', '+254745678901', 4, 135000.00, 135000.00, 29700.00, 0.00, 'mobile', 'RA26031', 'paid', 135000.00, 0.00, '2026-05-10 09:30:00'),
('202605120001', 1, 'Walk-in Customer', '', 5, 9200.00, 9200.00, 2024.00, 0.00, 'cash', NULL, 'paid', 9200.00, 0.00, '2026-05-12 12:45:00'),
('202605140001', 8, 'Stitch & Style', '+254778901234', 6, 102000.00, 102000.00, 22440.00, 0.00, 'mobile', 'RA26032', 'partial', 75000.00, 27000.00, '2026-05-14 15:00:00'),
('202605170001', 14, 'Sarah Mutua', '+254734567012', 4, 14600.00, 14600.00, 3212.00, 140.00, 'mobile', 'RA26033', 'paid', 14600.00, 0.00, '2026-05-17 10:15:00'),
('202605190001', 4, 'Textile Mart Ltd', '+254734567890', 5, 148000.00, 148000.00, 32560.00, 0.00, 'mobile', 'RA26034', 'paid', 148000.00, 0.00, '2026-05-19 11:00:00'),
('202605210001', 1, 'Walk-in Customer', '', 6, 11600.00, 11600.00, 2552.00, 0.00, 'cash', NULL, 'paid', 11600.00, 0.00, '2026-05-21 14:30:00'),
('202605230001', 9, 'Elegant Tailors', '+254789012345', 4, 88000.00, 88000.00, 19360.00, 0.00, 'mobile', 'RA26035', 'paid', 88000.00, 0.00, '2026-05-23 09:45:00'),
('202605250001', 2, 'John Mwangi', '+254712345678', 5, 13400.00, 13400.00, 2948.00, 160.00, 'cash', NULL, 'paid', 13400.00, 0.00, '2026-05-25 12:00:00'),
('202605270001', 15, 'Quick Stitch Tailors', '+254745670123', 6, 72000.00, 72000.00, 15840.00, 0.00, 'mobile', 'RA26036', 'paid', 72000.00, 0.00, '2026-05-27 15:30:00'),
('202605280001', 1, 'Walk-in Customer', '', 4, 12800.00, 12800.00, 2816.00, 0.00, 'cash', NULL, 'paid', 12800.00, 0.00, '2026-05-28 10:30:00');

-- ================================================
-- SALE ITEMS (Representative samples for each month)
-- ================================================
INSERT INTO sale_items (sale_id, product_id, product_name, quantity, unit_price, cost_price, minimum_price, total, profit, unexpected_profit) VALUES
-- June 2024
(1, 1, 'Cotton Plain White', 3, 250.00, 200.00, 220.00, 750.00, 150.00, 0.00),
(1, 9, 'Cotton Thread White', 18, 25.00, 15.00, 18.00, 450.00, 180.00, 0.00),
(2, 3, 'Denim Classic Blue', 4, 450.00, 350.00, 380.00, 1800.00, 400.00, 0.00),
(2, 12, 'Heavy Duty Thread', 20, 30.00, 20.00, 22.00, 600.00, 200.00, 0.00),
(3, 1, 'Cotton Plain White', 40, 250.00, 200.00, 220.00, 10000.00, 2000.00, 0.00),
(3, 5, 'Polyester Satin', 15, 240.00, 180.00, 200.00, 3600.00, 900.00, 0.00),
-- July 2024
(7, 2, 'Cotton Printed Floral', 4, 280.00, 220.00, 240.00, 1120.00, 240.00, 0.00),
(8, 6, 'Linen Natural Beige', 5, 520.00, 400.00, 440.00, 2600.00, 600.00, 0.00),
(9, 4, 'Silk Charmeuse White', 20, 1000.00, 800.00, 850.00, 20000.00, 4000.00, 0.00),
-- December 2024 (Peak)
(42, 1, 'Cotton Plain White', 100, 250.00, 200.00, 220.00, 25000.00, 5000.00, 0.00),
(42, 3, 'Denim Classic Blue', 60, 450.00, 350.00, 380.00, 27000.00, 6000.00, 0.00),
(45, 4, 'Silk Charmeuse White', 50, 1000.00, 800.00, 850.00, 50000.00, 10000.00, 0.00),
-- December 2025 (Higher Peak)
(140, 1, 'Cotton Plain White', 200, 250.00, 200.00, 220.00, 50000.00, 10000.00, 0.00),
(140, 3, 'Denim Classic Blue', 100, 450.00, 350.00, 380.00, 45000.00, 10000.00, 0.00),
(143, 4, 'Silk Charmeuse White', 80, 1000.00, 800.00, 850.00, 80000.00, 16000.00, 0.00),
-- May 2026 (Current)
(198, 1, 'Cotton Plain White', 250, 250.00, 200.00, 220.00, 62500.00, 12500.00, 0.00),
(198, 5, 'Polyester Satin', 150, 240.00, 180.00, 200.00, 36000.00, 9000.00, 0.00),
(201, 3, 'Denim Classic Blue', 120, 450.00, 350.00, 380.00, 54000.00, 12000.00, 0.00),
(204, 4, 'Silk Charmeuse White', 100, 1000.00, 800.00, 850.00, 100000.00, 20000.00, 0.00);

-- Multi-unit line items: quantity is in the SOLD unit, base_quantity is the
-- equivalent in base units that was deducted from stock.
INSERT INTO sale_items (sale_id, product_id, product_name, quantity, unit_label, base_quantity, unit_price, cost_price, minimum_price, total, profit, unexpected_profit) VALUES
(198, 9, 'Cotton Thread White', 5, 'Box', 60.00, 270.00, 180.00, 240.00, 1350.00, 450.00, 0.00),       -- 5 boxes  = 60 spools
(201, 1, 'Cotton Plain White', 2, 'Roll', 100.00, 12000.00, 10000.00, 11000.00, 24000.00, 4000.00, 0.00), -- 2 rolls  = 100 metres
(204, 3, 'Denim Classic Blue', 1, 'Roll', 50.00, 21500.00, 17500.00, 19000.00, 21500.00, 4000.00, 0.00),  -- 1 roll   = 50 metres
(204, 1, 'Cotton Plain White', 12.5, 'Metre', 12.50, 250.00, 200.00, 220.00, 3125.00, 625.00, 0.00);      -- 12.5 m cut-to-length

-- ================================================
-- DEBT ORDERS (For partial payments)
-- ================================================
INSERT INTO debt_orders (sale_id, customer_id, amount_due, amount_paid, due_date, status, notes) VALUES
(4, 5, 7000.00, 0.00, '2024-07-28', 'paid', 'Fashion Hub Kenya - June order'),
(8, 9, 6000.00, 0.00, '2024-08-31', 'paid', 'Elegant Tailors - July order'),
(21, 13, 10000.00, 0.00, '2024-10-18', 'paid', 'Kisumu Textiles - Sept order'),
(33, 8, 13000.00, 0.00, '2024-12-18', 'paid', 'Stitch & Style - Nov order'),
(48, 13, 18000.00, 0.00, '2025-01-20', 'paid', 'Kisumu Textiles - Dec order'),
(58, 5, 18000.00, 0.00, '2025-02-12', 'paid', 'Fashion Hub Kenya - Jan order'),
(65, 13, 12000.00, 0.00, '2025-03-17', 'paid', 'Kisumu Textiles - Feb order'),
(74, 8, 15000.00, 5000.00, '2025-04-20', 'partial', 'Stitch & Style - Mar order'),
(83, 15, 10000.00, 0.00, '2025-05-16', 'paid', 'Quick Stitch - April order'),
(92, 5, 25000.00, 10000.00, '2025-06-23', 'partial', 'Fashion Hub Kenya - May order'),
(99, 8, 17000.00, 0.00, '2025-07-13', 'paid', 'Stitch & Style - June order'),
(108, 12, 22000.00, 12000.00, '2025-08-17', 'partial', 'Mombasa Fabrics - July order'),
(117, 15, 13000.00, 0.00, '2025-09-18', 'paid', 'Quick Stitch - Aug order'),
(124, 4, 25000.00, 15000.00, '2025-10-18', 'partial', 'Textile Mart - Sept order'),
(133, 12, 23000.00, 0.00, '2025-11-18', 'paid', 'Mombasa Fabrics - Oct order'),
(142, 15, 15000.00, 5000.00, '2025-12-15', 'partial', 'Quick Stitch - Nov order'),
(150, 8, 23000.00, 8000.00, '2026-01-16', 'partial', 'Stitch & Style - Dec order'),
(159, 8, 20000.00, 10000.00, '2026-02-16', 'partial', 'Stitch & Style - Jan order'),
(168, 12, 25000.00, 15000.00, '2026-03-17', 'partial', 'Mombasa Fabrics - Feb order'),
(176, 5, 28000.00, 0.00, '2026-04-10', 'pending', 'Fashion Hub Kenya - Mar order'),
(182, 9, 22000.00, 0.00, '2026-05-17', 'pending', 'Elegant Tailors - April order'),
(192, 8, 27000.00, 0.00, '2026-06-14', 'pending', 'Stitch & Style - May order');

-- ================================================
-- DEBT PAYMENTS
-- ================================================
INSERT INTO debt_payments (debt_id, sale_id, amount, payment_method, mpesa_code, user_id, notes, payment_date) VALUES
(1, NULL, 7000.00, 'mobile', 'DP24001', 4, 'Full payment received', '2024-07-15 10:00:00'),
(2, NULL, 6000.00, 'mobile', 'DP24002', 5, 'Full payment received', '2024-08-20 11:30:00'),
(3, NULL, 10000.00, 'mobile', 'DP24003', 6, 'Full payment received', '2024-10-10 14:00:00'),
(4, NULL, 13000.00, 'mobile', 'DP24004', 4, 'Full payment received', '2024-12-10 09:45:00'),
(5, NULL, 18000.00, 'mobile', 'DP25001', 5, 'Full payment received', '2025-01-15 11:15:00'),
(6, NULL, 18000.00, 'mobile', 'DP25002', 6, 'Full payment received', '2025-02-05 13:30:00'),
(7, NULL, 12000.00, 'mobile', 'DP25003', 4, 'Full payment received', '2025-03-10 10:45:00'),
(8, NULL, 5000.00, 'mobile', 'DP25004', 5, 'Partial payment', '2025-04-10 14:15:00'),
(9, NULL, 10000.00, 'mobile', 'DP25005', 6, 'Full payment received', '2025-05-10 09:30:00'),
(10, NULL, 10000.00, 'mobile', 'DP25006', 4, 'Partial payment', '2025-06-15 12:00:00'),
(11, NULL, 17000.00, 'mobile', 'DP25007', 5, 'Full payment received', '2025-07-05 15:45:00'),
(12, NULL, 12000.00, 'mobile', 'DP25008', 6, 'Partial payment', '2025-08-10 10:15:00'),
(13, NULL, 13000.00, 'mobile', 'DP25009', 4, 'Full payment received', '2025-09-10 11:30:00'),
(14, NULL, 15000.00, 'mobile', 'DP25010', 5, 'Partial payment', '2025-10-10 14:45:00'),
(15, NULL, 23000.00, 'mobile', 'DP25011', 6, 'Full payment received', '2025-11-10 09:00:00'),
(16, NULL, 5000.00, 'mobile', 'DP25012', 4, 'Partial payment', '2025-12-08 12:30:00'),
(17, NULL, 8000.00, 'mobile', 'DP26001', 5, 'Partial payment', '2026-01-10 15:15:00'),
(18, NULL, 10000.00, 'mobile', 'DP26002', 6, 'Partial payment', '2026-02-10 10:45:00'),
(19, NULL, 15000.00, 'mobile', 'DP26003', 4, 'Partial payment', '2026-03-10 11:00:00');

-- ================================================
-- STOCK MOVEMENTS (Representative samples)
-- ================================================
INSERT INTO stock_movements (product_id, product_name, type, quantity, previous_stock, new_stock, user_id, reference_id, reference_type, reason, movement_date) VALUES
-- Initial restocking June 2024
(1, 'Cotton Plain White', 'purchase', 500, 0, 500, 7, NULL, 'initial', 'Initial stock', '2024-06-01 08:00:00'),
(3, 'Denim Classic Blue', 'purchase', 300, 0, 300, 7, NULL, 'initial', 'Initial stock', '2024-06-01 08:00:00'),
(4, 'Silk Charmeuse White', 'purchase', 150, 0, 150, 7, NULL, 'initial', 'Initial stock', '2024-06-01 08:00:00'),
-- Quarterly restocking
(1, 'Cotton Plain White', 'purchase', 200, 350, 550, 7, NULL, 'restock', 'Q3 2024 restock', '2024-09-15 09:00:00'),
(1, 'Cotton Plain White', 'purchase', 300, 280, 580, 7, NULL, 'restock', 'Q4 2024 restock', '2024-12-01 09:00:00'),
(1, 'Cotton Plain White', 'purchase', 250, 320, 570, 7, NULL, 'restock', 'Q1 2025 restock', '2025-03-01 09:00:00'),
(1, 'Cotton Plain White', 'purchase', 300, 250, 550, 7, NULL, 'restock', 'Q2 2025 restock', '2025-06-01 09:00:00'),
(1, 'Cotton Plain White', 'purchase', 350, 200, 550, 7, NULL, 'restock', 'Q3 2025 restock', '2025-09-01 09:00:00'),
(1, 'Cotton Plain White', 'purchase', 400, 150, 550, 7, NULL, 'restock', 'Q4 2025 restock', '2025-12-01 09:00:00'),
(1, 'Cotton Plain White', 'purchase', 350, 180, 530, 7, NULL, 'restock', 'Q1 2026 restock', '2026-03-01 09:00:00'),
(3, 'Denim Classic Blue', 'purchase', 150, 180, 330, 7, NULL, 'restock', 'Q2 2025 restock', '2025-06-15 09:00:00'),
(3, 'Denim Classic Blue', 'purchase', 200, 120, 320, 7, NULL, 'restock', 'Q4 2025 restock', '2025-12-15 09:00:00'),
(4, 'Silk Charmeuse White', 'purchase', 100, 80, 180, 7, NULL, 'restock', 'Q4 2024 restock', '2024-12-10 09:00:00'),
(4, 'Silk Charmeuse White', 'purchase', 80, 50, 130, 7, NULL, 'restock', 'Q2 2025 restock', '2025-06-10 09:00:00'),
(4, 'Silk Charmeuse White', 'purchase', 100, 30, 130, 7, NULL, 'restock', 'Q4 2025 restock', '2025-12-10 09:00:00');

-- ================================================
-- NOTIFICATIONS
-- ================================================
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
(1, 'Welcome to LilyJoe Textiles', 'System initialized successfully. Welcome to your new ERP system!', 'success', 1, '2024-06-01 08:00:00'),
(1, 'Low Stock Alert', 'Silk Charmeuse White is running low. Current stock: 30 units.', 'warning', 1, '2024-11-15 10:00:00'),
(1, 'Monthly Sales Record', 'December 2024 achieved highest monthly sales: KES 453,000!', 'success', 1, '2025-01-01 09:00:00'),
(1, 'Debt Payment Received', 'Fashion Hub Kenya paid KES 18,000 clearing their debt.', 'info', 1, '2025-02-05 13:30:00'),
(1, 'Low Stock Alert', 'Multiple products below minimum stock threshold.', 'warning', 1, '2025-05-20 11:00:00'),
(1, 'Sales Milestone', 'Congratulations! Total sales exceeded KES 5,000,000 for Year 1.', 'success', 1, '2025-06-01 08:00:00'),
(1, 'New Customer Added', 'Quick Stitch Tailors added as a new B2B customer.', 'info', 1, '2025-03-14 09:00:00'),
(1, 'Monthly Sales Record', 'December 2025 achieved new record: KES 756,000!', 'success', 1, '2026-01-01 09:00:00'),
(1, 'Outstanding Debts', '3 customers have outstanding debts totaling KES 77,000.', 'warning', 0, '2026-05-01 10:00:00'),
(1, 'System Update', 'New features added: Enhanced reporting and analytics.', 'info', 0, '2026-05-15 08:00:00');

-- ================================================
-- USER ACTIVITY LOG
-- ================================================
INSERT INTO user_activity (user_id, action, description, ip_address, created_at) VALUES
(1, 'login', 'Super Admin logged in', '192.168.1.100', '2024-06-01 08:00:00'),
(1, 'system_setup', 'Initial system configuration completed', '192.168.1.100', '2024-06-01 08:30:00'),
(4, 'login', 'Cashier Mary Wanjiku logged in', '192.168.1.101', '2024-06-05 09:00:00'),
(4, 'sale', 'Processed sale #202406050001', '192.168.1.101', '2024-06-05 10:30:00'),
(7, 'stock_update', 'Added initial stock for 44 products', '192.168.1.102', '2024-06-01 09:00:00'),
(2, 'login', 'Admin Sarah Njeri logged in', '192.168.1.100', '2025-01-02 09:00:00'),
(2, 'report', 'Generated annual sales report for 2024', '192.168.1.100', '2025-01-02 10:00:00'),
(3, 'login', 'Manager John Kamau logged in', '192.168.1.103', '2025-06-01 09:00:00'),
(3, 'analysis', 'Reviewed Year 1 business performance', '192.168.1.103', '2025-06-01 10:00:00'),
(1, 'login', 'Super Admin logged in', '192.168.1.100', '2026-01-02 08:00:00'),
(1, 'report', 'Generated comprehensive 2-year analysis', '192.168.1.100', '2026-01-02 09:00:00'),
(5, 'login', 'Cashier Peter Omondi logged in', '192.168.1.104', '2026-05-28 09:00:00'),
(5, 'sale', 'Processed sale #202605280001', '192.168.1.104', '2026-05-28 10:30:00'),
(1, 'login', 'Super Admin logged in - current session', '192.168.1.100', '2026-05-28 08:00:00');

-- ================================================
-- DELETED ITEMS (Soft-delete archive / recycle bin)
-- ================================================
-- Each row is a JSON snapshot of an entity removed from the system, with who
-- removed it and why. These power the "Deleted Items" / restore view.
INSERT INTO deleted_items (entity_type, entity_id, entity_label, data, deleted_by_id, deleted_by_name, deleted_by_role, reason, deleted_at) VALUES
('product', 101, 'Cotton Blend Red (Discontinued)', '{"id":101,"name":"Cotton Blend Red","category_id":1,"cost_price":180,"selling_price":240,"current_stock":0,"status":"discontinued"}', 1, 'Caleb Magaju', 'Super Admin', 'Product discontinued - no longer stocked', '2026-02-10 11:20:00'),
('category', 9, 'Seasonal Decorations', '{"id":9,"name":"Seasonal Decorations","icon":"fa-snowflake","color":"#0ea5e9","product_count":0}', 2, 'Sarah Njeri', 'Admin', 'Empty category removed during catalogue cleanup', '2026-01-18 09:45:00'),
('customer', 16, 'Test Customer (Duplicate)', '{"id":16,"name":"Test Customer","mobile":"+254700000000","email":"test@example.com","total_debt":0}', 1, 'Caleb Magaju', 'Super Admin', 'Duplicate customer record merged into John Mwangi', '2026-03-05 14:30:00'),
('unit', 11, 'Bales', '{"id":11,"name":"Bales","symbol":"bale","products_using":0}', 3, 'John Kamau', 'Manager', 'Unused measurement unit', '2026-02-22 16:10:00'),
('sale', 207, '202604180001', '{"id":207,"order_number":"202604180001","customer_name":"Walk-in Customer","total":4500,"payment_method":"cash"}', 4, 'Mary Wanjiku', 'Cashier', 'Sale voided - customer cancelled the order', '2026-04-18 10:05:00'),
('user', 9, 'Tom Barasa (Former Cashier)', '{"id":9,"username":"cashier4","full_name":"Tom Barasa","role":"Cashier","status":"inactive"}', 1, 'Caleb Magaju', 'Super Admin', 'Staff member left the company', '2026-03-30 17:00:00');

-- ================================================
-- SUPPORT MESSAGES (Help & Support tickets)
-- ================================================
INSERT INTO support_messages (user_id, sender_name, sender_email, sender_role, subject, message, category, status, emailed, created_at) VALUES
(2, 'Sarah Njeri', 'sarah@lilyjoe.com', 'Admin', 'Add a Supervisor user role', 'We would like a "Supervisor" role with limited admin access for shift leads.', 'feature', 'new', 0, '2026-05-25 16:20:00'),
(4, 'Mary Wanjiku', 'mary@lilyjoe.com', 'Cashier', 'Receipt printer not working', 'The receipt printer at POS station 2 stopped printing after the last update. Please advise.', 'technical', 'new', 1, '2026-05-20 09:15:00'),
(3, 'John Kamau', 'john@lilyjoe.com', 'Manager', 'Export monthly report to Excel', 'Could we get an option to export the monthly sales report directly to Excel?', 'feature', 'read', 1, '2026-05-12 14:40:00'),
(7, 'David Otieno', 'david@lilyjoe.com', 'Inventory Manager', 'Stock count mismatch on Cotton Plain White', 'It shows 447.5 metres but my physical count is 445. How do I record the adjustment?', 'inventory', 'resolved', 1, '2026-04-28 11:05:00'),
(5, 'Peter Omondi', 'peter@lilyjoe.com', 'Cashier', 'How do I apply a customer discount?', 'I need help understanding how to apply a percentage discount during checkout.', 'general', 'resolved', 1, '2026-03-15 10:30:00');

-- ================================================
-- USER PROFILE IMAGES
-- ================================================
-- profile_image stores a base64 data URL set via the app's Account Settings.
-- Left NULL here so seeded users fall back to initials-based avatars.
UPDATE users SET profile_image = NULL WHERE profile_image IS NULL;

-- ================================================
-- UPDATE PRODUCT COUNTS AND TOTALS
-- ================================================
UPDATE categories c SET product_count = (SELECT COUNT(*) FROM products p WHERE p.category_id = c.id);
UPDATE units u SET products_using = (SELECT COUNT(*) FROM products p WHERE p.unit_id = u.id);

-- ================================================
-- SUMMARY
-- ================================================
SELECT '================================================' AS '';
SELECT 'FLOWTIVE ERP - 2 YEAR SAMPLE DATA LOADED!' AS message;
SELECT '================================================' AS '';
SELECT 'Period: June 2024 - May 2026 (24 months)' AS info;
SELECT 'Total Sales Orders: ~210' AS info;
SELECT 'Total Customers: 15' AS info;
SELECT 'Total Products: 44 (4 multi-unit)' AS info;
SELECT 'Debt Orders: 22' AS info;
SELECT 'Multi-unit products: 4 with 8 product_units' AS info;
SELECT 'Deleted Items (archive): 6' AS info;
SELECT 'Support Messages: 5' AS info;
SELECT 'Fractional stock + unit-based sale items included' AS info;
SELECT 'Shows business growth progression over 2 years' AS info;
SELECT '================================================' AS '';
