# Supabase Troubleshooting Guide 🔧

**For issues during Supabase setup & app testing**

---

## 🆘 Common Issues

---

### ❌ Issue 1: "Supabase URL not set"

**Error Message:**
```
Exception: Supabase URL is not set. Did you call Supabase.initialize()?
```

**Causes:**
- ❌ `supabase_options.dart` not updated with credentials
- ❌ Variables still contain "YOUR_SUPABASE_URL"
- ❌ App not waiting for Supabase initialization

**Fix:**
1. Open `lib/config/supabase_options.dart`
2. Replace `YOUR_SUPABASE_URL` with your actual URL:
   ```dart
   const String supabaseUrl = 'https://xxxxxxxxxxx.supabase.co';
   const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```
3. Save file
4. Run: `flutter clean`
5. Run: `flutter run`

**Verify:**
- In Supabase dashboard, go to **Settings** → **API**
- Copy exact Project URL (starts with `https://`)
- Copy Anon Key (long string starting with `eyJ`)

---

### ❌ Issue 2: "Cannot connect to Supabase"

**Error Message:**
```
Failed connecting to: https://xxxxxxxxx.supabase.co
The system cannot find the host specified
```

**Causes:**
- ❌ No internet connection
- ❌ Wrong URL format
- ❌ Region/project deleted
- ❌ Typo in URL

