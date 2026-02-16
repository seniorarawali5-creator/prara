# Prashant Quick Reference Guide

## App Routes Quick Reference

| Screen Name | Route | File Location | Status |
|---|---|---|---|
| Splash | `/splash` | `screens/auth/splash_screen.dart` | ✅ Implemented |
| Login Options | `/login_options` | `screens/auth/login_options_screen.dart` | ✅ Implemented |
| User Login | `/login` | `screens/auth/login_screen.dart` | ✅ Implemented |
| Sign Up | `/signup` | `screens/auth/signup_screen.dart` | ✅ Implemented |
| Forgot Password | `/forgot_password` | `screens/auth/forgot_password_screen.dart` | ✅ Implemented |
| Admin Login | `/admin_login` | `screens/auth/admin_login_screen.dart` | ✅ Implemented |
| Home (Main) | `/home` | `screens/main_navigation_screen.dart` | ✅ Implemented |
| Admin Dashboard | `/admin_dashboard` | `screens/admin/admin_dashboard_screen.dart` | ✅ Implemented |
| Direct Chat | `/direct_chat` | Placeholder | 🔄 To Implement |
| Group Chat | `/group_chat` | Placeholder | 🔄 To Implement |
| New Chat | `/new_chat` | Placeholder | 🔄 To Implement |
| Note Detail | `/note_detail` | Placeholder | 🔄 To Implement |
| Create Note | `/create_note` | Placeholder | 🔄 To Implement |
| View Story | `/view_story` | Placeholder | 🔄 To Implement |
| Create Story | `/create_story` | Placeholder | 🔄 To Implement |
| Edit Profile | `/edit_profile` | Placeholder | 🔄 To Implement |
| Change Password | `/change_password` | Placeholder | 🔄 To Implement |

## Navigation in Code

```dart
// Navigate to screen
Get.toNamed('/home');

// Navigate with arguments
Get.toNamed('/direct_chat', arguments: chatData);

// Go back
Get.back();

// Replace current screen
Get.offNamed('/login');

// Clear all routes and go to new
Get.offAllNamed('/home');
```

## Bottom Navigation Tabs

```
0. Home (HomeScreen)
1. Chat (ChatScreen)
2. Friends (FriendsScreen)
3. Notes (NotesScreen)
4. Stories (StoriesScreen)
5. Analytics (AnalyticsScreen)
6. Settings (SettingsScreen)
```

## Key Dependencies

```yaml
# State Management & Navigation
GetX: ^4.6.5

# Firebase Services
firebase_auth: ^4.10.0
firebase_core: ^2.20.0
firebase_firestore: ^4.13.0
firebase_storage: ^11.2.0

# UI Components
fl_chart: ^0.63.0
shimmer: ^3.0.0
lottie: ^2.4.0

# Data Storage
shared_preferences: ^2.2.0
hive: ^2.2.3

# Media Handling
image_picker: ^1.0.4
file_picker: ^6.0.0
cached_network_image: ^3.3.0

# Utilities
intl: ^0.19.0
uuid: ^4.0.0
```

## Color Palette

| Color | Hex | Usage |
|---|---|---|
| Primary | #6366F1 | Main buttons, headers |
| Secondary | #8B5CF6 | Secondary actions |
| Tertiary | #EC4899 | Attention, highlights |
| Success | #10B981 | Positive feedback |
| Warning | #F59E0B | Warnings, cautions |
| Error | #EF4444 | Errors, deletions |
| Dark BG | #0F172A | Dark theme background |
| Light BG | #FAFAFA | Light theme background |

## Common Widget Patterns

### User Avatar
```dart
CircleAvatar(
  radius: 28,
  backgroundColor: Colors.blue,
  child: Text('A'), // User initial
)
```

### Card
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
  ),
  child: // content
)
```

### Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF6366F1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: Text('Button Text'),
)
```

### Input Field
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Hint text',
    prefixIcon: Icon(Icons.email),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
    ),
  ),
)
```

## Common Snackbars

```dart
// Success
Get.snackbar('Success', 'Operation completed',
    backgroundColor: Colors.green, colorText: Colors.white);

// Error
Get.snackbar('Error', 'Something went wrong',
    backgroundColor: Colors.red, colorText: Colors.white);

// Info
Get.snackbar('Info', 'Information message',
    backgroundColor: Colors.blue, colorText: Colors.white);
```

## Common Dialogs

```dart
// Confirmation Dialog
Get.dialog(
  AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
      ElevatedButton(onPressed: () { /* action */ Get.back(); }, child: Text('Confirm')),
    ],
  ),
);

// Loading Dialog
Get.dialog(
  Dialog(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),
    ),
  ),
  barrierDismissible: false,
);
```

## File Organization Best Practices

```
prashant/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── config/
│   │   ├── theme.dart
│   │   └── app_routes.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── assets.dart
│   ├── models/
│   │   └── [all model files]
│   ├── screens/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── chat/
│   │   ├── friends/
│   │   ├── notes/
│   │   ├── analytics/
│   │   ├── stories/
│   │   ├── settings/
│   │   ├── admin/
│   │   └── main_navigation_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── chat_service.dart
│   │   └── analytics_service.dart
│   ├── widgets/
│   │   └── [reusable components]
│   └── utils/
│       └── formatters.dart
├── assets/
│   ├── images/
│   ├── animations/
│   ├── icons/
│   └── fonts/
├── test/
├── android/
├── ios/
├── pubspec.yaml
├── README.md
├── ARCHITECTURE.md
├── DEVELOPMENT_GUIDE.md
├── FEATURES.md
└── analysis_options.yaml
```

## Keyboard Shortcuts

| Action | Shortcut |
|---|---|
| Hot Reload | `R` |
| Hot Restart | `r` |
| Open DevTools | `d` |
| Quit | `q` |
| Toggle Dart DevTools | `v` |
| View Device Log | `L` |

## Debugging Commands

```bash
# Verbose output
flutter run -v

# Run with profiling
flutter run --profile

# Run in release mode
flutter run --release

# Check connected devices
flutter devices

# Check app setup
flutter doctor

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build
flutter clean
```

## Testing Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/user_model_test.dart

# Run with coverage
flutter test --coverage

# Run with verbose output
flutter test -v
```

## Building Commands

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release
```

## Common Code Snippets

### Responsive Layout
```dart
// Get screen dimensions
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;
final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

// Responsive padding
final padding = screenWidth < 600 ? 12.0 : 24.0;
```

### Date Formatting
```dart
import 'package:intl/intl.dart';

// Format date
String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.now());

// Format time
String formattedTime = DateFormat('HH:mm').format(DateTime.now());
```

### JSON Serialization
```dart
// Convert object to JSON
Map<String, dynamic> json = user.toJson();

// Convert JSON to object
User user = User.fromJson(jsonData);
```

## Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)
- [Material Design](https://material.io/design)

## Performance Tips

1. **Use `const` constructors** wherever possible
2. **Use `ListView.builder()`** for large lists
3. **Cache network images** with `CachedNetworkImage`
4. **Minimize widget rebuilds** with proper state management
5. **Use `shouldRebuild()` method** to prevent unnecessary rebuilds
6. **Profile with DevTools** to find performance bottlenecks

## Security Checklist

- [ ] API keys stored securely (not in code)
- [ ] Firebase security rules configured
- [ ] User input validated on client and server
- [ ] Sensitive data encrypted
- [ ] SSL certificate pinning implemented
- [ ] Network traffic uses HTTPS
- [ ] User authentication required for sensitive operations
- [ ] Rate limiting implemented

---

**Version**: 1.0.0  
**Last Updated**: February 2026  
**Status**: Development Phase
