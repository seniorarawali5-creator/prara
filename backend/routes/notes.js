const express = require('express');
const pool = require('../config/database');
const authMiddleware = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const router = express.Router();

// Create Note
router.post('/', authMiddleware, [
  body('title').notEmpty().withMessage('Title is required'),
  body('content').notEmpty().withMessage('Content is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, content, subject, isShared } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      `INSERT INTO notes (user_id, title, content, subject, is_shared) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [userId, title, content, subject, isShared || false]
    );

    res.status(201).json({
      message: 'Note created successfully',
      note: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get User Notes
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM notes WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );

    res.json({
      notes: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Shared Notes with User
router.get('/shared', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT n.*, u.username, u.first_name FROM shared_notes sn
       JOIN notes n ON sn.note_id = n.id
       JOIN users u ON n.user_id = u.id
       WHERE sn.shared_with_user_id = $1
       ORDER BY sn.shared_at DESC`,
      [userId]
    );

    res.json({
      sharedNotes: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Share Note with Friend
router.post('/:id/share', authMiddleware, [
  body('friendId').isInt().withMessage('Friend ID must be a number')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const { friendId } = req.body;
    const userId = req.user.userId;

    // Check if note exists and belongs to user
    const noteCheck = await pool.query(
      'SELECT * FROM notes WHERE id = $1 AND user_id = $2',
      [id, userId]
    );

    if (noteCheck.rows.length === 0) {
      return res.status(404).json({ message: 'Note not found' });
    }

    // Share note
    const result = await pool.query(
      `INSERT INTO shared_notes (note_id, shared_with_user_id, shared_by_user_id) 
       VALUES ($1, $2, $3) 
       RETURNING *`,
      [id, friendId, userId]
    );

    res.status(201).json({
      message: 'Note shared successfully',
      sharedNote: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update Note
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, subject } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      `UPDATE notes SET title = $1, content = $2, subject = $3, updated_at = CURRENT_TIMESTAMP 
       WHERE id = $4 AND user_id = $5 
       RETURNING *`,
      [title, content, subject, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Note not found' });
    }

    res.json({
      message: 'Note updated successfully',
      note: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete Note
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'DELETE FROM notes WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Note not found' });
    }

    res.json({ message: 'Note deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
