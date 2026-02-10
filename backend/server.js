const express = require('express');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const activitiesRoutes = require('./routes/activities');
const goalsRoutes = require('./routes/goals');
const notesRoutes = require('./routes/notes');
const memoriesRoutes = require('./routes/memories');
const messagesRoutes = require('./routes/messages');
const usersRoutes = require('./routes/users');
const analyticsRoutes = require('./routes/analytics');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files for uploads
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/goals', goalsRoutes);
app.use('/api/notes', notesRoutes);
app.use('/api/memories', memoriesRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/analytics', analyticsRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running' });
});

// Socket.io for real-time chat
io.on('connection', (socket) => {
  console.log('New user connected:', socket.id);

  socket.on('join_room', (data) => {
    socket.join(data.conversationId);
    socket.emit('room_joined', { conversationId: data.conversationId });
  });

  socket.on('send_message', (data) => {
    io.to(data.conversationId).emit('receive_message', {
      senderId: data.senderId,
      message: data.message,
      timestamp: new Date(),
      conversationId: data.conversationId
    });
  });

  socket.on('typing', (data) => {
    socket.to(data.conversationId).emit('user_typing', {
      userId: data.userId,
      username: data.username
    });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: err.message || 'Server error' });
});

// Start server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = server;
