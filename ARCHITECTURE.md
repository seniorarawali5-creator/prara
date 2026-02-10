# 🏗️ Study Buddy - Architecture & Data Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     MOBILE FRONTEND                          │
│              (React Native + Expo)                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │  Auth    │  │  Activity│  │ Analytics│  │  Notes   │    │
│  │ Screens  │  │ Screens  │  │ Screens  │  │ Screens  │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │ Memories │  │   Chat   │  │ Friends  │                  │
│  │ Screens  │  │ Screens  │  │ Screens  │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          Navigation Layer                             │  │
│  │  Stack Navigator + Bottom Tab Navigator               │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          API Client (Axios)                           │  │
│  │  - Auto JWT injection                                 │  │
│  │  - Error handling                                     │  │
│  │  - Request/response interceptors                      │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  State Management (Context API + AsyncStorage)        │  │
│  │  - AuthContext for user state                         │  │
│  │  - LocalStorage for token persistence                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Real-time Connection (Socket.io)                     │  │
│  │  - Live chat updates                                  │  │
│  │  - Typing indicators                                  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ HTTP/WebSocket
                          │
┌─────────────────────────────────────────────────────────────┐
│                  BACKEND API SERVER                          │
│            (Node.js + Express + Socket.io)                  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          Express Routes                               │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐              │  │
│  │  │   Auth   │ │Activities│ │  Goals   │              │  │
│  │  │  Routes  │ │  Routes  │ │  Routes  │              │  │
│  │  └──────────┘ └──────────┘ └──────────┘              │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐              │  │
│  │  │  Notes   │ │ Memories │ │ Messages │              │  │
│  │  │  Routes  │ │  Routes  │ │  Routes  │              │  │
│  │  └──────────┘ └──────────┘ └──────────┘              │  │
│  │  ┌──────────┐ ┌──────────┐                           │  │
│  │  │  Users   │ │Analytics │                           │  │
│  │  │  Routes  │ │  Routes  │                           │  │
│  │  └──────────┘ └──────────┘                           │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          Middleware Stack                             │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐              │  │
│  │  │   CORS   │ │   Auth   │ │ Validation              │  │
│  │  │ Middleware │ Middleware │ Middleware               │  │
│  │  └──────────┘ └──────────┘ └──────────┘              │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          Socket.io Handler                            │  │
│  │  - Real-time chat                                     │  │
│  │  - Typing indicators                                  │  │
│  │  - Live notifications                                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          File Upload Handler (Multer)                 │  │
│  │  - Memory images storage                              │  │
│  │  - Size validation                                    │  │
│  │  - MIME type checking                                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          Service Layer                                │  │
│  │  - Business logic                                     │  │
│  │  - Data validation                                    │  │
│  │  - Error handling                                     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ PostgreSQL Driver (pg)
                          │
┌─────────────────────────────────────────────────────────────┐
│                   DATABASE LAYER                            │
│              (PostgreSQL Database)                          │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │   users    │  │ activities │  │   goals    │           │
│  │  (Profiles)│  │  (Logs)    │  │ (Targets)  │           │
│  └────────────┘  └────────────┘  └────────────┘           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │   notes    │  │ memories   │  │ messages   │           │
│  │(Materials) │  │  (Photos)  │  │  (Chat)    │           │
│  └────────────┘  └────────────┘  └────────────┘           │
│  ┌────────────┐  ┌────────────┐                           │
│  │  friends   │  │ analytics  │                           │
│  │(Connections)│  │(Statistics)│                           │
│  └────────────┘  └────────────┘                           │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐ │
│  │        Indexes & Optimization                         │ │
│  │  - user_id indexes                                    │ │
│  │  - date range indexes                                 │ │
│  │  - foreign key constraints                            │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐ │
│  │        File System - Uploads                          │ │
│  │  /uploads/memories/ - Image storage                   │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow Examples

### 1️⃣ User Sign Up Flow

