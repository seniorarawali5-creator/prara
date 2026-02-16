# Prashant App Architecture & Design Guide

## Architecture Overview

The Prashant app follows a clean, scalable architecture pattern with clear separation of concerns.

```
┌─────────────────────────────────────────────────┐
│              UI Layer (Screens)                 │
│  Splash → Auth → Navigation → Features          │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│         State Management Layer (GetX)           │
│  Controllers, Bindings, Routes                  │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│           Service Layer (Business Logic)        │
│  AuthService, ChatService, AnalyticsService    │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│         Data Layer (Models & Storage)           │
│  Firebase, Firestore, Local Storage             │
└─────────────────────────────────────────────────┘
```

## Project Structure Breakdown

### 1. **Main Entry Point** (`lib/main.dart`)
- App initialization
- GetX configuration
- Route setup
- Theme configuration

### 2. **Configuration** (`lib/config/`)
- `theme.dart`: Color schemes and typography
- `app_routes.dart`: Route definitions and navigation

### 3. **Models** (`lib/models/`)
Data classes representing app entities:
- `user_model.dart`: User information
- `study_session_model.dart`: Study tracking data
- `chat_message_model.dart`: Chat messages
- `note_model.dart`: Notes with metadata
- `story_model.dart`: Stories with expiry
- `friend_request_model.dart`: Friend requests

### 4. **Screens** (`lib/screens/`)
UI implementation organized by feature:
```
screens/
├── auth/
│   ├── splash_screen.dart          # Initial loading screen
│   ├── login_options_screen.dart   # Admin vs User choice
│   ├── login_screen.dart           # User login
│   ├── signup_screen.dart          # User registration
│   ├── forgot_password_screen.dart # Password recovery
│   └── admin_login_screen.dart     # Admin authentication
├── home/
│   └── home_screen.dart            # Main dashboard
├── chat/
│   └── chat_screen.dart            # Direct & group messaging
├── friends/
│   └── friends_screen.dart         # User discovery & management
├── notes/
│   └── notes_screen.dart           # Note management
├── analytics/
│   └── analytics_screen.dart       # Analytics & insights
├── stories/
│   └── stories_screen.dart         # 24-hour stories
├── settings/
│   └── settings_screen.dart        # User preferences
├── admin/
│   └── admin_dashboard_screen.dart # Admin analytics
└── main_navigation_screen.dart     # Bottom navigation controller
```

### 5. **Services** (`lib/services/`)
Business logic layer:
- `auth_service.dart`: Authentication & authorization
- `chat_service.dart`: Messaging functionality
- `analytics_service.dart`: Data analysis & insights

### 6. **Widgets** (`lib/widgets/`)
Reusable UI components (to be created as needed):
- Custom buttons
- Cards
- Dialogs
- Loading indicators

### 7. **Constants** (`lib/constants/`)
- `app_colors.dart`: Color palettes
- `app_strings.dart`: UI text strings
- `assets.dart`: Asset path constants

### 8. **Utils** (`lib/utils/`)
Utility functions:
- `formatters.dart`: Date, time, and number formatting

## Design Patterns

### 1. **Model-View-ViewModel (MVVM) Pattern**
- Models: Data classes with serialization
- Views: Stateful/Stateless widgets
- ViewModels: GetX Controllers (future implementation)

### 2. **Service Layer Pattern**
- Abstract service interfaces
- Concrete implementations
- Dependency injection via GetX

### 3. **Factory Pattern**
- Model factories for JSON parsing
- Service implementations

### 4. **Singleton Pattern**
- GetX services as singletons
- Shared preferences for local storage

## Navigation Flow

### Authentication Flow
```
SplashScreen
    ↓
LoginOptionsScreen
    ├→ LoginScreen → Home
    ├→ AdminLoginScreen → AdminDashboard
    └→ SignUpScreen → Home

ForgotPasswordScreen
    ↓
PasswordResetScreen
    ↓
LoginScreen
```

### Main App Flow (After Auth)
```
MainNavigationScreen (7-Tab Navigation)
├── Home (Daily Stats & Pie Charts)
├── Chat (Direct & Group Messaging)
├── Friends (User Discovery & Requests)
├── Notes (Create & Share Notes)
├── Stories (24-Hour Stories)
├── Analytics (Weekly/Monthly Comparisons)
└── Settings (Profile & Preferences)
```

### Tab Navigation Structure
```
┌────────────────────────────────────────┐
│         MainNavigationScreen           │
│  (Manages Bottom Navigation Index)     │
└────────┬───────────────────────────────┘
         │
    ┌────┴────┬──────┬────────┬───────┬─────────┬──────────┐
    │          │      │        │       │         │          │
   Home      Chat  Friends   Notes  Stories  Analytics  Settings
```

