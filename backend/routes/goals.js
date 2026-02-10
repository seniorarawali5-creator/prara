const express = require('express');
const pool = require('../config/database');
const authMiddleware = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const router = express.Router();

// Create Goal
router.post('/', authMiddleware, [
  body('title').notEmpty().withMessage('Title is required'),
  body('targetValue').isInt().withMessage('Target value must be a number'),
  body('endDate').notEmpty().withMessage('End date is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, description, goalType, targetValue, targetUnit, startDate, endDate } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      `INSERT INTO goals (user_id, title, description, goal_type, target_value, target_unit, start_date, end_date) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
       RETURNING *`,
      [userId, title, description, goalType, targetValue, targetUnit, startDate, endDate]
    );

    res.status(201).json({
      message: 'Goal created successfully',
      goal: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get User Goals
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status } = req.query;

    let query = 'SELECT * FROM goals WHERE user_id = $1';
    let params = [userId];

    if (status) {
      query += ' AND status = $2';
      params.push(status);
    }

    query += ' ORDER BY end_date ASC';

    const result = await pool.query(query, params);

    res.json({
      goals: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update Goal Progress
router.put('/:id/progress', authMiddleware, [
  body('progress').isInt().withMessage('Progress must be a number')
], async (req, res) => {
  try {
    const { id } = req.params;
    const { progress } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      `UPDATE goals SET progress = $1, updated_at = CURRENT_TIMESTAMP 
       WHERE id = $2 AND user_id = $3 
       RETURNING *`,
      [progress, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Goal not found' });
    }

    res.json({
      message: 'Goal progress updated',
      goal: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update Goal Status
router.put('/:id/status', authMiddleware, [
  body('status').isIn(['active', 'completed', 'abandoned']).withMessage('Invalid status')
], async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      `UPDATE goals SET status = $1, updated_at = CURRENT_TIMESTAMP 
       WHERE id = $2 AND user_id = $3 
       RETURNING *`,
      [status, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Goal not found' });
    }

    res.json({
      message: 'Goal status updated',
      goal: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete Goal
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'DELETE FROM goals WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Goal not found' });
    }

    res.json({ message: 'Goal deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
