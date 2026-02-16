# Prashant - Study & Social Platform 📚

**Status:** ✅ Supabase Migration 100% Complete  
**Backend:** Supabase (Firebase Alternative)  
**Cost:** Completely FREE - No credit card needed 💰

---

## 🎯 Quick Start (15 minutes)

### 1️⃣ Create Supabase Account (2 min)
```bash
Go to: https://supabase.com
Sign up with Google/GitHub
Already have account? Skip to step 2
```

### 2️⃣ Create Project (3 min)
- Click **"New project"**
- Name: `prashant`
- Region: Closest to you
- Click **"Create"**

### 3️⃣ Get Credentials (1 min)
- Settings → API
- Copy "Project URL"
- Copy "Anon Key"

### 4️⃣ Add to App (1 min)
Open `lib/config/supabase_options.dart`:
```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';        // Paste here
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Paste here
```

### 5️⃣ Create Database Tables (5 min)
Go to Supabase **SQL Editor**, copy-paste and run:

```sql
CREATE TABLE users (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), email VARCHAR(255) UNIQUE NOT NULL, fullName VARCHAR(255), mobileNumber VARCHAR(20), role VARCHAR(50) DEFAULT 'user', photoURL TEXT, isDarkMode BOOLEAN DEFAULT FALSE, createdAt TIMESTAMP DEFAULT NOW(), updatedAt TIMESTAMP DEFAULT NOW());
CREATE INDEX idx_users_email ON users(email);

CREATE TABLE messages (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), chatId VARCHAR(255), groupId VARCHAR(255), senderId UUID REFERENCES users(id) ON DELETE CASCADE, receiverId UUID, text TEXT NOT NULL, isRead BOOLEAN DEFAULT FALSE, attachmentURL TEXT, createdAt TIMESTAMP DEFAULT NOW());
CREATE INDEX idx_messages_chatId ON messages(chatId);
CREATE INDEX idx_messages_groupId ON messages(groupId);
CREATE INDEX idx_messages_senderId ON messages(senderId);

CREATE TABLE study_sessions (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), userId UUID REFERENCES users(id) ON DELETE CASCADE, subject VARCHAR(255), duration INTEGER, productivity FLOAT, notes TEXT, createdAt TIMESTAMP DEFAULT NOW());
CREATE INDEX idx_study_sessions_userId ON study_sessions(userId);

CREATE TABLE stories (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), userId UUID REFERENCES users(id) ON DELETE CASCADE, imageURL TEXT, caption TEXT, views INTEGER DEFAULT 0, createdAt TIMESTAMP DEFAULT NOW(), expiresAt TIMESTAMP);
CREATE INDEX idx_stories_userId ON stories(userId);
```

### 6️⃣ Install & Run (2 min)
```bash
cd C:\Users\skris\Desktop\kriara
flutter clean
flutter pub get
flutter run
```

### 7️⃣ Test It! ✅
- Create account in app
- Go to Supabase dashboard
- SQL Editor: `SELECT * FROM users;`
- Should see your new user!

---

## 📚 Documentation

### Getting Started
- **[SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md)** - Detailed step-by-step guide (30 min)
- **[SUPABASE_QUICK_START.md](SUPABASE_QUICK_START.md)** - Quick reference checklist (15 min)
- **[SUPABASE_TROUBLESHOOTING.md](SUPABASE_TROUBLESHOOTING.md)** - Fix common issues 🔧

### Migration Info
- **[FIREBASE_TO_SUPABASE_MIGRATION.md](FIREBASE_TO_SUPABASE_MIGRATION.md)** - What changed & why

### Code Structure
```
lib/
├── main.dart                          ✅ Supabase initialized
├── config/
│   ├── supabase_options.dart         🔴 ADD YOUR CREDENTIALS HERE
│   ├── routes.dart
│   └── theme.dart
├── services/
│   ├── auth_service.dart             ✅ Supabase Auth
│   ├── chat_service.dart             ✅ Supabase Messages
│   ├── analytics_service.dart        ✅ Supabase Study Sessions
│   ├── database_service.dart         ✅ Generic Supabase CRUD
│   └── storage_service.dart
├── models/
│   ├── user.dart
│   ├── chat_message.dart
│   ├── study_session.dart
│   └── story.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── dashboard_screen.dart
│   ├── chat/
│   │   ├── chat_list_screen.dart
│   │   └── chat_detail_screen.dart
│   ├── analytics/
│   │   └── analytics_screen.dart
│   └── /* ... other screens ... */
├── widgets/
└── utils/
```

