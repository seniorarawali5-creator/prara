const express = require('express');
const pool = require('../config/database');
const authMiddleware = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const router = express.Router();

// Add Activity
router.post('/', authMiddleware, [
  body('title').notEmpty().withMessage('Title is required'),
  body('activityType').notEmpty().withMessage('Activity type is required'),
  body('durationMinutes').isInt().withMessage('Duration must be a number')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, description, activityType, subject, durationMinutes, category, tags } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      `INSERT INTO activities (user_id, title, description, activity_type, subject, duration_minutes, category, tags) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
       RETURNING *`,
      [userId, title, description, activityType, subject, durationMinutes, category, tags]
    );

    res.status(201).json({
      message: 'Activity added successfully',
      activity: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get User Activities (with filters)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { startDate, endDate, activityType } = req.query;

    let query = 'SELECT * FROM activities WHERE user_id = $1';
    let params = [userId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND created_at >= $${paramCount}`;
      params.push(startDate);
      paramCount++;
    }

    if (endDate) {
      query += ` AND created_at <= $${paramCount}`;
      params.push(endDate);
      paramCount++;
    }

    if (activityType) {
      query += ` AND activity_type = $${paramCount}`;
      params.push(activityType);
      paramCount++;
    }

    query += ' ORDER BY created_at DESC';

    const result = await pool.query(query, params);

    res.json({
      activities: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Activity by ID
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM activities WHERE id = $1 AND user_id = $2',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update Activity
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const { title, description, durationMinutes } = req.body;

    const result = await pool.query(
      `UPDATE activities SET title = $1, description = $2, duration_minutes = $3, updated_at = CURRENT_TIMESTAMP 
       WHERE id = $4 AND user_id = $5 
       RETURNING *`,
      [title, description, durationMinutes, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    res.json({
      message: 'Activity updated successfully',
      activity: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete Activity
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'DELETE FROM activities WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    res.json({ message: 'Activity deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
