# Firebase Integration Setup Guide

## Overview
This guide walks you through setting up Firebase for the Prashant app with complete authentication, Firestore database, and Storage integration.

## Prerequisites
- Firebase Project created at [console.firebase.google.com](https://console.firebase.google.com)
- Flutter project with Firebase plugins configured
- Android Studio or any IDE with Flutter support

---

## Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
1. Visit https://console.firebase.google.com
2. Click "Add project"
3. Name it "Prashant"
4. Accept terms and create project
5. Wait for project initialization (2-3 minutes)

### 1.2 Enable Google Analytics (Optional)
- Choose "Enable Google Analytics for this project" during creation
- Select or create a Google Analytics account

---

## Step 2: Register Apps with Firebase

### 2.1 Add Android App
1. In Firebase Console, click **Add app** → select **Android**
2. Enter package name: `com.prashant.app` (or your preferred name)
3. Click "Register app"
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`
6. Follow setup instructions shown on screen

### 2.2 Add iOS App (if targeting iOS)
1. Click **Add app** → select **iOS**
2. Enter Bundle ID: `com.example.prashant` (or your preferred)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Follow setup instructions

### 2.3 Add Web App (Optional)
1. Click **Add app** → select **Web**
2. Copy the Firebase config
3. Update `lib/config/firebase_options.dart` with web credentials

---

## Step 3: Update Firebase Options

### 3.1 Get Firebase Credentials
1. Go to Firebase Console → Project Settings (gear icon)
2. Under "Your apps" section, find your Android app
3. Copy these values:
   - API Key
   - Project ID
   - Storage Bucket
   - Sender ID (Cloud Messaging)

### 3.2 Update firebase_options.dart
```dart
// Run: flutterfire configure
// OR manually update lib/config/firebase_options.dart with:

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'prashant',
  storageBucket: 'prashant.appspot.com',
);
```

### 3.3 Use FlutterFire CLI (Recommended)
```bash
# Install flutterfire CLI
dart pub global activate flutterfire_cli

# Configure for all platforms
flutterfire configure --project=prashant
```

---

## Step 4: Enable Firebase Services

### 4.1 Enable Authentication
1. Go to **Authentication** in Firebase Console
2. Click **Get started**
3. Enable **Email/Password** provider:
   - Click on Email/Password
   - Toggle "Enable"
   - Toggle "Enable email link sign in" (optional)
   - Save
4. Enable **Anonymous** provider (optional):
   - Click on Anonymous
   - Toggle "Enable"
   - Save

### 4.2 Enable Google Sign-In (Optional)
1. Click on **Google**
2. Toggle "Enable"
3. Select support email
4. Save

### 4.3 Configure Email Action Templates (Send Password Reset Emails)
1. Go to **Authentication** → **Templates**
2. Update email templates if needed
3. These handle password reset, email verification, etc.

---

## Step 5: Setup Firestore Database

### 5.1 Create Firestore Database
1. Go to **Firestore Database** in Firebase Console
2. Click **Create database**
3. Select location: Choose closest region to users
4. Start in **Test mode** (later move to Production)
5. Wait for database initialization

### 5.2 Deploy Security Rules
1. Go to **Firestore Database** → **Rules** tab
2. Replace all content with rules from `firestore.rules` file
3. Click **Publish**

### 5.3 Create Collections Structure
Run this Dart command to initialize collections:
```dart
// In your app after authentication
final db = FirebaseFirestore.instance;
final userId = FirebaseAuth.instance.currentUser?.uid;

// Create user document (auto-created by auth_service)
// Create empty subcollections to define structure
await db
    .collection('users')
    .doc(userId)
    .collection('study_sessions')
    .doc('__init__')
    .set({'_': true});

await db
    .collection('users')
    .doc(userId)
    .collection('screen_time')
    .doc('__init__')
    .set({'_': true});
```

**Collections to Create:**
- `users` - User profiles
- `chats` - Direct messages
- `groups` - Group conversations  
- `stories` - User stories
- `friend_requests` - Friend request tracking
- `friendships` - Accepted friendships
- `notifications` - User notifications

---

## Step 6: Setup Firebase Storage

### 6.1 Enable Storage
1. Go to **Storage** in Firebase Console
2. Click **Get started**
3. Start in **Test Mode** initially
4. Select storage location (same as Firestore)
5. Create storage

### 6.2 Deploy Storage Rules
1. Go to **Storage** → **Rules** tab
2. Replace content with rules from `firebase_storage.rules`
3. Click **Publish**

### 6.3 Create Storage Buckets Structure
```
users/
  {userId}/
    profile_picture/
chats/
  {chatId}/
    attachments/
groups/
  {groupId}/
    attachments/
stories/
  {userId}/
notes/
  {userId}/
    {noteId}/
      attachments/
temp/
  {userId}/
```

---

## Step 7: Setup Firebase Cloud Messaging (FCM)

### 7.1 Enable Cloud Messaging
1. Go to **Cloud Messaging** in Firebase Console
2. Copy **Sender ID** - you'll need this

### 7.2 Configure Android
1. In `android/app/build.gradle`, ensure Firebase dependency is present:
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.2.1'
    implementation platform('com.google.firebase:firebase-bom:32.2.0')
}
```

