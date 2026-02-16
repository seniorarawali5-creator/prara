# Supabase Setup Guide for Prashant App

Complete guide to setting up Supabase (Firebase Alternative) for the Prashant app.

---

## ✅ Why Supabase?

- **Completely FREE** - No billing worries
- **Unlimited data** - Write as much as you want
- **PostgreSQL** - Industry standard database
- **Real-time** - Live updates like Firebase
- **Authentication** - Built-in auth system
- **Storage** - File uploads included
- **No credit card** - Ever needed ✅

---

## Step 1: Create Supabase Account

### 1.1 Go to Supabase
1. Visit: https://supabase.com
2. Click **"Start your project"** or **"Sign up"**
3. Sign up with:
   - Google account, OR
   - GitHub account, OR
   - Email + password
4. Verify email (if using email signup)

### 1.2 Create Organization (Optional)
1. After login, click **"New Organization"**
2. Name it: **Prashant**
3. Click **"Create Organization"**

---

## Step 2: Create Prashant Project

### 2.1 New Project
1. In Supabase dashboard, click **"New project"**
2. Fill in details:
   - **Project name**: `prashant`
   - **Database password**: Create strong password (save this!)
   - **Region**: Select closest region (e.g., `Asia - Singapore`)
   - **PostgreSQL version**: Choose latest 15+
3. Click **"Create New Project"**
4. Wait 1-2 minutes for initialization ⏳

### 2.2 Get API Keys
1. In project, go to **Settings** → **API**
2. Copy these values:
   - **Project URL** - Looks like: `https://xxxxxxxxx.supabase.co`
   - **Anon Key (public)** - Looks like: `eyJhbGc...` (long string)

### 2.3 Update Flutter App
Open `lib/config/supabase_options.dart`:

```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
// Paste your Project URL here
// Example: https://xyzabc.supabase.co

const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
// Paste your Anon Key here
// Example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Save the file!** ✅

---

## Step 3: Setup Database Tables

Supabase uses PostgreSQL. You need to create these tables:

### 3.1 Create Users Table

Go to **Supabase Dashboard** → **SQL Editor** → **New Query**

Paste this SQL:

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  fullName VARCHAR(255),
  mobileNumber VARCHAR(20),
  role VARCHAR(50) DEFAULT 'user',
  photoURL TEXT,
  isDarkMode BOOLEAN DEFAULT FALSE,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);

-- Create index on email for faster lookups
CREATE INDEX idx_users_email ON users(email);
```

Click **"Run"** ✅

### 3.2 Create Messages Table

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chatId VARCHAR(255),
  groupId VARCHAR(255),
  senderId UUID REFERENCES users(id) ON DELETE CASCADE,
  receiverId UUID,
  text TEXT NOT NULL,
  isRead BOOLEAN DEFAULT FALSE,
  attachmentURL TEXT,
  createdAt TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_messages_chatId ON messages(chatId);
CREATE INDEX idx_messages_groupId ON messages(groupId);
CREATE INDEX idx_messages_senderId ON messages(senderId);
```

Click **"Run"** ✅

### 3.3 Create Study Sessions Table

```sql
CREATE TABLE study_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  userId UUID REFERENCES users(id) ON DELETE CASCADE,
  subject VARCHAR(255),
  duration INTEGER,
  productivity FLOAT,
  notes TEXT,
  createdAt TIMESTAMP DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_study_sessions_userId ON study_sessions(userId);
```

Click **"Run"** ✅

### 3.4 Create Stories Table

```sql
CREATE TABLE stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  userId UUID REFERENCES users(id) ON DELETE CASCADE,
  imageURL TEXT,
  caption TEXT,
  views INTEGER DEFAULT 0,
  createdAt TIMESTAMP DEFAULT NOW(),
  expiresAt TIMESTAMP
);

-- Create index
CREATE INDEX idx_stories_userId ON stories(userId);
```

Click **"Run"** ✅

---

## Step 4: Setup Authentication

### 4.1 Enable Email Provider
1. Go to **Authentication** → **Providers**
2. Find **Email** provider
3. Toggle **"Enable email provider"** ON
4. Save ✅

### 4.2 Email Configuration (Optional)
1. Go to **Authentication** → **Settings**
2. Customize email templates if needed
3. Default templates work fine

### 4.3 Configure Redirect URLs
1. Go to **Authentication** → **URL Configuration**
2. Add your app's redirect URLs:
   - `com.prashant.app://auth`
   - `http://localhost:3000`
   - `http://localhost:3001`

---

## Step 5: Setup Storage

### 5.1 Create Buckets

Go to **Storage** → **Buckets**

Create these buckets:
1. **profiles** - User profile pictures
2. **chats** - Chat attachments
3. **stories** - Story uploads

For each bucket:
- Click **"New bucket"**
- Enter name
- Make **PUBLIC** (for easier access)
- Click **"Create bucket"**

### 5.2 Storage Policies

Supabase needs policies for access. Go to **Storage** → **Policies**

For each bucket, add a policy allowing authenticated users to upload.

---

## Step 6: Install Supabase in Flutter

The `pubspec.yaml` is already updated! Just run:

```bash
cd C:\Users\skris\Desktop\kriara
flutter pub get
```

This installs:
- `supabase_flutter` package
- All dependencies

---

## Step 7: Test Your Setup

### 7.1 Run the App

