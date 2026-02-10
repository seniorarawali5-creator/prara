const express = require('express');
const pool = require('../config/database');
const authMiddleware = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const router = express.Router();

// Send Message
router.post('/', authMiddleware, [
  body('recipientId').isInt().withMessage('Recipient ID is required'),
  body('message').notEmpty().withMessage('Message is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { recipientId, message, imageUrl } = req.body;
    const senderId = req.user.userId;

    // Check if recipient exists
    const recipientCheck = await pool.query(
      'SELECT id FROM users WHERE id = $1',
      [recipientId]
    );

    if (recipientCheck.rows.length === 0) {
      return res.status(404).json({ message: 'Recipient not found' });
    }

    const result = await pool.query(
      `INSERT INTO messages (sender_id, recipient_id, message, image_url) 
       VALUES ($1, $2, $3, $4) 
       RETURNING *`,
      [senderId, recipientId, message, imageUrl || null]
    );

    res.status(201).json({
      message: 'Message sent successfully',
      data: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Conversation
router.get('/conversation/:userId', authMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.user.userId;

    const result = await pool.query(
      `SELECT * FROM messages 
       WHERE (sender_id = $1 AND recipient_id = $2) 
          OR (sender_id = $2 AND recipient_id = $1)
       ORDER BY created_at ASC
       LIMIT 100`,
      [currentUserId, userId]
    );

    // Mark messages as read
    await pool.query(
      `UPDATE messages 
       SET is_read = true 
       WHERE recipient_id = $1 AND sender_id = $2 AND is_read = false`,
      [currentUserId, userId]
    );

    res.json({
      conversation: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Conversations List
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT DISTINCT
        CASE 
          WHEN sender_id = $1 THEN recipient_id 
          ELSE sender_id 
        END as other_user_id,
        u.username,
        u.first_name,
        u.profile_picture,
        m.message,
        m.created_at,
        COUNT(CASE WHEN m.recipient_id = $1 AND m.is_read = false THEN 1 END) as unread_count
       FROM messages m
       JOIN users u ON CASE 
         WHEN m.sender_id = $1 THEN m.recipient_id = u.id
         ELSE m.sender_id = u.id
       END
       WHERE sender_id = $1 OR recipient_id = $1
       GROUP BY other_user_id, u.id, m.message, m.created_at
       ORDER BY m.created_at DESC`,
      [userId]
    );

    res.json({
      conversations: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Unread Messages Count
router.get('/unread/count', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT COUNT(*) as unread_count FROM messages 
       WHERE recipient_id = $1 AND is_read = false`,
      [userId]
    );

    res.json({
      unreadCount: parseInt(result.rows[0].unread_count)
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete Message
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      `DELETE FROM messages 
       WHERE id = $1 AND sender_id = $2 
       RETURNING id`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Message not found' });
    }

    res.json({ message: 'Message deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
