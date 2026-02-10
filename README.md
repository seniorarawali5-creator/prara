# Study Buddy - Educational Collaboration Platform

एक व्यापक शिक्षा सहयोग प्लेटफॉर्म जहाँ आप और आपके दोस्त मिलकर पढ़ाई कर सकते हैं, एक दूसरे को ट्रैक कर सकते हैं, और अपनी प्रगति साझा कर सकते हैं।

## Features (सुविधाएं)

### 🔐 Authentication
- Real signup/signin system
- JWT token-based authentication
- Secure password hashing with bcryptjs

### 📚 Activity Management
- Add daily study activities
- Track subjects and topics studied
- Monitor study duration
- Categorize activities (study, exercise, project, etc.)

### 📊 Analytics
- Weekly study analytics
- Monthly progress reports
- Subject-wise study breakdown
- Group performance comparison
- Visual charts and graphs

### 🎯 Goals Management
- Set weekly and monthly goals
- Track goal progress
- Monitor goal completion
- Update goal status

### 📝 Shared Notes
- Create and manage personal notes
- Share notes with friends
- Organize notes by subject
- Edit and delete notes

### 📸 Memories
- Share photos and memories
- Build a study journey album
- View friends' memories (if friends)
- Organize memories by date

### 💬 Real-time Chat
- Direct messaging with friends
- Socket.io powered real-time updates
- Message history
- Typing indicators
- Unread message count

### 👥 Friends System
- Add and manage friends
- Friend requests (pending/accepted)
- Search for users
- View friends' analytics
- Compare progress with friends

---

## Project Structure

```
kriara/
├── backend/                   # Node.js + Express Server
│   ├── config/
│   │   └── database.js       # Database connection
│   ├── database/
│   │   └── schema.sql        # PostgreSQL schema
│   ├── middleware/
│   │   └── auth.js           # JWT authentication
│   ├── routes/
│   │   ├── auth.js           # Sign in/up
│   │   ├── activities.js      # Activity CRUD
│   │   ├── goals.js          # Goals CRUD
│   │   ├── notes.js          # Notes sharing
│   │   ├── memories.js       # Image uploads
│   │   ├── messages.js       # Chat
│   │   ├── users.js          # Friends management
│   │   └── analytics.js      # Analytics
│   ├── utils/
│   │   └── auth.js           # Password hashing, JWT
│   ├── server.js             # Main server file
│   ├── package.json
│   └── .env                  # Environment variables
│
└── frontend/                  # React Native App
    ├── src/
    │   ├── api/
    │   │   └── client.js      # API requests
    │   ├── context/
    │   │   └── AuthContext.js # Authentication state
    │   ├── navigation/
    │   │   └── Navigation.js   # App navigation
    │   ├── screens/
    │   │   ├── auth/
    │   │   │   ├── SigninScreen.js
    │   │   │   └── SignupScreen.js
    │   │   └── app/
    │   │       ├── HomeScreen.js
    │   │       ├── AddActivityScreen.js
    │   │       ├── AnalyticsScreen.js
    │   │       ├── NotesScreen.js
    │   │       ├── AddNoteScreen.js
    │   │       ├── MemoriesScreen.js
    │   │       ├── ChatListScreen.js
    │   │       ├── ChatScreen.js
    │   │       └── FriendsScreen.js
    ├── App.js                 # Entry point
    ├── app.json               # Expo configuration
    ├── package.json
    └── .env                   # Environment variables
```

---

## Setup Instructions

### Prerequisites
- Node.js (v14 or higher)
- PostgreSQL (v12 or higher)
- Expo CLI (`npm install -g expo-cli`)
- React Native development tools

### Backend Setup

1. **Install Dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Setup Database**
   - Create a PostgreSQL database named `study_buddy`
   - Run the schema file:
     ```bash
     psql -U postgres -d study_buddy -f database/schema.sql
     ```

3. **Configure Environment**
   - Edit `.env` file:
     ```
     DB_HOST=localhost
     DB_USER=postgres
     DB_PASSWORD=your_password
     DB_NAME=study_buddy
     DB_PORT=5432
     JWT_SECRET=your_secret_key_change_in_production
     PORT=5000
     ```

4. **Start Server**
   ```bash
   npm run dev   # Development with auto-reload
   # or
   npm start     # Production
   ```
   Server will run on `http://localhost:5000`

### Frontend Setup

1. **Install Dependencies**
   ```bash
   cd frontend
   npm install
   ```

2. **Configure Environment**
   - Edit `.env` file:
     ```
     API_BASE_URL=http://your_machine_ip:5000
     SOCKET_URL=http://your_machine_ip:5000
     ```

3. **Start App**
   ```bash
   npm start                  # Start Expo
   npx expo start --web       # Web version
   npx react-native run-android  # Android
   npx react-native run-ios   # iOS (Mac only)
   ```

---

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create account
- `POST /api/auth/signin` - Login

