# Flowtive Central: Zero-Budget Deployment Guide

This guide will walk you through deploying the fully modernised Flowtive Central ERP to the cloud for **free**, using the best zero-budget tier services.

## Prerequisites (Local Machine)
Before you start, push your code to a GitHub repository:
1. Open your terminal in the project folder (`d:\Projects\flowtive-central`).
2. Run `npm install --legacy-peer-deps` (to generate the `package-lock.json`).
3. Commit everything and push to a new GitHub repository.

---

## Step 1: Database Setup (Supabase)
Supabase gives you a free, scalable PostgreSQL database.

1. Go to [Supabase](https://supabase.com/) and create an account/sign in.
2. Click **New Project**, choose a region close to you, and generate a strong database password (save this password somewhere safe).
3. Once the project is provisioned (takes a minute), click the **SQL Editor** on the left menu.
4. Copy the entire contents of your local `scripts/004_supabase_migration.sql` file.
5. Paste it into the SQL Editor and click **Run**. This will create all your tables, views, and the default admin user.
6. Go to **Project Settings (Gear icon) -> Database**.
7. Scroll down to **Connection string** and select the **URI** tab. 
   - It will look like this: `postgresql://postgres.[your-ref]:[YOUR-PASSWORD]@aws-0-[region].pooler.supabase.com:6543/postgres`
   - Copy this URI. Replace `[YOUR-PASSWORD]` with the password you made in step 2. Keep this handy.

---

## Step 2: Backend API Setup (Railway)
Railway will host our PHP backend using the `Dockerfile` I just created for you.

1. Go to [Railway](https://railway.app/) and sign in with GitHub.
2. Click **New Project** -> **Deploy from GitHub repo**.
3. Select your `flowtive-central` repository.
4. Once added, click on the deployed service card, go to the **Variables** tab, and add the following Environment Variables:
   - `DB_DRIVER`: `pgsql`
   - `DATABASE_URL`: *(Paste the Supabase Connection URI from Step 1)*
   - `APP_SECRET`: *(Generate a random 32-character string, e.g., `my-super-secret-key-2026-flowtive`)*
   - `APP_TIMEZONE`: `Africa/Nairobi`
   - `ALLOWED_ORIGINS`: *(Leave this blank for now, we will come back to it in Step 3)*
5. Go to the **Settings** tab, scroll down to **Networking**, and click **Generate Domain**.
   - It will give you a URL like `flowtive-central-production.up.railway.app`. 
   - Copy this URL. This is your `BACKEND_URL`.

---

## Step 3: Frontend Setup (Vercel)
Vercel is the creator of Next.js and hosts it perfectly for free.

1. Go to [Vercel](https://vercel.com/) and sign in with GitHub.
2. Click **Add New...** -> **Project**.
3. Import your `flowtive-central` repository.
4. Vercel will automatically detect the **Framework Preset** as **Next.js**.
5. Open the **Environment Variables** section and add:
   - `NEXT_PUBLIC_API_URL`: `https://[YOUR-RAILWAY-DOMAIN]` *(e.g., `https://flowtive-central-production.up.railway.app` - **No trailing slash!**)*
6. Click **Deploy**.
7. Once deployed, Vercel will give you a public URL (e.g., `https://flowtive-central.vercel.app`). Copy this URL.

**Final Backend Link-up:**
1. Go *back* to Railway.
2. Open your service -> **Variables**.
3. Update `ALLOWED_ORIGINS` to be your Vercel URL (e.g., `https://flowtive-central.vercel.app`). This secures your API so only your frontend can talk to it.

---

## Step 4: First Login & M-Pesa Configuration

Your app is now live!

1. Go to your Vercel URL (e.g., `https://flowtive-central.vercel.app`).
2. Log in using the default credentials:
   - **Username:** `admin`
   - **Password:** `Admin@123`
3. **Security Prompt:** The system will immediately force you to set a new password. Enter a strong password and sign in again.
4. Navigate to **ERP Hub -> Settings** in the sidebar.
5. Under **M-Pesa Integration**, change the mode from Manual to **Daraja API (Auto STK Push)**.
6. Enter your Safaricom Developer Portal (Daraja) credentials:
   - **Shortcode / Till Number**
   - **Passkey**
   - **Consumer Key**
   - **Consumer Secret**
7. Click **Save Settings**. These are immediately encrypted in your Supabase database using the `APP_SECRET` you set in Railway.

### You're Done! 🎉
You can now start adding products, creating staff accounts, and ringing up sales on any device. The PWA will allow you to "Install" the app directly to your phone's home screen.