## State Management (GetX)

### Current Implementation
- Navigation via `Get.toNamed()`
- SnackBars via `Get.snackbar()`
- Dialogs via `Get.dialog()`

### Future Implementation (Recommended)
```dart
// Example Controller Structure
class HomeController extends GetxController {
  var screenTime = 0.0.obs;
  var studyHours = 0.0.obs;
  
  void updateStudyHours(double hours) {
    studyHours.value = hours;
    calculateProductivity();
  }
  
  void calculateProductivity() {
    // Logic here
  }
}
```

## Data Flow

### Study Session Update Flow
```
UI Input (Manual Entry)
    ↓
HomeScreen._handleAddStudyHours()
    ↓
Update local state
    ↓
Calculate productivity
    ↓
UI Rebuild (PieChart updates)
    ↓
(Future) Send to Firestore
```

### Chat Message Flow
```
User Types Message
    ↓
ChatService.sendMessage()
    ↓
Firebase Firestore (Real-time listener)
    ↓
Message appears in UI
    ↓
Mark as read
```

## Firebase Integration

### Firestore Collection Structure
```
users/
  ├── {userId}
  │   ├── email
  │   ├── fullName
  │   ├── profilePhotoUrl
  │   ├── bio
  │   └── createdAt

studySessions/
  ├── {sessionId}
  │   ├── userId
  │   ├── studyHours
  │   ├── screenTime
  │   ├── date
  │   └── productivityPercentage

messages/
  ├── {chatId}
  │   ├── senderId
  │   ├── receiverId
  │   ├── text
  │   ├── timestamp
  │   └── isRead

notes/
  ├── {noteId}
  │   ├── userId
  │   ├── title
  │   ├── content
  │   ├── visibility
  │   ├── sharedWithUsers
  │   └── createdAt

stories/
  ├── {storyId}
  │   ├── userId
  │   ├── content
  │   ├── createdAt
  │   ├── expiresAt
  │   └── viewedBy

friendRequests/
  ├── {requestId}
  │   ├── senderId
  │   ├── receiverId
  │   ├── status
  │   └── createdAt
```

## Error Handling Strategy

### Current Implementation
- Try-catch blocks in services
- SnackBar notifications for user feedback
- Graceful fallbacks

### Best Practices
1. Log errors to Crashlytics
2. Show appropriate user messages
3. Provide retry mechanisms
4. Track error patterns

## Performance Optimization

### UI Performance
- Page building happens once
- Scroll performance with `ListView.builder()`
- Image caching with `CachedNetworkImage`
- Lazy loading of tabs

### Data Performance
- Pagination for lists
- Efficient Firestore queries with indexes
- Local caching with Hive
- Debouncing for search

## Security Implementation

### Authentication
- Firebase Auth with email/password
- Role-based access control (Admin/User)
- Secure token storage

### Data Privacy
- Private notes with user selection
- Firestore security rules
- Encrypted network communication

## Testing Strategy

### Unit Tests
```dart
test('Calculate productivity correctly', () {
  double productivity = calculateProductivity(2.0, 4.0);
  expect(productivity, 33.33);
});
```

### Widget Tests
```dart
testWidgets('Login button triggers login', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.byIcon(Icons.login));
  await tester.pumpAndSettle();
});
```

## Deployment Considerations

### Android Build
- Sign APK/AAB with keystore
- Configure proguard rules
- Minimize APK size
- Test on various devices

### iOS Build  
- Certificate configuration
- Bundle ID setup
- Privacy permissions

## Future Architecture Improvements

1. **Repository Pattern**
   - Separate data layer completely
   - Multiple data sources support

2. **Dependency Injection**
   - GetIt for service locator
   - Automatic factory registration

3. **Event Bus**
   - App-wide event streaming
   - Better component communication

4. **Bloc Pattern**
   - Alternative to GetX for complex states
   - Better testability

5. **Feature-First Structure**
   - Organize by features instead of layers
   - Self-contained feature modules

## Code Style Guide

### Naming Conventions
- Classes: `PascalCase` (HomeScreen)
- Variables: `camelCase` (screenTime)
- Constants: `camelCase` (appName)
- Private: Prefix with `_` (_controller)

### Best Practices
1. Use const constructors
2. Dispose resources properly
3. Add comments for complex logic
4. Keep functions small and focused
5. Use meaningful variable names

---

**Last Updated**: February 2026
