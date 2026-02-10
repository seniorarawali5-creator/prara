# Study Buddy - Installation & Quick Start Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Clone & Navigate
```bash
git clone <repo-url>
cd kriara
```

### Step 2: Backend Setup
```bash
cd backend
npm install

# Create .env file and update:
# DB_HOST=localhost
# DB_USER=postgres
# DB_PASSWORD=yourpassword
# DB_NAME=study_buddy

# Create PostgreSQL database:
psql -U postgres -c "CREATE DATABASE study_buddy;"
psql -U postgres -d study_buddy -f database/schema.sql

# Start backend
npm run dev
```

### Step 3: Frontend Setup
```bash
cd ../frontend
npm install

# Update .env with your machine IP:
# API_BASE_URL=http://192.168.x.x:5000
# SOCKET_URL=http://192.168.x.x:5000

# Start Expo
npm start
```

---

## 📱 Running on Different Platforms

### Web Browser
```bash
npx expo start --web
```
Open http://localhost:19006

### Android (via Expo)
```bash
npx expo start
# Scan QR code with Expo Go app
```

### iOS Simulator
```bash
npx expo start
# Press 'i' to open iOS simulator
```

---

## 📚 Main Features Overview

| Feature | Location | What It Does |
|---------|----------|--------------|
| **Add Activity** | Home → Add Activity | Log study sessions |
| **Analytics** | Home → Analytics | View charts & progress |
| **Notes** | Notes Tab | Create & share notes |
| **Memories** | Memories Tab | Upload & view photos |
| **Chat** | Chat Tab | Message friends |
| **Friends** | Friends Tab | Manage friend connections |

---

## 🔧 API Testing

Use Postman or any REST client:

```bash
# Sign Up
POST http://localhost:5000/api/auth/signup
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}

# Sign In
POST http://localhost:5000/api/auth/signin
{
  "email": "john@example.com",
  "password": "password123"
}

# Get Activities (requires token in Authorization header)
GET http://localhost:5000/api/activities
Header: Authorization: Bearer <your_token>
```

---

## 🗄️ Database Schema Summary

**Users** → Profile, auth info
**Activities** → Study sessions logs
**Goals** → Weekly/monthly targets
**Notes** → Study notes with sharing
**Memories** → Photo uploads
**Messages** → Chat conversation
**Friends** → Connection management
**Analytics** → Aggregated stats

---

## ⚙️ Environment Variables

### Backend (.env)
```
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=*****
DB_NAME=study_buddy
DB_PORT=5432
JWT_SECRET=your_secret_key_here
PORT=5000
NODE_ENV=development
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880
```

### Frontend (.env)
```
API_BASE_URL=http://192.168.1.100:5000
SOCKET_URL=http://192.168.1.100:5000
```

---

## 🐛 Common Issues

### "Cannot find module"
```bash
# Backend
npm install

# Frontend
npm install
npx expo install expo-image-picker
```

### "Database connection refused"
- Ensure PostgreSQL is running
- Check credentials match
- Verify database was created

### "Cannot connect to API"
- Get your local IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Update frontend `.env` with correct IP
- Restart both backend and frontend

### "Images not uploading"
- Create `backend/uploads/memories` folder
- Check file permissions
- Verify file size < 5MB

---

## 📦 Project Dependencies

### Backend
- express: HTTP server
- pg: PostgreSQL driver
- jsonwebtoken: JWT auth
- bcryptjs: Password hashing
- multer: File uploads
- socket.io: Real-time chat
- express-validator: Input validation

### Frontend
- react-native: Mobile framework
- expo: Development platform
- @react-navigation: Navigation
- axios: HTTP client
- socket.io-client: Real-time communication
- react-native-chart-kit: Data visualization

---

## 🔐 Security Notes

- Change JWT_SECRET in production
- Store sensitive data in environment variables
- Use HTTPS in production
- Implement rate limiting for API
- Regular security audits

---

## 📞 Getting Help

1. Check README.md for detailed docs
2. Review API endpoints section
3. Check GitHub issues
4. Create new issue with error details

---

**Happy Studying! 🎓✨**
