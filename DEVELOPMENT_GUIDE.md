# Prashant Development Guide

## Prerequisites

Before you start developing, ensure you have:

- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: 3.0 or higher
- **Android Studio** or **VS Code** with Flutter extension
- **Xcode** (for iOS development, macOS only)
- **Firebase Account** (for backend services)
- **Git** (for version control)

## Environment Setup

### 1. Install Flutter

**Windows:**
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to a folder (e.g., C:\flutter)
# Add to PATH environment variable
# Run doctor to verify installation
flutter doctor
```

**macOS:**
```bash
# Using homebrew
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install/macos
# Extract to a folder (e.g., ~/Developer/flutter)
# Add to PATH in ~/.zshrc or ~/.bash_profile
export PATH="$PATH:$HOME/Developer/flutter/bin"
```

**Linux:**
```bash
# Install dependencies
sudo apt-get install git curl unzip xz-utils

# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz

# Extract and add to PATH
tar xf flutter_linux_3.x.x-stable.tar.xz
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
```

### 2. Setup Android Development

```bash
# Check Flutter setup
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses

# Create Android emulator
flutter emulators create --name default

# Run emulator
flutter emulators launch default
```

### 3. Setup iOS Development (macOS only)

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Verify setup
flutter doctor
```

### 4. Setup Firebase

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project "Prashant"
   - Enable Firestore Database
   - Enable Storage
   - Enable Authentication (Email/Password method)

2. **Android Setup**:
   ```bash
   # Download google-services.json from Firebase Console
   # Place in: android/app/google-services.json
   ```

3. **iOS Setup**:
   ```bash
   # Download GoogleService-Info.plist from Firebase Console
   # Place in: ios/Runner/GoogleService-Info.plist
   ```

## Project Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/prashant.git
cd prashant
```

### 2. Install Dependencies

```bash
# Get all pub packages
flutter pub get

# Upgrade packages
flutter pub upgrade

# Run code generation (if needed)
flutter pub run build_runner build
```

### 3. Check Setup

```bash
# Verify project setup
flutter doctor

# Check for analysis errors
flutter analyze
```

## Development Workflow

### Running the App

```bash
# Run on Android emulator
flutter run

# Run with verbose output
flutter run -v

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test

# Generate coverage report
flutter test --coverage
```

### Hot Reload

During development:
- Press `r` to hot reload
- Press `R` to hot restart
- Use Android Studio's hot reload button

## Creating New Screens

### 1. Create New Screen File

```dart
import 'package:flutter/material.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Screen'),
      ),
      body: const Center(
        child: Text('Your content here'),
      ),
    );
  }
}
```

### 2. Add Route

```dart
// In lib/config/app_routes.dart
GetPage(
  name: '/new_screen',
  page: () => const NewScreen(),
),
```

### 3. Navigate to Screen

```dart
// In any screen
Get.toNamed('/new_screen');
```

## Adding New Features

### Adding a Service

```dart
// lib/services/new_service.dart
abstract class NewService {
  Future<void> doSomething();
}

class NewServiceImpl implements NewService {
  @override
  Future<void> doSomething() async {
    // Implementation
  }
}
```

### Adding a Model

```dart
// lib/models/new_model.dart
class NewModel {
  final String id;
  final String name;

  NewModel({required this.id, required this.name});

  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

## Debugging

### Enable Logging

```dart
// In any file
import 'package:logger/logger.dart';

final logger = Logger();

// Use in code
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Use Debugger

```bash
# Run with debugging
flutter run

# Set breakpoints in VS Code or Android Studio
# Use debug console to inspect variables
```

### Visual Debugging

```dart
// Add debug borders to widgets
debugPaintBaselinesEnabled = true;
debugPaintLayersEnabled = true;

// Use Flutter DevTools
flutter pub global activate devtools
devtools
```

## Testing

### Write Unit Tests

```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    test('login returns user', () async {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage
```

## Building Release

### Android APK

```bash
# Build APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk

# Build AAB for Play Store
flutter build appbundle --release

# AAB location: build/app/outputs/bundle/release/app-release.aab
```

### iOS App

```bash
# Build iOS app
flutter build ios --release

# Build for App Store
flutter build ios --release --no-codesign
```

## Troubleshooting

### Common Issues

**Issue**: Flutter commands not found
```bash
# Solution: Add Flutter to PATH
# Windows: Add C:\flutter\bin to Environment Variables
# macOS/Linux: Add to ~/.bashrc or ~/.zshrc
```

**Issue**: Gradle errors on Android
```bash
# Solution: Clear cache
flutter clean
rm -rf android/.gradle
flutter pub get
flutter run
```

**Issue**: Pod install errors on iOS
```bash
# Solution: Update pods
cd ios
pod repo update
pod install --repo-update
cd ..
flutter run
```

**Issue**: Build cache issues
```bash
# Solution: Deep clean
flutter clean
flutter pub get
flutter run
```

## Performance Tips

1. **Use const constructors** - Reduces widget rebuilds
2. **Use ListView.builder** - For large lists instead of Column
3. **Lazy load data** - Load on demand, not all at once
4. **Cache network images** - Use CachedNetworkImage
5. **Minimize rebuilds** - Use keys and proper state management

## Code Organization Tips

1. **Keep files small** - Max 500 lines per file
2. **Group related code** - Put models together, services together
3. **Use consistent naming** - Follow Dart conventions
4. **Add documentation** - Comment complex logic
5. **Separate concerns** - UI, logic, data layers

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Dart Language Guide](https://dart.dev/guides)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)

## Getting Help

1. Check existing GitHub issues
2. Search Stack Overflow with [flutter] tag
3. Ask in Flutter Community Discord
4. File Issue with reproduction steps

---

Happy Coding! 🚀
