# Flowtive Central ERP System

A complete, production-ready Enterprise Resource Planning (ERP) system designed for textile and retail businesses. Features Point of Sale (POS), Inventory Management, and Admin Dashboard modules.

## Features

- **Multi-Module System**: ERP Dashboard, Point of Sale, and Inventory Management
- **Role-Based Access**: Super Admin, Admin, Cashier, and Inventory Manager roles
- **Real-Time Sync**: Automatic data synchronization every 15 seconds
- **Dark/Light Mode**: Full theme support across all modules
- **PWA Ready**: Installable on mobile devices with offline support
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Invoice & Receipt Generation**: Professional PDF invoices and thermal receipts

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | HTML5, Tailwind CSS, JavaScript |
| Backend | PHP 7.4+ |
| Database | MySQL 5.7+ / MariaDB 10.3+ |
| Server | Apache (XAMPP) |
| Icons | Material Icons |
| Charts | ECharts |
| PDF | html2pdf.js |

## Project Structure

```
flowtive-erp/
├── api/                          # Backend PHP APIs
│   ├── config/
│   │   └── database.php          # Database connection & helpers
│   ├── auth/
│   │   ├── login.php             # User authentication
│   │   ├── logout.php            # Session termination
│   │   └── verify.php            # Token verification
│   ├── products/index.php        # Products CRUD
│   ├── categories/index.php      # Categories CRUD
│   ├── units/index.php           # Units CRUD
│   ├── sales/index.php           # Sales management
│   ├── customers/index.php       # Customer management
│   ├── users/index.php           # User management
│   ├── stock/index.php           # Stock movements
│   ├── dashboard/index.php       # Dashboard statistics
│   └── settings/index.php        # Company settings
├── scripts/                      # Database scripts
│   ├── 001_main_database.sql     # Database schema (run first)
│   └── 002_sample_database.sql   # Sample data with users
├── index.html                    # Redirect to login
├── login.html                    # Authentication page
├── erp-hub.html                  # Admin dashboard
├── pos.html                      # Point of Sale module
├── inventory.html                # Inventory management
├── manifest.json                 # PWA manifest
├── sw.js                         # Service worker
├── offline.html                  # Offline fallback page
└── README.md                     # This documentation
```

## Installation on XAMPP (Windows)

### Prerequisites

