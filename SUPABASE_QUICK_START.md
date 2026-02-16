# Supabase Quick Start Checklist ⚡

**Time:** 10-15 minutes | **Difficulty:** Easy | **Cost:** FREE

---

## 🚀 5-Minute Quick Start

### Step 1: Create Supabase Account (2 min)
- [ ] Go to https://supabase.com
- [ ] Click "Sign up"
- [ ] Use Google/GitHub (easiest)
- [ ] Verify email

### Step 2: Create Project (3 min)
- [ ] Click "New project"
- [ ] Name: `prashant`
- [ ] Database password: Create strong one
- [ ] Region: Closest to you
- [ ] Click "Create"

### Step 3: Get Credentials (1 min)
- [ ] Go to **Settings** → **API**
- [ ] Copy "Project URL" (https://xxxxx.supabase.co)
- [ ] Copy "Anon Key" (long text string)

### Step 4: Add to Flutter App (1 min)
- [ ] Open `lib/config/supabase_options.dart`
- [ ] Replace `YOUR_SUPABASE_URL` with Project URL
- [ ] Replace `YOUR_SUPABASE_ANON_KEY` with Anon Key
- [ ] Save file ✅

### Step 5: Create Database Tables (5 min)
Go to **SQL Editor** in Supabase, copy-paste each SQL block and run:

#### Copy-Paste 1: Users Table
```sql
CREATE TABLE users (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), email VARCHAR(255) UNIQUE NOT NULL, fullName VARCHAR(255), mobileNumber VARCHAR(20), role VARCHAR(50) DEFAULT 'user', photoURL TEXT, isDarkMode BOOLEAN DEFAULT FALSE, createdAt TIMESTAMP DEFAULT NOW(), updatedAt TIMESTAMP DEFAULT NOW());
CREATE INDEX idx_users_email ON users(email);
```

#### Copy-Paste 2: Messages Table
```sql
CREATE TABLE messages (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), chatId VARCHAR(255), groupId VARCHAR(255), senderId UUID REFERENCES users(id) ON DELETE CASCADE, receiverId UUID, text TEXT NOT NULL, isRead BOOLEAN DEFAULT FALSE, attachmentURL TEXT, createdAt TIMESTAMP DEFAULT NOW());
CREATE INDEX idx_messages_chatId ON messages(chatId);
CREATE INDEX idx_messages_groupId ON messages(groupId);
CREATE INDEX idx_messages_senderId ON messages(senderId);
```

#### Copy-Paste 3: Study Sessions Table
```sql
CREATE TABLE study_sessions (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), userId UUID REFERENCES users(id) ON DELETE CASCADE, subject VARCHAR(255), duration INTEGER, productivity FLOAT, notes TEXT, createdAt TIMESTAMP DEFAULT NOW());
CREATE INDEX idx_study_sessions_userId ON study_sessions(userId);
```

#### Copy-Paste 4: Stories Table
```sql
CREATE TABLE stories (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), userId UUID REFERENCES users(id) ON DELETE CASCADE, imageURL TEXT, caption TEXT, views INTEGER DEFAULT 0, createdAt TIMESTAMP DEFAULT NOW(), expiresAt TIMESTAMP);
CREATE INDEX idx_stories_userId ON stories(userId);
```

### Step 6: Install Flutter Package
```bash
cd C:\Users\skris\Desktop\kriara
flutter pub get
```

### Step 7: Run App 🎉
```bash
flutter clean
flutter run
```

### Step 8: Test Signup ✅
- Open app
- Create account with test email
- Check Supabase Console → **SQL Editor**:
```sql
SELECT * FROM users;
```
Should see your new user!

---

## 🔑 Credential Locations

### Where to Find Your Credentials in Supabase

1. **Project URL**
   - Dashboard → Settings → API
   - Look for: "Project URL"
   - Starts with: `https://`

2. **Anon Key**
   - Dashboard → Settings → API  
   - Look for: "Anon public"
   - Long string starting with `eyJ`

3. **Database Password**
   - Used during project setup
   - Needed if resetting database

---

## 📱 What Each File Does

| File | Purpose | Status |
|------|---------|--------|
| `lib/config/supabase_options.dart` | Credentials | **YOU UPDATE** ⚠️ |
| `lib/main.dart` | App initialization | ✅ Already updated |
| `lib/services/auth_service.dart` | Login/Signup | ✅ Already updated |
| `lib/services/chat_service.dart` | Messages | ✅ Already updated |
| `lib/services/analytics_service.dart` | Study stats | ✅ Already updated |
| `lib/services/database_service.dart` | DB operations | ✅ Already updated |

---

## 🔐 DON'T

- ❌ Don't commit credentials to git
- ❌ Don't share Anon Key publicly
- ❌ Don't use same password as other accounts
- ❌ Don't lose database password

---

## ✅ DO

- ✅ Enable Email authentication (Settings → Auth)
- ✅ Create all 4 tables
- ✅ Test signup before using app
- ✅ Keep credentials in `.env` file (optional)

---

## 🆘 If Something Goes Wrong

### App crashes on startup
**Fix:** Check `supabase_options.dart` credentials are correct

### Signup fails
**Fix:** 
1. Check email is valid format
2. Check Email provider is enabled in Supabase

### Messages won't send
**Fix:**
1. Verify `messages` table exists
2. Check user is logged in

### Storage upload fails
**Fix:**
1. Create storage buckets in Supabase
2. Set bucket to public

---

## 📊 Database Tables Quick Reference

```
users          → Store user profiles
messages       → Chat messages & attachments
study_sessions → Study tracking data
stories        → User stories/updates
```

---

## 🎯 What's Free

- ✅ Unlimited projects
- ✅ Unlimited database
- ✅ Unlimited storage
- ✅ Real-time subscriptions
- ✅ 50,000 monthly active users
- ✅ 500 MB storage
- ✅ Forever free tier

**No credit card needed!**

---

## 📞 Need Help?

1. **Read full guide**: Open `SUPABASE_SETUP_GUIDE.md`
2. **Check Supabase Docs**: https://supabase.com/docs
3. **Check Flutter logs**: `flutter logs`
4. **Test in SQL Editor**: Run queries manually

---

**Status:** Ready to go! 🚀  
Follow steps 1-8 above, takes ~15 minutes total.