---

## ✨ Features

### 🔐 Authentication
- ✅ Email/Password signup
- ✅ Email/Password login
- ✅ Password reset
- ✅ Session management
- ✅ Logout

### 💬 Messaging
- ✅ 1-on-1 direct messages
- ✅ Group chats
- ✅ Real-time message delivery
- ✅ Message read status
- ✅ File attachments
- ✅ Message search

### 📊 Analytics
- ✅ Daily study sessions
- ✅ Weekly/monthly stats
- ✅ Average study time
- ✅ Productivity tracking
- ✅ Screen time monitoring

### 📱 User Features
- ✅ User profiles
- ✅ Profile pictures
- ✅ Stories (like Instagram)
- ✅ Friend requests
- ✅ Dark mode
- ✅ Notifications

---

## 🔧 Backend Services

### `auth_service.dart`
Handles authentication:
```dart
AuthService.login(email, password)
AuthService.signup(email, password, fullName, mobileNumber)
AuthService.logout()
AuthService.resetPassword(email)
AuthService.getCurrentUser()
AuthService.updateProfile(user)
AuthService.authStateChanges() // Stream of auth state
```

### `chat_service.dart`
Handles messaging:
```dart
ChatService.getDirectMessages(userId, peerId)
ChatService.getGroupMessages(groupId)
ChatService.sendMessage(message)
ChatService.sendGroupMessage(message, groupId)
ChatService.getDirectMessagesStream(userId, peerId) // Real-time
ChatService.getGroupMessagesStream(groupId) // Real-time
ChatService.markAsRead(messageId)
ChatService.searchMessages(query, userId)
```

### `analytics_service.dart`
Handles study tracking:
```dart
AnalyticsService.getDailyAnalytics(date)
AnalyticsService.getWeeklyAnalytics(startDate)
AnalyticsService.getMonthlyAnalytics(month, year)
AnalyticsService.getAverageStudyHours(startDate, endDate)
AnalyticsService.getAverageScreenTime(startDate, endDate)
AnalyticsService.calculateProductivity(studyHours, screenTime)
```

### `database_service.dart`
Generic database operations:
```dart
DatabaseService.createDocument(table, data, documentId)
DatabaseService.readDocument(table, documentId)
DatabaseService.updateDocument(table, documentId, data)
DatabaseService.deleteDocument(table, documentId)
DatabaseService.queryDocuments(table, field, value, orderBy, descending, limit)
DatabaseService.streamDocuments(table)
DatabaseService.countDocuments(table, field, value)
DatabaseService.documentExists(table, documentId)
DatabaseService.getWhere(table, filters)
```

---

## 🗄️ Database Schema

### Users Table
```sql
id              UUID (primary key)
email           VARCHAR (unique)
fullName        VARCHAR
mobileNumber    VARCHAR
role            VARCHAR (default: 'user')
photoURL        TEXT
isDarkMode      BOOLEAN
createdAt       TIMESTAMP
updatedAt       TIMESTAMP
```

### Messages Table
```sql
id              UUID (primary key)
chatId          VARCHAR (for direct messages)
groupId         VARCHAR (for group messages)
senderId        UUID (foreign key → users)
receiverId      UUID (for direct messages)
text            TEXT
isRead          BOOLEAN
attachmentURL   TEXT
createdAt       TIMESTAMP
```

### Study Sessions Table
```sql
id              UUID (primary key)
userId          UUID (foreign key → users)
subject         VARCHAR
duration        INTEGER (minutes)
productivity    FLOAT (0-100)
notes           TEXT
createdAt       TIMESTAMP
```

### Stories Table
```sql
id              UUID (primary key)
userId          UUID (foreign key → users)
imageURL        TEXT
caption         TEXT
views           INTEGER
createdAt       TIMESTAMP
expiresAt       TIMESTAMP
```

---