1. Download XAMPP from [apachefriends.org](https://www.apachefriends.org/download.html)
2. Install with Apache and MySQL components
3. Default path: `C:\xampp`

### Step 1: Start XAMPP Services

1. Open XAMPP Control Panel (Run as Administrator)
2. Click **Start** next to Apache
3. Click **Start** next to MySQL
4. Both should show green "Running" status

### Step 2: Deploy Project Files

1. Navigate to `C:\xampp\htdocs\`
2. Create folder `flowtive-erp`
3. Copy all project files maintaining the structure:

```
C:\xampp\htdocs\flowtive-erp\
├── api\
├── scripts\
├── index.html
├── login.html
├── erp-hub.html
├── pos.html
├── inventory.html
└── ...
```

### Step 3: Create Database

**Option A: Using phpMyAdmin (Recommended)**

1. Open browser: `http://localhost/phpmyadmin`
2. Click **SQL** tab
3. Copy contents of `scripts/001_main_database.sql`
4. Paste and click **Go**
5. Repeat for `scripts/002_sample_database.sql`

**Option B: Using MySQL Command Line**

```bash
cd C:\xampp\mysql\bin
mysql -u root
source C:/xampp/htdocs/flowtive-erp/scripts/001_main_database.sql;
source C:/xampp/htdocs/flowtive-erp/scripts/002_sample_database.sql;
```

### Step 4: Access the Application

1. Open browser: `http://localhost/flowtive-erp/`
2. Login with credentials below

## Default Login Credentials

| Role | Username | Password | Access |
|------|----------|----------|--------|
| Super Admin | superadmin | super123 | All modules |
| Admin | admin | admin123 | All modules |
| Manager | manager | manage123 | All modules |
| Cashier 1 | cashier1 | cash123 | POS only |
| Cashier 2 | cashier2 | cash123 | POS only |
| Cashier 3 | cashier3 | cash123 | POS only |
| Stock Keeper 1 | stockkeeper | stock123 | Inventory only |
| Stock Keeper 2 | stockkeeper2 | stock123 | Inventory only |

## Sample Data Included

- **8 Users** with different roles
- **8 Categories** (Cotton, Silk, Denim, Linen, Polyester, Accessories, Ready-Made, Yarns)
- **10 Units** of measurement
- **40 Products** across all categories
- **15 Customers** including businesses
- **10 Sales** with items and debt tracking
- **Company Settings** pre-configured

## API Endpoints

| Endpoint | Methods | Description |
|----------|---------|-------------|
| `/api/auth/login.php` | POST | Authenticate user |
| `/api/auth/logout.php` | POST | End session |
| `/api/auth/verify.php` | GET | Verify token |
| `/api/products/index.php` | GET, POST, PUT, DELETE | Manage products |
| `/api/categories/index.php` | GET, POST, PUT, DELETE | Manage categories |
| `/api/units/index.php` | GET, POST, PUT, DELETE | Manage units |
| `/api/sales/index.php` | GET, POST | Process sales |
| `/api/customers/index.php` | GET, POST, PUT, DELETE | Manage customers |
| `/api/users/index.php` | GET, POST, PUT, DELETE | Manage users |
| `/api/stock/index.php` | GET, POST | Stock movements |
| `/api/dashboard/index.php` | GET | Dashboard stats |
| `/api/settings/index.php` | GET, POST | Company settings |

## Database Configuration

Edit `api/config/database.php` if needed:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'flowtive_erp');
define('DB_USER', 'root');
define('DB_PASS', '');  // Empty for default XAMPP
```

## Troubleshooting

### "Database connection failed"
- Ensure MySQL is running in XAMPP
- Verify database `flowtive_erp` exists
- Check credentials in `api/config/database.php`

### "Apache won't start" (Port conflict)
1. Open XAMPP Config > Apache (httpd.conf)
2. Change `Listen 80` to `Listen 8080`
3. Access via `http://localhost:8080/flowtive-erp/`

### "Login not working"
1. Check browser console (F12) for errors
2. Verify SQL scripts executed successfully
3. Check users table has data:
   ```sql
   SELECT * FROM users WHERE username = 'superadmin';
   ```

### "Settings not saving"
- Ensure `company_settings` table exists
- Check API folder permissions
- View Apache error logs: `C:\xampp\apache\logs\error.log`

### "Data not showing in modules"
- Verify sample database script ran successfully
- Check browser network tab for API errors
- Ensure JavaScript console has no errors

## Module Features

### ERP Dashboard
- KPI cards with real-time data
- Sales trend charts
- Cashier performance matrix
- User management
- Company settings
- Report generation

### Point of Sale
- Product grid with search
- Cart with editable prices
- Multiple payment methods (Cash, M-Pesa)
- Debt/partial payment tracking
- Receipt and invoice generation
- Sales history with receipts

### Inventory Management
- Product catalog (grid/list view)
- Category management with icons
- Unit management
- Low stock alerts
- Stock value and potential sales calculations
- Stock adjustments

## Security Notes

⚠️ **For Production Deployment:**

1. **Enable Password Hashing** (currently disabled as requested)
2. **Use HTTPS** with SSL certificate
3. **Set Secure Headers** in Apache
4. **Implement Rate Limiting**
5. **Regular Database Backups**
6. **Update File Permissions** (restrict write access)

## Browser Support

- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

## License

Proprietary - Flowtive Central Ltd.

---

© 2026 Flowtive Central. All rights reserved.
