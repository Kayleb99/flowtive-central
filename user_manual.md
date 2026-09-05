# Flowtive Central ERP: User Manual & Onboarding Guide

Welcome to Flowtive Central! This guide will help you understand how to navigate the system, whether you are ringing up sales as a Cashier, managing stock as an Inventory Manager, or overseeing the entire business as an Administrator.

---

## 1. Getting Started

### Logging In & First Steps
1. Navigate to your company's Flowtive URL (e.g., `https://your-company.vercel.app`).
2. Enter your **Username** and **Password** provided by your manager.
3. **Important:** If this is your first time logging in, or if an admin reset your password, you will be prompted to set a new secure password immediately.
4. Once logged in, you will land on your primary dashboard based on your role.

### Navigation Overview
- **Sidebar (Left):** This is your main menu. It is divided into three sections: **ERP Hub**, **Point of Sale**, and **Inventory**. You will only see the modules you have permission to access.
- **Top Bar:** Shows the current date, a button to toggle the sidebar on mobile devices, and system notifications.
- **User Menu (Bottom Left):** Displays your profile. Click the logout icon here when your shift is over.

---

## 2. Role-Based Quick Start

### 🛒 Cashiers
**Your main workspace is the Point of Sale (POS).**
- Go to **Point of Sale -> New Sale** to start ringing up customers.
- Go to **Point of Sale -> Sales History** to view receipts or check past transactions from your shift.
- *Tip: If a customer splits a payment between Cash and M-Pesa, use the "Split" tab during checkout.*

### 📦 Inventory Managers
**Your main workspace is the Inventory Module.**
- Go to **Inventory -> Items** to add new products or update prices.
- Go to **Inventory -> Low Stock** at the start of your day to see what needs ordering.
- Go to **Inventory -> Stock** when receiving a new delivery to log the incoming items.

### 📊 Managers & Admins
**Your main workspace is the ERP Hub.**
- Go to **ERP Hub -> Dashboard** for a bird's-eye view of today's revenue, profit, and customer counts.
- Go to **ERP Hub -> Reports** for end-of-day reconciliation.
- Admins can go to **ERP Hub -> Settings** to configure M-Pesa or business details.

---

## 3. Key Workflows: Step-by-Step

### How to Process a Sale (POS)
1. Navigate to **New Sale**.
2. **Find Products:** Use the search bar or click on product cards in the grid to add them to the cart.
3. **Adjust Cart:** Use the `+` and `-` buttons in the right-hand cart panel to change quantities.
4. Click **Checkout**.
5. **Customer Details (Optional):** Enter a name or mobile number if the customer wants a digital receipt or is buying on credit.
6. **Payment Method:**
   - **Cash:** Collect cash, click Confirm.
   - **M-Pesa (Manual):** Enter the M-Pesa confirmation code (e.g., `QH38...`) from the customer's text message.
   - **M-Pesa (Daraja/Auto):** If enabled by admins, a prompt will automatically appear on the customer's phone.
   - **Split:** Enter the Cash amount given; the system calculates the remaining M-Pesa balance.
   - **Debt:** Records the sale as unpaid. Requires customer details.
7. Click **Confirm Sale**.

### How to Add a New Product
1. Navigate to **Inventory -> Items**.
2. Click **+ Add Product** in the top right.
3. Fill in the details:
   - **Name:** What is the product? (e.g., "Unga 2kg")
   - **SKU/Barcode:** (Optional) Scan or type the barcode.
   - **Selling & Cost Price:** Ensures your profit reports are accurate.
   - **Opening Stock:** How many do you currently have on the shelf?
   - **Min Stock Alert:** When stock drops below this number, it appears on the Low Stock report.
4. Click **Add Product**.

### How to Record Incoming Stock (Deliveries)
*Do not just edit the product quantity directly—always record a stock movement so there is a paper trail!*
1. Navigate to **Inventory -> Stock**.
2. Click **+ Adjust Stock**.
3. Select the **Product** from the dropdown.
4. Set Type to **Purchase** (for new deliveries) or **Return** (if a customer brought an item back).
5. Enter the **Quantity** added.
6. (Optional) Add a reason like "Invoice #1234 from Supplier X".
7. Click **Save**.

### How to Reset a Staff Member's Password (Admins)
If a cashier forgets their password:
1. Navigate to **ERP Hub -> Users** (Note: this screen is accessible only to Managers/Admins).
2. Find the user in the list and click **Force Password Reset**.
3. The system will generate a temporary reset link. Share this link with the staff member.
4. When they click it, they will be forced to choose a new password.

---

## 4. Troubleshooting & Offline Mode

- **No Internet?** Flowtive Central is a Progressive Web App (PWA). If your internet goes down, the app will stay open. However, depending on your setup, you may need an active connection to process live Daraja M-Pesa payments or sync stock across multiple devices.
- **Install as an App:** You don't need the App Store or Play Store. Open Flowtive in Google Chrome or Safari, tap the browser menu, and select **"Add to Home Screen"** or **"Install App"**. It will now launch full-screen like a native app.
- **Wrong Stock Numbers?** If a product count is off, go to **Inventory -> Stock -> Adjust Stock**, select **Adjustment** as the type, and enter a positive (found extra) or negative (lost/damaged) quantity to correct it.