```
Frontend (SignupScreen)
    │
    ├─ User enters credentials
    │
    ├─ Form validation
    │
    ├─ Call authAPI.signup()
    │
    └─→ Backend (POST /api/auth/signup)
            │
            ├─ Validate input data
            │
            ├─ Check duplicate email/username
            │
            ├─ Hash password with bcryptjs
            │
            ├─ Insert into database
            │
            ├─ Generate JWT token
            │
            └─→ Response with token & user data
                    │
                    ├─ Store token in AsyncStorage
                    │
                    ├─ Update AuthContext
                    │
                    └─→ Navigate to App Tabs
```

### 2️⃣ Activity Logging Flow

```
Frontend (HomeScreen)
    │
    ├─ User clicks "Add Activity"
    │
    ├─ Navigate to AddActivityScreen
    │
    ├─ User fills form
    │
    ├─ Click "Add Activity"
    │
    └─→ API Client (axios)
            │
            ├─ Get JWT token from AsyncStorage
            │
            ├─ Add Bearer token to header
            │
            ├─ POST /api/activities
            │
            └─→ Backend Handler
                    │
                    ├─ Verify JWT token (AuthMiddleware)
                    │
                    ├─ Validate input data
                    │
                    ├─ Insert into activities table
                    │
                    ├─ Return activity object
                    │
                    └─→ Success response
                            │
                            ├─ Show success alert
                            │
                            ├─ Navigate back
                            │
                            └─→ Refresh activities list
```

### 3️⃣ Real-time Chat Flow

```
Frontend A (ChatScreen)
    │
    ├─ User types message
    │
    ├─ Click send
    │
    ├─ Create message object
    │
    ├─ POST /api/messages
    │
    └─→ API Response
            │
            ├─ Store message in database
            │
            └─→ Socket.io broadcast
                    │
                    └─→ Frontend B (Socket listener)
                            │
                            ├─ Receive message event
                            │
                            ├─ Add to local messages state
                            │
                            └─→ Display in chat UI
```

### 4️⃣ Analytics Generation Flow

```
Frontend (AnalyticsScreen)
    │
    ├─ User opens Analytics
    │
    ├─ Trigger loadAnalytics()
    │
    │
    ├─→ Backend (GET /api/analytics/weekly)
    │       │
    │       ├─ Get user_id from JWT token
    │       │
    │       ├─ Query activities (this week)
    │       │
    │       ├─ Calculate totals
    │       │
    │       ├─ Group by subject
    │       │
    │       ├─ Query goals progress
    │       │
    │       └─→ Return analytics data
    │
    │
    │
    ├─→ Backend (GET /api/analytics/monthly)
    │       │
    │       └─→ Return monthly data
    │
    │
    ├─→ Backend (GET /api/analytics/subject)
    │       │
    │       └─→ Return subject breakdown
    │
    └─→ Frontend Updates
            │
            ├─ Update state with data
            │
            ├─ Render charts (Chart Kit)
            │
            └─→ Display analytics
```

### 5️⃣ Image Upload (Memory) Flow

```
Frontend (MemoriesScreen)
    │
    ├─ User clicks "Add Memory"
    │
    ├─ Open image picker
    │
    ├─ User selects image
    │
    ├─ Create FormData object
    │
    ├─ Add image binary data
    │
    ├─ Add metadata (title, description)
    │
    └─→ POST /api/memories (multipart/form-data)
            │
            ├─ Multer middleware processes
            │
            ├─ Save file to /uploads/memories/
            │
            ├─ Insert record in memories table
            │
            └─→ Response with image URL
                    │
                    ├─ Add to memories list
                    │
                    └─→ Display thumbnail
```

---

## Authentication Flow