2. Update `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <!-- FCM Receiver -->
    <service
        android:name=".services.FirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

### 7.3 Get FCM Token in App
```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
// Save to user document for sending notifications
```

---

## Step 8: Deploy Cloud Functions (Optional)

### 8.1 Setup Cloud Functions
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Navigate to project directory
cd your-flutter-project

# Initialize functions
firebase init functions

# Select "TypeScript"
```

### 8.2 Deploy Functions
1. Copy code from `cloud_functions_reference.ts`
2. Replace `functions/src/index.ts`
3. Install dependencies:
```bash
cd functions
npm install
```

4. Deploy:
```bash
firebase deploy --only functions
```

---

## Step 9: Setup Android Configuration

### 9.1 Update android/app/build.gradle
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-auth:22.1.2'
    implementation 'com.google.firebase:firebase-firestore:24.7.1'
    implementation 'com.google.firebase:firebase-storage:20.2.1'
    implementation 'com.google.firebase:firebase-messaging:23.2.1'
    implementation platform('com.google.firebase:firebase-bom:32.2.0')
}

apply plugin: 'com.google.gms.google-services'
```

### 9.2 Update android/build.gradle
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

### 9.3 Permissions - android/app/src/main/AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

---

## Step 10: Initialize Firebase in Flutter

### 10.1 Update main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize other services
  setupServiceLocator();
  
  runApp(const MyApp());
}
```

### 10.2 Setup Service Locator
```dart
void setupServiceLocator() {
  // Register Firebase services as singletons
  GetIt.instance.registerSingleton<AuthService>(
    AuthServiceImpl(),
  );
  GetIt.instance.registerSingleton<ChatService>(
    ChatServiceImpl(),
  );
  GetIt.instance.registerSingleton<AnalyticsService>(
    AnalyticsServiceImpl(),
  );
  GetIt.instance.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}
```

---

## Step 11: Test Firebase Integration

### 11.1 Run the App
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on emulator/device
flutter run
```

### 11.2 Test Authentication
1. Open app
2. Go to Signup screen
3. Create account with email: `test@prashant.com`
4. Password: `Test@123456`
5. Verify user appears in Firebase Console → Authentication

### 11.3 Test Firestore
1. After signup, check Firebase Console
2. Go to Firestore Database
3. Verify `users` collection has your new user document
4. Check `users/{userId}` document shows:
   - `email`
   - `fullName`
   - `mobileNumber`
   - `role: "user"`
   - `createdAt`

### 11.4 Monitor in Real-time
Use Firebase Console to:
- Watch Firestore collections update
- View Authentication users
- Monitor Cloud Functions logs
- Check Storage uploads

---

## Step 12: Move to Production (Security)

### 12.1 Update Security Rules to Production
**IMPORTANT:** Test mode rules allow anyone to read/write. Update to production:

1. Go to Firestore Database → Rules
2. Deploy rules from `firestore.rules` (already done)
3. Same for Storage → Rules

### 12.2 Generate and Upload Signing Key for Android

```bash
# Generate keystore (run once)
keytool -genkey -v -keystore ~/key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload-key

# Create signing properties file
# android/key.properties
storeFile=/path/to/key.jks
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload-key
```

### 12.3 Update android/app/build.gradle
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

---

## Step 13: Build APK for Release

### 13.1 Build Release APK
```bash
flutter build apk --release --split-per-abi
```

### 13.2 Build App Bundle for Play Store
```bash
flutter build appbundle --release
```

Output files:
- APK: `build/app/outputs/apk/release/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## Common Firebase Issues & Solutions

### Issue: "google-services.json not found"
**Solution:**
```bash
# Run flutterfire configure
flutterfire configure --project=prashant
```

### Issue: "Permission denied" Firestore errors
**Solution:**
- Check Security Rules are properly deployed
- Verify user is authenticated
- In test mode temporarily to debug

### Issue: "API key not valid" errors
**Solution:**
- Re-download google-services.json
- Clear Android build cache: `./gradlew clean`
- Rebuild: `flutter clean && flutter pub get`

### Issue: Storage upload fails
**Solution:**
- Check Storage Rules are deployed
- Verify user has write permissions for that path
- Check file size is under limit

---

## Important Security Reminders

✅ **DO:**
- Keep private keys secret
- Use environment variables for sensitive data
- Deploy security rules before going live
- Enable Firebase Admin verification when needed
- Rate limit API calls
- Use HTTPS only

❌ **DON'T:**
- Commit API keys to version control
- Use test mode rules in production
- Store sensitive data in client-side code
- Share Firebase project credentials
- Enable anonymous write access in production

---

## Monitoring & Debugging

### View Real-time Logs
```bash
# Firebase Cloud Functions logs
firebase functions:log

# Firebase console logs
# Go to: Functions → Logs
```

### Monitor Database Performance
Firebase Console → Performance:
- Query latency
- Database size
- Read/write operations

### Setup Debugging in Flutter
Add to `main.dart`:
```dart
if (kDebugMode) {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

---

## Next Steps

1. ✅ Complete all 13 steps above
2. ✅ Test app thoroughly with Firebase backend
3. ✅ Implement remaining features (screen time API)
4. ✅ Add more Cloud Functions as needed
5. ✅ Setup analytics tracking
6. ✅ Deploy to Play Store
7. ✅ Monitor production app health

---

## Useful Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Plugins](https://firebase.flutter.dev)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)

---

**Status:** Complete Firebase setup with production-ready configuration
**Last Updated:** 2024
**Maintained By:** Prashant Development Team