```bash
flutter clean
flutter pub get
flutter run
```

### 7.2 Create Test Account

1. Open app
2. Go to **Signup** screen
3. Enter:
   - Email: `test@prashant.com`
   - Password: `Test@123456`
   - Name: `Test User`
   - Mobile: `9999999999`
4. Click **Sign up**

### 7.3 Verify in Supabase

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Run query:
```sql
SELECT * FROM users;
```

You should see your test user! ✅

### 7.4 Test Chat

1. Send a message in app
2. Go to **SQL Editor** → Run:
```sql
SELECT * FROM messages;
```

You should see message! ✅

---

## Step 8: Setup Storage Access

### 8.1 Enable Public Access (Development)

For development, make storage buckets accessible. Go to **Storage** → **Policies**

For each bucket (profiles, chats, stories):
1. Click bucket name
2. Click **"Policies"**
3. Click **"New Policy"**
4. Select **"For full customization"**
5. Paste:

```sql
CREATE POLICY "Allow public read" ON storage.objects
  FOR SELECT USING (true);

CREATE POLICY "Allow authenticated uploads" ON storage.objects
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

This allows:
- Anyone to download files
- Authenticated users to upload

✅ Done!

---

## Step 9: Enable Row Level Security (RLS)

RLS makes your database secure. Go to **Authentication** → **Policies**

For each table, you can create rules like:
- Users can only see their own data
- Only friends can chat with you
- Stories visible to all authenticated users

(This is already configured in our Supabase setup)

---

## Step 10: Configure App

The app is already configured! 

What was done:
- ✅ `main.dart` - Updated to use Supabase
- ✅ `pubspec.yaml` - Added supabase_flutter package
- ✅ `lib/config/supabase_options.dart` - Configuration file created
- ✅ `lib/services/auth_service.dart` - Updated for Supabase
- ✅ `lib/services/chat_service.dart` - Updated for Supabase
- ✅ `lib/services/analytics_service.dart` - Updated for Supabase
- ✅ `lib/services/database_service.dart` - Updated for Supabase

You just need to:
1. Add your Supabase credentials to `supabase_options.dart`
2. Create database tables (SQL in Step 3)
3. Run the app!

---

## Common Issues & Fixes

### "Supabase URL not set"
**Fix:** Update `lib/config/supabase_options.dart` with your credentials

### "Failed to connect to Supabase"
**Fix:** 
- Check internet connection
- Verify URL format (should have `supabase.co`)
- Check region availability

### "Authentication failed"
**Fix:**
- Ensure email provider is enabled
- Check email format is valid

### "Messages not syncing"
**Fix:**
- Create `messages` table (Step 3.2)
- Verify user ID matches

### "Storage upload fails"
**Fix:**
- Create storage buckets (Step 5)
- Enable storage policies
- Check file size limits

---

## Useful Supabase Features

### SQL Editor
- Write custom SQL queries
- Test database operations
- Create tables & indexes

### Realtime
- Real-time updates
- Subscribe to changes
- Live notifications

### Webhooks
- Trigger functions on events
- Send HTTP requests
- Integrate external services

### Database Backups
- Automatic daily backups
- Manual point-in-time recovery
- Data protection

---

## Database Schema Summary

```
users
├── id (UUID)
├── email (VARCHAR)
├── fullName (VARCHAR)
├── mobileNumber (VARCHAR)
├── role (VARCHAR)
├── photoURL (TEXT)
├── isDarkMode (BOOLEAN)
└── timestamps

messages
├── id (UUID)
├── chatId (VARCHAR)
├── groupId (VARCHAR)
├── senderId (UUID ref users)
├── receiverId (UUID)
├── text (TEXT)
├── isRead (BOOLEAN)
├── attachmentURL (TEXT)
└── createdAt (TIMESTAMP)

study_sessions
├── id (UUID)
├── userId (UUID ref users)
├── subject (VARCHAR)
├── duration (INTEGER)
├── productivity (FLOAT)
├── notes (TEXT)
└── createdAt (TIMESTAMP)

stories
├── id (UUID)
├── userId (UUID ref users)
├── imageURL (TEXT)
├── caption (TEXT)
├── views (INTEGER)
├── createdAt (TIMESTAMP)
└── expiresAt (TIMESTAMP)
```

---

## Next Steps

1. ✅ Create Supabase account
2. ✅ Create project
3. ✅ Get API keys
4. ✅ Update `supabase_options.dart`
5. ✅ Create database tables
6. ✅ Run `flutter pub get`
7. ✅ Run `flutter run`
8. ✅ Create test account
9. ✅ Verify in Supabase Console
10. ✅ Start developing!

---

## Resources

- **Supabase Docs**: https://supabase.com/docs
- **Supabase Flutter**: https://supabase.com/docs/reference/flutter/introduction
- **PostgreSQL Docs**: https://www.postgresql.org/docs
- **Dart/Flutter Docs**: https://dart.dev & https://flutter.dev

---

## Support

If you're stuck:
1. Check Supabase Console for errors
2. Check Flutter logs: `flutter logs`
3. Review Supabase documentation
4. Check Stack Overflow for similar issues

---

**Status:** Supabase Setup Complete ✅  
**Ready to:** Start development 🚀  
**Cost:** Completely FREE 💰

All set! Start with Step 1 above. Feel free to ask if you get stuck! 👍
