# 📖 Study Buddy - Quick Reference Guide

## 🎯 User Workflows

### Workflow 1: New User Journey
```
1. Launch App → SignIn Screen
2. Click "Don't have an account? Sign Up"
3. Enter credentials (first name, last name, username, email, password)
4. Click "Sign Up"
5. Logged in automatically → Home Screen
6. See "Add Activity" button
7. Add first activity → Success!
```

### Workflow 2: Track Daily Activity
```
1. Home Screen
2. Click "Add Activity"
3. Enter:
   - Title: "Completed Math Chapter 5"
   - Subject: "Mathematics"
   - Duration: 45 minutes
   - Type: "Study"
4. Click "Add Activity"
5. Activity appears in today's list
6. View weekly stats updated
```

### Workflow 3: Set Learning Goals
```
1. Home → Add Activity (repeat multiple times)
2. Tap "Home" → View "This Week" stats
3. Click "Set Goal" (future implementation)
4. Create goal:
   - Title: "Study 10 hours this week"
   - Target: 10 hours
   - Type: Weekly
5. Work towards goal
6. See progress in Analytics
```

### Workflow 4: View Analytics
```
1. Click "Home" tab
2. Tap "Analytics" button
3. See:
   - Weekly study hours graph
   - Subject breakdown
   - Goals progress
   - Days studied
4. Toggle to Monthly view
5. Compare with previous periods
```

### Workflow 5: Share Notes
```
1. Click "Notes" tab
2. Tap "Create Note"
3. Enter:
   - Title: "Physics - Thermodynamics"
   - Content: "Detailed notes here..."
   - Subject: "Physics"
4. Save
5. Friend sees it in "Shared Notes"
```

### Workflow 6: Upload Memories
```
1. Click "Memories" tab
2. Tap camera icon
3. Select photo
4. Add title/description
5. Upload
6. View in photo grid
7. Friend can see (if friends)
```

### Workflow 7: Chat with Friend
```
1. Click "Friends" tab
2. Click "+ Add" → Search friend
3. Send friend request
4. Friend accepts in "Requests" tab
5. Click "Messages" tab
6. Find friend in list
7. Tap to open chat
8. Type and send messages
9. See typing indicator
10. Real-time updates
```

### Workflow 8: Make Friends
```
1. Click "Friends" tab
2. Click "+" or search box
3. Search by name/username
4. Click "Add" on user
5. Friend gets request notification
6. Friend clicks "Accept"
7. Now in each other's friends list
8. Can share notes and view memories
```

---

## 🔐 Test Accounts (For Demo)

Create these accounts to test functionality:

### Account 1:
- Name: Alice Johnson
- Username: alice_study
- Email: alice@example.com
- Password: password123

### Account 2:
- Name: Bob Smith
- Username: bob_learn
- Email: bob@example.com
- Password: password123

### Test Flow:
1. Sign up Alice
2. Add activities
3. View analytics
4. Create notes
5. Sign out
6. Sign up Bob
7. Search for Alice
8. Send friend request
9. Sign back in as Alice
10. Accept request
11. Chat with Bob

---

## 📊 Analytics Interpretation

### Weekly Analytics Shows:
- **Total Hours**: Sum of all activity durations
- **Activities Count**: Number of sessions
- **Goals Done**: Completed goals this week
- **Subject Breakdown**: Hours per subject
- **Best Days**: Days with most study

### Monthly Analytics Shows:
- **Total Study Hours**: Month totals
- **Productivity Trend**: Daily/weekly breakdown
- **Goal Completion Rate**: % goals met
- **Most Studied Subject**: Top subject by hours
- **Consistency**: Days without study marked

### Subject Analytics Shows:
- **Hours per Subject**: Total hours
- **Session Count**: Number of sessions
- **Average Session**: Hours per session
- **Last Studied**: Recent activity date

---

## 💾 Data Storage Locations

### Frontend (AsyncStorage - Local Device):
- `authToken` - JWT token
- `user` - User profile data
- `theme` - App theme (future)

### Backend (PostgreSQL Database):
- All permanent data
- Activities, goals, notes, etc.
- Message history
- User profiles

### File System (Server):
- `/uploads/memories/` - Profile pictures
- User memory photos
- Organization: `timestamp_filename.ext`

---

## 🔄 Sync & Offline

### Auto-Sync When Online:
- New activities uploaded automatically
- Messages sent/received
- Friends list updated
- Notes synchronized

### Offline Support (Future):
- View cached activities
- Compose messages (send when online)
- Read cached notes
- Local storage of edits

---

## ⚙️ Settings & Preferences

### Currently No Settings Screen (Future):
- Theme (light/dark)
- Notifications
- Privacy
- Goal reminders
- Activity categories

For now, all settings are defaults.

---

## 🎨 UI Color Scheme

- **Primary**: #5C6BC0 (Indigo)
- **Accent**: #4CAF50 (Green for success)
- **Danger**: #FF6B6B (Red for delete)
- **Background**: #f5f5f5 (Light gray)
- **Cards**: #ffffff (White)
- **Text**: #333333 (Dark gray)
- **Hint**: #999999 (Medium gray)

