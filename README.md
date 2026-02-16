# Prashant - Productivity & Social Accountability App

A modern Flutter application that combines personal productivity tracking with social features for accountability and motivation.

## 🎯 App Features

### 1. **Authentication System**
- **Landing Screen**: Choose between Admin or User login
- **User Login**: Email + Password authentication
- **User Sign Up**: Email, Mobile, Full Name, Password
- **Forgot Password**: Email-based password recovery
- **Admin Login**: Special admin interface for analytics and user management
- **Role-based Access**: Admin and User roles with different permissions

### 2. **Screen Time Tracking**
- Automatic daily mobile screen usage tracking
- Display today's, weekly, and monthly screen time statistics
- Integration with Android Usage Stats API
- Visual representation with charts

### 3. **Home Screen (Core Feature)**
- Manual entry of daily study hours
- Auto-calculated remaining hours (24h - screen time)
- Visual analytics with pie charts:
  - Daily progress breakdown
  - Weekly trends
  - Monthly comparison
- Productivity percentage calculation

### 4. **Chat Section**
- **Direct Messaging**:
  - One-to-one chats with read status
  - Text messages
  - Image/PDF/File sharing
  - Online status indicator
  
- **Group Chat**:
  - Create and manage groups
  - Add/remove members
  - Group messaging

### 5. **Friends Section**
- Browse all registered users
- Send/Accept/Reject friend requests
- View mutual friends count
- Online status indicator
- Quick access to chat with friends
- Friend request management with notifications

### 6. **Notes Section**
- Create and manage notes
- Upload notes, images, and PDFs
- Visibility options:
  - **Public**: Visible to all users
  - **Private**: Only selected users can view
- Share notes with specific users
- Filter by visibility type
- View note metadata (author, creation date, attachments)

### 7. **Analytics Dashboard**
- **Weekly View**:
  - Study hours vs Screen time comparison
  - Daily breakdown
  - Trend analysis

- **Monthly View**:
  - Week-by-week comparison
  - Performance summaries
  - Productivity insights

### 8. **Stories Feature**
- Upload image/text stories like Instagram
- Stories visible for 24 hours
- View status tracking
- Social sharing of daily achievements

### 9. **Settings**
- Edit profile information
- Change password
- Upload profile photo
- Dark/Light mode toggle
- Push notification preferences
- About & Legal documents
- Logout functionality

### 10. **Admin Dashboard**
- View total registered users
- Track active vs inactive users
- Average screen time across platform
- Average study hours statistics
- Recent users list
- User distribution charts
- User management capabilities

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point
├── config/
│   ├── theme.dart                     # Theme configuration
│   └── app_routes.dart                # Route management
├── models/
│   ├── user_model.dart
│   ├── study_session_model.dart
│   ├── chat_message_model.dart
│   ├── note_model.dart
│   ├── story_model.dart
│   └── friend_request_model.dart
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── login_options_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── admin_login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── chat/
│   │   └── chat_screen.dart
│   ├── friends/
│   │   └── friends_screen.dart
│   ├── notes/
│   │   └── notes_screen.dart
│   ├── analytics/
│   │   └── analytics_screen.dart
│   ├── stories/
│   │   └── stories_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   ├── admin/
│   │   └── admin_dashboard_screen.dart
│   └── main_navigation_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── analytics_service.dart
│   └── chat_service.dart
├── widgets/
│   └── [Reusable components]
├── utils/
│   └── [Helper functions]
└── constants/
    ├── colors.dart
    ├── strings.dart
    └── assets.dart
```

## 🎨 UI/UX Features

- **Modern Minimal Design**: Clean interface with intuitive navigation
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Gradient Cards**: Beautiful gradient backgrounds
- **Rounded Corners**: Soft, modern UI elements
- **Color Scheme**:
  - Primary: Indigo (#6366F1)
  - Secondary: Violet (#8B5CF6)
  - Tertiary: Pink (#EC4899)
  - Success: Green (#10B981)
  - Warning: Amber (#F59E0B)

- **Bottom Navigation**: 7-tab navigation for easy access
  - Home
  - Chat
  - Friends
  - Notes
  - Stories
  - Analytics
  - Settings

## 🛠 Tech Stack

- **Frontend**: Flutter 3.0+
- **State Management**: Provider + GetX
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Charts**: FL Chart
- **Local Storage**: Shared Preferences, Hive
- **Notifications**: Firebase Messaging, Flutter Local Notifications
- **Threading**: Dart async/await

## 📱 Dependencies

Key packages used:
- `firebase_auth`: Authentication
- `firebase_firestore`: Real-time database
- `firebase_storage`: File storage
- `fl_chart`: Beautiful charts
- `GetX`: State management & routing
- `image_picker`: Media selection
- `file_picker`: File handling
- `cached_network_image`: Image caching
- `intl`: Internationalization
- `app_usage`: Screen time tracking

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/prashant.git
   cd prashant
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Create a Firebase project
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)
   - Place in respective platform folders

4. **Run the app**
   ```bash
   flutter run
   ```

## 📊 Screen Time Tracking Integration

The app uses Android's Usage Stats API to:
- Fetch hourly screen usage data
- Track app-specific usage
- Display today's, weekly, and monthly statistics
- Calculate productivity metrics

## 🔐 Security Features

- Email/Password authentication via Firebase
- Role-based access control
- Private/Public note visibility
- Selected user sharing for notes
- Secure file storage with Firebase

## 📈 Analytics Implementation

- Real-time study hour tracking
- Screen time correlation analysis
- Weekly and monthly trend visualization
- Personal productivity scoring
- Comparative analytics dashboard (Admin)

## 🎯 Future Enhancements

- [ ] Social media integration (Share achievements)
- [ ] Leaderboard system
- [ ] AI-powered productivity insights
- [ ] Video streaming for study sessions
- [ ] Integration with popular learning platforms
- [ ] Push notifications for reminders
- [ ] Voice messages in chat
- [ ] GIF/Emoji support
- [ ] Report generation
- [ ] Premium features

## 📝 Dummy Data

All screens include realistic dummy data for testing:
- Sample users with online status
- Study session data
- Chat conversations
- Notes with various visibility levels
- Stories with expiry dates
- Analytics data for visualization

## 🔄 State Management Flow

```
User Input → Controller/Service → Model Update → UI Rebuild
```

All screens use GetX for:
- Simple state management
- Route navigation
- Dependency injection
- SnackBars and dialogs

## 📱 App Navigation

The app uses a 7-tab bottom navigation system:

1. **Home**: Daily tracking and pie charts
2. **Chat**: Direct and group messaging
3. **Friends**: User discovery and management
4. **Notes**: Create and share notes
5. **Stories**: 24-hour stories like Instagram
6. **Analytics**: Weekly/monthly comparisons
7. **Settings**: User preferences and profile

## 🎓 Learning Resources

This app demonstrates:
- Flutter best practices
- Firebase integration
- GetX state management
- Complex UI layouts
- Data visualization with FL Chart
- Authentication flows
- Real-time features

## 📄 License

This project is open source and available under the MIT License.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support, email support@prashant.app or open an issue on GitHub.

---

**Built with ❤️ for productivity and accountability**
