const express = require('express');
const pool = require('../config/database');
const authMiddleware = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const router = express.Router();

// Get User Profile
router.get('/profile/:userId', authMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await pool.query(
      'SELECT id, username, email, first_name, last_name, profile_picture, bio, created_at FROM users WHERE id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = result.rows[0];

    // Get friend status
    const friendStatus = await pool.query(
      `SELECT status FROM friends 
       WHERE (user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1)`,
      [req.user.userId, userId]
    );

    res.json({
      user,
      friendStatus: friendStatus.rows.length > 0 ? friendStatus.rows[0].status : null
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Search Users
router.get('/search', authMiddleware, async (req, res) => {
  try {
    const { query } = req.query;

    if (!query || query.length < 2) {
      return res.status(400).json({ message: 'Query must be at least 2 characters' });
    }

    const result = await pool.query(
      `SELECT id, username, first_name, last_name, profile_picture FROM users 
       WHERE (username ILIKE $1 OR first_name ILIKE $1 OR last_name ILIKE $1)
       AND id != $2
       LIMIT 20`,
      [`%${query}%`, req.user.userId]
    );

    res.json({
      users: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Send Friend Request
router.post('/:userId/friend-request', authMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;
    const senderId = req.user.userId;

    if (parseInt(userId) === senderId) {
      return res.status(400).json({ message: 'Cannot add yourself as friend' });
    }

    // Check if user exists
    const userCheck = await pool.query('SELECT id FROM users WHERE id = $1', [userId]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if already friends
    const existingFriend = await pool.query(
      `SELECT * FROM friends 
       WHERE (user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1)`,
      [senderId, userId]
    );

    if (existingFriend.rows.length > 0) {
      return res.status(400).json({ message: 'Friend request already exists' });
    }

    // Create friend request
    const result = await pool.query(
      `INSERT INTO friends (user_id, friend_id, status) 
       VALUES ($1, $2, 'pending') 
       RETURNING *`,
      [senderId, userId]
    );

    res.status(201).json({
      message: 'Friend request sent',
      friendRequest: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Accept Friend Request
router.put('/:requestId/accept', authMiddleware, async (req, res) => {
  try {
    const { requestId } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      `UPDATE friends 
       SET status = 'accepted' 
       WHERE id = $1 AND friend_id = $2 AND status = 'pending'
       RETURNING *`,
      [requestId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Friend request not found' });
    }

    res.json({
      message: 'Friend request accepted',
      friend: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Friends List
router.get('/list', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT u.id, u.username, u.first_name, u.last_name, u.profile_picture FROM friends f
       JOIN users u ON ((f.user_id = $1 AND u.id = f.friend_id) OR (f.friend_id = $1 AND u.id = f.user_id))
       WHERE f.status = 'accepted'`,
      [userId]
    );

    res.json({
      friends: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Pending Friend Requests
router.get('/requests/pending', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT u.id, u.username, u.first_name, u.last_name, u.profile_picture, f.id as request_id FROM friends f
       JOIN users u ON f.user_id = u.id
       WHERE f.friend_id = $1 AND f.status = 'pending'`,
      [userId]
    );

    res.json({
      pendingRequests: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Remove Friend
router.delete('/:friendId', authMiddleware, async (req, res) => {
  try {
    const { friendId } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      `DELETE FROM friends 
       WHERE (user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1)
       RETURNING id`,
      [userId, friendId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Friend not found' });
    }

    res.json({ message: 'Friend removed successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