```
┌─────────────────────────────────────────────────┐
│            JWT Authentication Flow              │
└─────────────────────────────────────────────────┘

1. Sign In
   ├─ POST /api/auth/signin
   ├─ Email + Password
   ├─ Backend verifies password
   ├─ Generate JWT token (valid 7 days)
   └─ Return token + user data

2. Store Token
   ├─ Save to AsyncStorage (key: "authToken")
   ├─ Available for entire session
   └─ Persists app restart

3. API Requests
   ├─ Axios interceptor gets token
   ├─ Add to Authorization header
   ├─ Format: "Bearer <token>"
   └─ Send with request

4. Backend Verification
   ├─ Middleware verifies token
   ├─ Decode JWT payload
   ├─ Extract userId
   ├─ User ID added to request object
   └─ Proceed with request

5. Token Expiry
   ├─ Token expires after 7 days
   ├─ Backend returns 401 error
   ├─ App catches error
   ├─ Redirect to sign in
   └─ User must re-authenticate

6. Sign Out
   ├─ Clear AsyncStorage token
   ├─ Update AuthContext
   ├─ Navigate to Auth Stack
   └─ Fresh start
```

---

## Database Relationships

```
┌─────────────────────────────────────────────────────────┐
│              Entity Relationship Diagram                │
└─────────────────────────────────────────────────────────┘

users (1) ──→ (N) activities
   │
   ├─→ (N) goals
   │
   ├─→ (N) notes
   │
   ├─→ (N) memories
   │
   ├─→ (N) messages (as sender)
   │
   ├─→ (N) messages (as recipient)
   │
   ├─→ (N) friends (friend requests)
   │
   └─→ (N) analytics

notes (1) ──→ (N) shared_notes
   │
   └─→ (N) users (through shared_notes)

messages (N) ←─→ (N) users
   │
   ├─ sender_id → users.id
   └─ recipient_id → users.id

friends relations:
   users (1) ──→ (N) friends.user_id
   users (1) ──→ (N) friends.friend_id
```

---

## Request/Response Cycle

```
Step 1: Frontend
├─ Component calls API function
├─ Example: activitiesAPI.getActivities()
└─ Axios creates HTTP request

Step 2: Request Interceptor
├─ Get token from AsyncStorage
├─ Add Authorization header
└─ Set Content-Type

Step 3: Network
├─ Request travels over HTTP/HTTPS
├─ URL: http://localhost:5000/api/activities
└─ Method: GET/POST/PUT/DELETE

Step 4: Backend Express Server
├─ Route handler receives request
├─ Middleware stack processes:
│  ├─ CORS check
│  ├─ Auth verification
│  └─ Input validation
└─ Business logic executes

Step 5: Database Query
├─ PostgreSQL client executes query
├─ Fetch data from tables
└─ Return results to handler

Step 6: Response Generation
├─ Format response object
├─ Add status code (200, 400, 500)
└─ Serialize to JSON

Step 7: Response Interceptor
├─ Check status code
├─ Handle errors globally
└─ Pass to calling code

Step 8: Frontend Processing
├─ Update component state
├─ Re-render UI
├─ Show success/error message
└─ Update async storage if needed
```

---

## Error Handling

```
Frontend Level
├─ Form validation
├─ Network error catching
├─ User feedback (Alert)
└─ Loading state management

Backend Level
├─ Input validation (express-validator)
├─ JWT verification
├─ Database constraints
├─ Error middleware
└─ JSON response with code/message
```

---

## Scalability Considerations

| Aspect | Current | Future |
|--------|---------|--------|
| Users | Small group | 1000s |
| Activities | Per user | Archive old |
| Messages | Short term | Archive |
| Analytics | Real-time calc | Pre-computed |
| Images | Local storage | Cloud (S3) |
| Database | Single | Replicas |

---

## Security Layers

```
Layer 1: Transport
├─ HTTPS in production
└─ Encrypted data in transit

Layer 2: Authentication
├─ JWT tokens
├─ Password hashing
└─ Secure storage

Layer 3: Authorization
├─ User can access own data
├─ Friends only for shared data
└─ Admin functions

Layer 4: Data Validation
├─ Input sanitization
├─ Type checking
└─ Length limits

Layer 5: API Security
├─ Rate limiting (future)
├─ CORS enabled
└─ Error hiding
```

---

This architecture provides a robust, scalable foundation for the Study Buddy application!
