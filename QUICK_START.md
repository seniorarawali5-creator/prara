# Prashant App - Quick Start Guide

Get the Prashant app running with Firebase in 15 minutes! 🚀

---

## Prerequisites
- Flutter SDK (3.0+) - [Install](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter extension
- Firebase account (free tier works)
- Git (for version control)

---

## Step 1: Clone & Setup Project (2 min)

```bash
# Navigate to project directory
cd c:\Users\skris\Desktop\kriara

# Install dependencies
flutter pub get

# Get Firebase plugins
flutter pub get
```

---

## Step 2: Create Firebase Project (3 min)

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name: `Prashant`
4. Uncheck "Enable Google Analytics" (for now)
5. Create project
6. Wait for initialization ⏳

---

## Step 3: Register Android App (3 min)

1. In Firebase Console, click **Add App** → **Android**
2. Package name: `com.prashant.app`
3. Click "Register app"
4. Download `google-services.json`
5. Place in: `android/app/google-services.json`
6. Click "Next" through remaining steps

---

## Step 4: Configure Firebase (2 min)

### Option A: Automatic (Recommended)
```bash
# Install flutterfire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=prashant
```

### Option B: Manual
1. Open `lib/config/firebase_options.dart`
2. Go to Firebase Console → Project Settings
3. Copy values from "Your apps" section
4. Paste into firebase_options.dart

---

## Step 5: Enable Services (3 min)

### Enable Authentication
1. Firebase Console → **Authentication**
2. Click "Get started"
3. Click on **Email/Password**
4. Toggle "Enable"
5. Click "Save"

### Enable Firestore
1. Firebase Console → **Firestore Database**
2. Click "Create database"
3. Select location nearest to you
4. Start in **Test mode**
5. Create

### Enable Storage
1. Firebase Console → **Storage**
2. Click "Get started"
3. Start in **Test mode**
4. Create

---

## Step 6: Deploy Security Rules (2 min)

### Firestore Rules
1. Firebase Console → **Firestore Database** → **Rules** tab
2. Replace all content with rules from `firestore.rules` file
3. Click **Publish**

### Storage Rules
1. Firebase Console → **Storage** → **Rules** tab  
2. Replace all content with rules from `firebase_storage.rules` file
3. Click **Publish**

---

## Step 7: Run the App (Remaining time)

```bash
# Start emulator (if not running)
flutter emulators --launch Pixel_5_API_33

# Run app in debug mode
flutter run

# Or run specific device
flutter run -d emulator-5554
```

---

## Step 8: Test Authentication

### Create Test Account
1. Open app on emulator/device
2. Go to **Signup** screen
3. Enter:
   - Email: `test@prashant.com`
   - Password: `Test@123`
   - Full Name: `Test User`
   - Mobile: `1234567890`
4. Click "Sign up"
5. Verify success ✅

### Verify in Firebase
1. Firebase Console → **Authentication**
2. Check new user appears in "Users" tab
3. Go to **Firestore Database** → `users` collection
4. Verify user document created with your data

---

## Step 9: Test Chat Feature

1. After signup, go to **Chat** tab
2. Start typing a message
3. Send message
4. Open Firebase Console → **Firestore** → `chats` collection
5. Verify message document created ✅

---

## Step 10: Test Analytics

1. Go to **Analytics** tab
2. You should see placeholder data
3. Go to **Notes** and create a note
4. Refresh Analytics
5. See note count update (once querying is setup)

---

## Common Issues & Fixes

### "google-services.json not found"
```bash
# Run configuration command
flutterfire configure --project=prashant

# If using manual: ensure file is in correct location
# Should be: android/app/google-services.json
```

### "Firebase initialization failed"
```bash
# Check firebase_options.dart has correct credentials
# Verify google-services.json copied to android/app/

# If still failing:
flutter clean
flutter pub get
flutter run
```

### "Permission denied" errors
```
Status: This is expected in Test Mode!
Solution: Deploy Firestore and Storage rules as shown in Step 6
```

### "Connection refused"
```
Solution: Ensure emulator is running or device is connected
Check: Run 'flutter devices' to see connected devices
```

---

## Next Steps

### After Basic Test (Optional)
1. **Add more test users** for chat testing
2. **Upload files** to Storage via Camera feature
3. **Create study sessions** to test Analytics
4. **Add friends** to test Friend feature
5. **Create stories** to test 24-hour expiry

### Before Production
1. Generate signing key for Play Store
2. Deploy Cloud Functions
3. Setup proper security rules (not test mode)
4. Configure Push Notifications (FCM)
5. Setup analytics tracking
6. Test thoroughly

---

## Useful Commands

```bash
# Run app
flutter run

# Run with specific device
flutter run -d emulator-5554

# Run on release mode
flutter run --release

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check connected devices
flutter devices

# View logs
flutter logs

# Build APK
flutter build apk --release

# Build for iOS
flutter build ios

# Format code
dart format .

# Analyze code
dart analyze
```

---

## Debugging Tips

### View Firebase Logs
```bash
# In Firebase Console
→ Functions → Logs (for cloud functions)
→ Firestore → View Metrics (for database)
→ Storage → Files (for uploads)
```

### Debug Authentication
```dart
// In Flutter code
final user = FirebaseAuth.instance.currentUser;
print('Logged in: $user');
print('UID: ${user?.uid}');
```

### Debug Firestore
```dart
// Enable Firestore debugging
FirebaseFirestore.instance.settings = 
  const Settings(persistenceEnabled: false);
```

### Check Network Activity
```
Android Studio → Logcat
Search: "Firebase" or "Firestore"
```

---

## Project Structure

```
lib/
├── main.dart                 ← Start here
├── config/
│   ├── firebase_options.dart ← Firebase config
│   ├── theme.dart
│   └── app_routes.dart
├── screens/
│   ├── auth/                 ← Login/Signup screens
│   ├── home/                 ← Main features
│   ├── chat/
│   ├── analytics/
│   └── ...
├── services/
│   ├── auth_service.dart     ← Authentication
│   ├── chat_service.dart     ← Messaging
│   ├── analytics_service.dart
│   └── database_service.dart
├── models/                   ← Data models
└── constants/                ← Colors, strings

android/
├── app/
│   └── google-services.json  ← Firebase config
└── build.gradle
```

---

## Account Credentials for Testing

**Test Admin:**
- Email: `admin@prashant.com`
- Password: `Admin@123`

**Test User 1:**
- Email: `user1@prashant.com`
- Password: `User1@123`

**Test User 2:**
- Email: `user2@prashant.com`
- Password: `User2@123`

---

## Need Help?

### Common Resources
- 📚 [Firebase Documentation](https://firebase.google.com/docs)
- 🐦 [Flutter Documentation](https://flutter.dev/docs)
- 💬 [Stack Overflow - Firebase Tag](https://stackoverflow.com/questions/tagged/firebase)
- 🔧 [FlutterFire Plugins](https://firebase.flutter.dev)

### Check These Files
- `FIREBASE_SETUP_GUIDE.md` - Detailed setup instructions
- `FIREBASE_INTEGRATION_SUMMARY.md` - Complete overview
- `ARCHITECTURE.md` - Project architecture
- `README.md` - Feature documentation

---

## Shortcuts

| Action | Command |
|--------|---------|
| Run app | `flutter run` |
| Hot reload | Press `r` in terminal |
| Hot restart | Press `R` in terminal |
| Stop app | Press `q` in terminal |
| Open logs | `flutter logs` |
| Open DevTools | `flutter pub global run devtools` |

---

## Success Checklist

- [ ] Flutter installed and working
- [ ] Firebase project created
- [ ] Android app registered
- [ ] google-services.json placed
- [ ] Authentication enabled
- [ ] Firestore database created
- [ ] Storage enabled
- [ ] Rules deployed
- [ ] App runs without errors
- [ ] Can create user account
- [ ] User appears in Firebase Console
- [ ] Can send message
- [ ] Message appears in Firestore

✅ **All checked? You're ready to develop!**

---

## Performance Tips

- Use Firestore indexes for complex queries
- Implement pagination for large datasets
- Cache user data locally with Hive
- Batch operations for multiple writes
- Use streams sparingly to save bandwidth

---

**Status:** Ready to Use ✅  
**Time to Setup:** ~15 minutes  
**Difficulty:** Beginner-Friendly  
**Support:** Full source code provided