**Fix:**
1. Check internet connection: Open https://google.com in browser
2. Verify URL format - should be:
   - ✅ Correct: `https://xyz123.supabase.co`
   - ✅ Correct: `https://xyz123.asia.supabase.co`
   - ❌ Wrong: `https://supabase.co` (missing project ID)
   - ❌ Wrong: `supabase.co` (missing https://)
3. Copy-paste from Supabase dashboard (don't type manually)
4. Check Supabase project is active:
   - Go to Supabase dashboard
   - Verify project shows "Status: Active"

---

### ❌ Issue 3: "Authentication failed" or "Invalid credentials"

**Error Message:**
```
Invalid login credentials
```

**Causes:**
- ❌ Wrong email format
- ❌ Wrong password
- ❌ User doesn't exist yet (first time signup)
- ❌ Email provider not enabled

**Fix for Signup:**
1. Verify email format: Should be `name@domain.com`
2. Verify password: Should be at least 6 characters
3. Check Email provider enabled:
   - Supabase Dashboard → **Authentication** → **Providers**
   - Toggle **Email** to ON
   - Save changes

**Fix for Login:**
1. Check user exists:
   - Supabase Dashboard → **SQL Editor**
   - Run: `SELECT email FROM users;`
   - Verify email matches exactly
2. Password is case-sensitive
3. No spaces in password

**Test:**
1. Create NEW account (signup, not login)
2. Check table in SQL Editor
3. Should see user appear

---

### ❌ Issue 4: "Users table not found" or similar

**Error Message:**
```
relation "public.users" does not exist
```

**Causes:**
- ❌ Database tables not created
- ❌ Wrong table name in query
- ❌ Table exists but user doesn't have permission

**Fix:**
1. Create missing tables:
   - Go to Supabase Dashboard → **SQL Editor**
   - Copy-paste SQL from [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md) Step 3
   - Run each query

2. Verify tables exist:
   ```sql
   SELECT table_name FROM information_schema.tables 
   WHERE table_schema = 'public';
   ```
   Should show: `users`, `messages`, `study_sessions`, `stories`

3. Check table schema:
   ```sql
   \d users
   ```

---

### ❌ Issue 5: "Messages not showing up"

**Error Message:**
```
No messages in chat (but no error)
```

**Causes:**
- ❌ `messages` table not created
- ❌ chatId column not populated correctly
- ❌ Wrong chatId format
- ❌ Real-time subscription not working

**Fix:**
1. Create messages table:
   ```sql
   CREATE TABLE messages (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     chatId VARCHAR(255),
     groupId VARCHAR(255),
     senderId UUID REFERENCES users(id),
     receiverId UUID,
     text TEXT NOT NULL,
     isRead BOOLEAN DEFAULT FALSE,
     attachmentURL TEXT,
     createdAt TIMESTAMP DEFAULT NOW()
   );
   ```

2. Test by sending message and checking:
   ```sql
   SELECT * FROM messages WHERE chatId = 'test';
   ```

3. Verify column names match service code:
   - ✅ Should use: `chatId`, `senderId`, `text`, `createdAt`
   - ❌ Not: `chat_id`, `sender_id`, `message`, `created_at` (snake_case)

4. Check console logs:
   ```bash
   flutter logs
   ```
   Look for errors from `ChatService`

---

### ❌ Issue 6: "File upload fails"

**Error Message:**
```
Exception: Storage bucket not found
```

**Causes:**
- ❌ Storage buckets not created
- ❌ Bucket not public
- ❌ Insufficient permissions

**Fix:**
1. Create storage buckets:
   - Supabase Dashboard → **Storage**
   - Click **"New bucket"** for each:
     - `profiles`
     - `chats`
     - `stories`
   - Make them **PUBLIC**

2. Set bucket policies:
   - For each bucket → **Policies** → **New Policy**
   - Allow public read, authenticated write

3. Verify bucket exists:
   - Dashboard → Storage
   - Should see 3 buckets listed

4. Test upload:
   ```dart
   await supabase.storage
       .from('profiles')
       .upload('test.txt', File('test.txt'));
   ```

---

### ❌ Issue 7: "Type mismatch" errors

**Error Message:**
```
Unexpected null value
Instance of 'Null' error
```

**Causes:**
- ❌ Database schema doesn't match model expectations
- ❌ Column types wrong (VARCHAR vs UUID)
- ❌ NULL values where not expected
- ❌ JSON serialization mismatch

**Fix:**
1. Check User model vs users table:
   - Model expects: `id` (string), `email` (string), `fullName` (string)
   - Table should have these columns with matching types

2. Add column constraints:
   ```sql
   ALTER TABLE users MODIFY email VARCHAR(255) NOT NULL;
   ALTER TABLE messages MODIFY text TEXT NOT NULL;
   ```

3. Set default values:
   ```sql
   ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'user';
   ```

4. Check model JSON parsing:
   - Open `lib/models/user.dart`
   - Verify `fromJson()` handles all fields
   - Use `_notRequired()` for optional fields

---

### ❌ Issue 8: "Realtime not working" or messages not live

**Error Message:**
```
Stream not updating
Messages not appearing immediately
```

**Causes:**
- ❌ Realtime not enabled
- ❌ Wrong subscription pattern
- ❌ Broadcast not triggered
- ❌ Row-level security blocking updates

**Fix:**
1. Enable realtime on table:
   - Supabase Dashboard → **SQL Editor**
   - Run: `ALTER PUBLICATION supabase_realtime ADD TABLE messages;`

2. Verify subscription is correct:
   ```dart
   // ✅ Correct
   supabase
       .from('messages')
       .stream(primaryKey: ['id'])
       .listen((data) => print(data));
   
   // ❌ Wrong (not using stream)
   supabase.from('messages').select()
   ```

3. Check logs:
   ```bash
   flutter logs | grep -i stream
   ```

4. Verify RLS not blocking:
   - If using Row-Level Security policies
   - Make sure authenticated users can read/write

---

### ❌ Issue 9: "App crashes on startup"

**Error Message:**
```
Unhandled exception: ...
Process exited abnormally
```

**Causes:**
- ❌ Syntax error in code
- ❌ Missing import
- ❌ Supabase initialization not awaited
- ❌ Wrong configuration file path

**Fix:**
1. Check for errors:
   ```bash
   flutter doctor
   flutter pub get
   flutter clean
   ```

2. Check main.dart initialization is awaited:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     await Supabase.initialize(
       url: supabaseUrl,
       anonKey: supabaseAnonKey,
     );
     
     runApp(MyApp());
   }
   ```

3. Check console for actual error:
   ```bash
   flutter run -v
   ```
   Look for red error message

4. Verify pubspec.yaml:
   ```bash
   flutter pub get
   ```

---

### ❌ Issue 10: Dart/Flutter package errors

**Error Message:**
```
Package not found
Dependency version mismatch
```

**Causes:**
- ❌ `supabase_flutter` not installed
- ❌ pubspec.yaml has syntax error
- ❌ Version conflicts

**Fix:**
1. Clean and reinstall:
   ```bash
   cd C:\Users\skris\Desktop\kriara
   flutter clean
   flutter pub get
   ```

2. Check pubspec.yaml syntax:
   ```bash
   flutter pub get --verbose
   ```

3. Upgrade Flutter:
   ```bash
   flutter upgrade
   ```

4. Update package:
   ```bash
   flutter pub upgrade supabase_flutter
   ```

---

## 🔍 Debugging Tips

### Enable Verbose Logging

**View all logs:**
```bash
flutter logs
```

**Filter for errors:
```bash
flutter logs | grep -i error
```

**Run with verbose output:**
```bash
flutter run -v
```

### Check Supabase Console

**View all requests:**
1. Supabase Dashboard → **Logs** → **Database**
2. Check for SQL errors

**View realtime activity:**
1. Supabase Dashboard → **Logs** → **Realtime**
2. See subscriptions and broadcasts

### Test Queries Manually

**In SQL Editor:**
```sql
-- Test users table
SELECT * FROM users LIMIT 5;

-- Test messages table  
SELECT * FROM messages WHERE chatId = 'test';

-- Test if user exists
SELECT * FROM users WHERE email = 'test@example.com';
```

### Check Application State

**In main.dart, add debug print:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('📱 Initializing Supabase...');
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  print('✅ Supabase initialized!');
  print('URL: $supabaseUrl');
  
  runApp(MyApp());
}
```

---

## ✅ Self-Diagnosis Checklist

Before reporting issue:

- [ ] Supabase project is active (dashboard shows green)
- [ ] Internet connection works (can access google.com)
- [ ] ULR and key are correct (copy-pasted from Supabase)
- [ ] All required tables exist in database:
  - [ ] `users`
  - [ ] `messages`
  - [ ] `study_sessions`
  - [ ] `stories`
- [ ] Email provider is enabled in Authentication
- [ ] `flutter clean && flutter pub get` ran successfully
- [ ] No syntax errors: `flutter analyze`
- [ ] App runs: `flutter run`
- [ ] Can create account using the app
- [ ] Account appears in Supabase Dashboard SQL Editor

---

## 📞 Getting Help

### Check These First
1. [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md) - Step-by-step setup
2. [SUPABASE_QUICK_START.md](SUPABASE_QUICK_START.md) - Quick reference
3. This file - Troubleshooting guide

### Official Resources
- **Supabase Docs:** https://supabase.com/docs
- **Flutter Docs:** https://flutter.dev/docs
- **Dart Docs:** https://dart.dev/guides

### Community Help
- **Stack Overflow:** Tag `flutter` + `supabase`
- **GitHub Issues:** supabase/supabase repo
- **Using Questions:** 
  - Include exact error message
  - Include your Supabase version
  - Show what you tried
  - Provide code snippet if relevant

---

## 🚀 Once Working

When everything is working:
1. Test all features (signup, login, messages, analytics)
2. Check database has correct data
3. Try real-time features (send message, see it appear live)
4. Test on multiple devices/emulators
5. Deploy to TestFlight/Google Play when ready

---

**Most Common Issue:** Forgotten to update `supabase_options.dart`  
**Second Most Common:** Forgot to create database tables  
**Quick Diagnostic:** Run `SELECT * FROM users;` in SQL Editor

You got this! 💪