### Activities
- `POST /api/activities` - Add activity
- `GET /api/activities` - Get activities
- `PUT /api/activities/:id` - Update activity
- `DELETE /api/activities/:id` - Delete activity

### Goals
- `POST /api/goals` - Create goal
- `GET /api/goals` - Get goals
- `PUT /api/goals/:id/progress` - Update progress
- `PUT /api/goals/:id/status` - Update status
- `DELETE /api/goals/:id` - Delete goal

### Notes
- `POST /api/notes` - Create note
- `GET /api/notes` - Get user's notes
- `GET /api/notes/shared` - Get shared notes
- `POST /api/notes/:id/share` - Share note
- `PUT /api/notes/:id` - Update note
- `DELETE /api/notes/:id` - Delete note

### Memories
- `POST /api/memories` - Upload memory
- `GET /api/memories` - Get user's memories
- `GET /api/memories/friend/:friendId` - Get friend's memories
- `DELETE /api/memories/:id` - Delete memory

### Messages
- `POST /api/messages` - Send message
- `GET /api/messages/conversation/:userId` - Get conversation
- `GET /api/messages` - Get all conversations
- `GET /api/messages/unread/count` - Get unread count
- `DELETE /api/messages/:id` - Delete message

### Users & Friends
- `GET /api/users/profile/:userId` - Get user profile
- `GET /api/users/search` - Search users
- `POST /api/users/:userId/friend-request` - Send friend request
- `PUT /api/users/:requestId/accept` - Accept request
- `GET /api/users/list` - Get friends list
- `GET /api/users/requests/pending` - Get pending requests
- `DELETE /api/users/:friendId` - Remove friend

### Analytics
- `GET /api/analytics/weekly` - Weekly analytics
- `GET /api/analytics/monthly` - Monthly analytics
- `GET /api/analytics/subject` - Subject-wise breakdown
- `GET /api/analytics/group/comparison` - Group comparison

---

## Technology Stack

### Backend
- **Framework**: Express.js
- **Database**: PostgreSQL
- **Authentication**: JWT + bcryptjs
- **Real-time**: Socket.io
- **File Upload**: Multer
- **Validation**: express-validator

### Frontend
- **Framework**: React Native (Expo)
- **Navigation**: React Navigation
- **HTTP Client**: Axios
- **Charts**: react-native-chart-kit
- **Storage**: AsyncStorage
- **Icons**: Material Icons
- **Real-time**: socket.io-client

---

## Key Features Explained

### 1. Activity Tracking
Users can log daily study sessions with:
- Title and description
- Subject and duration
- Activity category
- Automatic timestamp

### 2. Analytics Dashboard
- Weekly hour totals with charts
- Subject-wise breakdown
- Goal completion tracking
- Friend group comparisons

### 3. Goal Setting
- Create weekly/monthly goals
- Set target hours or items
- Track progress visually
- Update completion status

### 4. Notes Sharing
- Create rich-text notes
- Share with specific friends
- Organize by subject
- Edit and delete anytime

### 5. Memory Board
- Upload study journey photos
- Add titles and descriptions
- View friend memories
- Date-organized timeline

### 6. Real-time Chat
- Direct messaging
- Live notifications
- Typing indicators
- Message history

### 7. Friends System
- Request/accept friends
- Search user database
- View friend profiles
- Compare statistics

---

## Security Considerations

1. **JWT Tokens**
   - 7-day expiration
   - Stored securely in AsyncStorage
   - Auto-included in all requests

2. **Password Security**
   - Bcryptjs hashing (10 salt rounds)
   - Never stored in plain text
   - Secure comparison on login

3. **Data Privacy**
   - User can only access own data
   - Shared notes only with accepted friends
   - Messages encrypted in transit

4. **Validation**
   - Input validation on all endpoints
   - Field length restrictions
   - Email format validation

---

## Troubleshooting

### Database Connection Error
- Check PostgreSQL is running
- Verify credentials in `.env`
- Ensure database exists

### App Won't Connect to Backend
- Check IP address in frontend `.env`
- Firewall might be blocking port 5000
- Ensure backend server is running

### Image Upload Fails
- Check `uploads/memories` folder exists
- Verify file size limits
- Check file permissions

### Socket.io Real-time Issues
- Verify socket URL matches backend
- Check WebSocket support
- Restart Expo app

---

## Future Enhancements

- [ ] Group study sessions
- [ ] Voice/video calls
- [ ] Study reminders and notifications
- [ ] Achievement badges
- [ ] Leaderboards
- [ ] Study timer/Pomodoro
- [ ] Offline mode
- [ ] Dark theme
- [ ] Advanced search filters
- [ ] Content recommendation

---

## Contributing

Feel free to contribute by:
1. Finding bugs and reporting
2. Suggesting features
3. Submitting pull requests
4. Improving documentation

---

## License

This project is open source and available under the MIT License.

---

## Support

For issues and questions:
- Check existing documentation
- Search GitHub issues
- Create a new issue with details

---

## Authors

Created as a comprehensive educational collaboration platform.

**Happy Studying! 📚✨**