---

## 📱 Screen Navigation Map

```
Auth Stack:
├─ SignIn Screen
│  └─ "Sign Up" → SignUp Screen
└─ SignUp Screen
   └─ "Sign In" → SignIn Screen

App Tabs (After Login):
├─ Home Tab
│  ├─ HomeScreen
│  ├─ → AddActivityScreen
│  └─ → AnalyticsScreen
│
├─ Notes Tab
│  ├─ NotesScreen
│  └─ → AddNoteScreen
│
├─ Memories Tab
│  └─ MemoriesScreen
│
├─ Chat Tab
│  ├─ ChatListScreen
│  └─ → ChatScreen
│
└─ Friends Tab
   └─ FriendsScreen
```

---

## 🔧 Component State Examples

### HomeScreen State:
```javascript
{
  activities: [
    { id: 1, title: "Math", subject: "Math" },
    { id: 2, title: "Physics", subject: "Physics" }
  ],
  analytics: {
    totalStudyHours: 5.5,
    goalsProgress: { completed: 2, total: 5 }
  },
  loading: false
}
```

### NotesScreen State:
```javascript
{
  notes: [
    { id: 1, title: "Physics Notes", subject: "Physics" },
    { id: 2, title: "Chemistry Notes", subject: "Chemistry" }
  ],
  searchQuery: "",
  loading: false
}
```

### ChatScreen State:
```javascript
{
  messages: [
    { id: 1, sender: "Alice", text: "Hi!", timestamp: "10:30" },
    { id: 2, sender: "Bob", text: "Hey!", timestamp: "10:31" }
  ],
  messageText: "",
  sending: false
}
```

---

## 📡 API Request Examples

### Add Activity
```bash
POST /api/activities
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Math Chapter 5",
  "subject": "Mathematics",
  "description": "Completed exercises 1-20",
  "durationMinutes": 45,
  "activityType": "study",
  "category": "homework"
}
```

### Get Activities
```bash
GET /api/activities?startDate=2024-02-10&endDate=2024-02-17
Authorization: Bearer <token>
```

### Send Message
```bash
POST /api/messages
Authorization: Bearer <token>
Content-Type: application/json

{
  "recipientId": 2,
  "message": "Hi, how are you?"
}
```

### Create Goal
```bash
POST /api/goals
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Complete Math 10 hours",
  "goalType": "weekly",
  "targetValue": 10,
  "targetUnit": "hours",
  "startDate": "2024-02-10",
  "endDate": "2024-02-17"
}
```

### Share Note
```bash
POST /api/notes/5/share
Authorization: Bearer <token>
Content-Type: application/json

{
  "friendId": 3
}
```

---

## ⏱️ Typical Daily Usage Timeline

```
08:00 AM - Open app, view Home
08:15 AM - Study Math 45 mins → Add Activity
09:10 AM - Study Physics 60 mins → Add Activity
12:00 PM - Check Analytics (Weekly view)
01:00 PM - Send note to friend
01:15 PM - Chat with study buddy
03:00 PM - Upload study photo to Memories
05:00 PM - Review Today's activities
06:00 PM - Add Evening Study Session
08:00 PM - Check Friend Progress
```

---

## 🐛 Common Issues & Quick Fixes

| Issue | Fix |
|-------|-----|
| "Token Expired" | Sign in again |
| "Can't connect to API" | Check IP in .env |
| "Messages not appearing" | Restart app |
| "Image upload fails" | Check file size < 5MB |
| "Crashes on chat" | Refresh and retry |
| "Friends not updating" | Pull to refresh |

---

## 📱 Keyboard Shortcuts (If on Web)

```
Tab - Switch between fields
Enter - Submit forms
Esc - Close modals
Space - Toggle checkboxes
```

---

## 🎓 Study Tips with Study Buddy

1. **Create Detailed Activities**
   - Include subject and topic
   - Add meaningful descriptions
   - Track time accurately

2. **Set Realistic Goals**
   - Start with 5-10 hours/week
   - Increase gradually
   - Review weekly

3. **Share Quality Notes**
   - Organized by subject
   - Include headers
   - Clean formatting

4. **Use Memories Wisely**
   - Document study setup
   - Capture important concepts
   - Before/after progress

5. **Chat with Study Partners**
   - Discuss concepts
   - Form study groups
   - Share resources

6. **Review Analytics Weekly**
   - Identify patterns
   - Adjust goals
   - Celebrate progress

---

## 🚀 Advanced Features (Roadmap)

Coming soon:
- Voice notes
- Video tutorials
- Study timer (Pomodoro)
- Reminders & notifications
- Group study sessions
- Leaderboards
- Achievement badges
- Dark mode
- Offline sync

---

This guide covers the essentials. For more details, see README.md and ARCHITECTURE.md!

**Happy Studying! 📚✨**