## 🚀 Getting Started

### Prerequisites
- ✅ Flutter 3.0+
- ✅ Dart 3.0+
- ✅ Android Studio or VS Code
- ✅ iOS (Mac only) or Android emulator/device

### Installation

1. **Clone or download the project**
   ```bash
   cd C:\Users\skris\Desktop\kriara
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase credentials**
   - Follow "Quick Start" section above
   - Edit `lib/config/supabase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

### First Time Setup

1. App launches → Signup Screen
2. Create account (email, password, name, mobile)
3. Login with new account
4. Explore dashboard
5. Send test message
6. Check analytics

---

## 🔐 Security Notes

### Credentials
- **Never commit** `supabase_options.dart` to git with real credentials
- **Keep anon key secret** (use environment variables in production)
- **Database password** - Save it, you'll need it for admin access

### Row-Level Security (RLS)
- Users can only access their own data
- Custom policies enforce security
- No data leaks between users

### Best Practices
1. Always use HTTPS (Supabase enforces this)
2. Never expose service role key (admin key)
3. Implement proper authentication
4. Use RLS policies for all tables
5. Validate data server-side

---

## 🛠️ Development

### Hot Reload
```bash
# While app is running:
flutter run
# Press 'r' to reload
# Press 'R' to hot restart
```

### View Logs
```bash
flutter logs
```

### Connect Supabase Tools
1. Go to **Supabase Dashboard** → **SQL Editor**
2. Run custom SQL queries
3. View real-time logs
4. Check storage files

### Debugging
```bash
# Run with verbose output
flutter run -v

# Check for issues
flutter doctor

# Analyze code
flutter analyze
```

---

## 🚀 Production

### Before Deploying

- [ ] Test signup/login thoroughly
- [ ] Test messaging with multiple users
- [ ] Test analytics functionality
- [ ] Test file uploads
- [ ] Check Supabase storage buckets
- [ ] Enable CORS if needed
- [ ] Set up email templates
- [ ] Configure RLS policies
- [ ] Enable auto backups

### Environment Variables

Create `.env` file:
```
SUPABASE_URL=your_url_here
SUPABASE_ANON_KEY=your_anon_key_here
```

Load in app:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
String url = dotenv.env['SUPABASE_URL']!;
```

### Performance

- ✅ Real-time subscriptions auto-managed
- ✅ Database indexed for fast queries
- ✅ Images cached locally
- ✅ Pagination for message lists
- ✅ Search optimized

---

## 📊 Key Metrics

- **Users**: Unlimited
- **Messages**: Unlimited
- **Storage**: 500 MB (expandable)
- **Database**: 500 MB (expandable)
- **Real-time**: Unlimited concurrent connections
- **API Calls**: Unlimited
- **Cost**: $0 (free tier)

---

## 🆘 Need Help?

1. **Quick issues:** Check [SUPABASE_TROUBLESHOOTING.md](SUPABASE_TROUBLESHOOTING.md)
2. **Setup help:** Check [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md)
3. **Quick reference:** Check [SUPABASE_QUICK_START.md](SUPABASE_QUICK_START.md)
4. **Migration details:** Check [FIREBASE_TO_SUPABASE_MIGRATION.md](FIREBASE_TO_SUPABASE_MIGRATION.md)

---

## 📱 Supported Platforms

- ✅ Android 5.0+
- ✅ iOS 11.0+
- ✅ Windows 10+
- ✅ macOS 10.13+
- ✅ Linux (Ubuntu 20.04+)

---

## 🎉 You're All Set!

Your Supabase backend is ready to go! 

**Next Steps:**
1. ✅ Read docs above (start with SUPABASE_QUICK_START.md)
2. ✅ Create Supabase account
3. ✅ Set up database tables
4. ✅ Add credentials to app
5. ✅ Run the app
6. ✅ Test features
7. ✅ Start building! 🚀

---

## 📝 License

This project is part of the Prashant Study Platform.

---

## 👥 Contributors

- Your name here

---

## 📞 Support

- **Discord:** (Add your community server)
- **Email:** (Add support email)
- **GitHub Issues:** (Add repo link)

---

**Happy coding! 🎉**

Built with ❤️ using Flutter + Supabase
