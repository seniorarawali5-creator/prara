const express = require('express');
const pool = require('../config/database');
const authMiddleware = require('../middleware/auth');
const router = express.Router();

// Get Weekly Analytics
router.get('/weekly', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { weekStart } = req.query;

    let query = `
      SELECT 
        DATE_TRUNC('week', created_at) as week_start,
        COUNT(*) as total_activities,
        SUM(duration_minutes) as total_minutes,
        activity_type,
        subject,
        array_agg(DISTINCT subject) as subjects_studied
      FROM activities
      WHERE user_id = $1
    `;

    let params = [userId];

    if (weekStart) {
      query += ` AND created_at >= $2::date AND created_at < ($2::date + interval '7 days')`;
      params.push(weekStart);
    } else {
      query += ` AND created_at >= DATE_TRUNC('week', NOW()) AND created_at < DATE_TRUNC('week', NOW()) + interval '7 days'`;
    }

    query += ` GROUP BY week_start, activity_type, subject ORDER BY week_start DESC`;

    const result = await pool.query(query, params);

    // Get goals progress for the week
    const goalsQuery = `
      SELECT 
        COUNT(*) as total_goals,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_goals,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_goals
      FROM goals
      WHERE user_id = $1
    `;

    const goalsResult = await pool.query(goalsQuery, [userId]);

    res.json({
      weeklyAnalytics: result.rows,
      goalsProgress: goalsResult.rows[0],
      totalStudyHours: result.rows.reduce((sum, row) => sum + (parseInt(row.total_minutes) || 0), 0) / 60
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Monthly Analytics
router.get('/monthly', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { month } = req.query;

    let query = `
      SELECT 
        DATE_TRUNC('month', created_at) as month,
        COUNT(*) as total_activities,
        SUM(duration_minutes) as total_minutes,
        activity_type,
        array_agg(DISTINCT subject) as subjects_studied
      FROM activities
      WHERE user_id = $1
    `;

    let params = [userId];

    if (month) {
      query += ` AND DATE_TRUNC('month', created_at) = $2::date`;
      params.push(month);
    } else {
      query += ` AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', NOW())`;
    }

    query += ` GROUP BY DATE_TRUNC('month', created_at), activity_type ORDER BY month DESC`;

    const result = await pool.query(query, params);

    // Get monthly goals
    const goalsQuery = `
      SELECT 
        COUNT(*) as total_goals,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_goals,
        SUM(progress) as total_progress
      FROM goals
      WHERE user_id = $1 AND DATE_TRUNC('month', start_date) = DATE_TRUNC('month', NOW())
    `;

    const goalsResult = await pool.query(goalsQuery, [userId]);

    res.json({
      monthlyAnalytics: result.rows,
      goalsProgress: goalsResult.rows[0],
      totalStudyHours: result.rows.reduce((sum, row) => sum + (parseInt(row.total_minutes) || 0), 0) / 60
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Subject-wise Analytics
router.get('/subject', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const query = `
      SELECT 
        subject,
        COUNT(*) as study_count,
        SUM(duration_minutes) as total_minutes,
        AVG(duration_minutes) as avg_minutes,
        MAX(created_at) as last_studied
      FROM activities
      WHERE user_id = $1 AND subject IS NOT NULL
      GROUP BY subject
      ORDER BY total_minutes DESC
    `;

    const result = await pool.query(query, [userId]);

    res.json({
      subjectAnalytics: result.rows,
      totalSubjects: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Friend Group Analytics (for group comparison)
router.get('/group/comparison', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const query = `
      SELECT 
        u.id,
        u.username,
        u.first_name,
        COUNT(a.id) as activities_count,
        SUM(a.duration_minutes) as total_minutes,
        COUNT(DISTINCT a.subject) as subjects_count
      FROM users u
      LEFT JOIN friends f ON ((f.user_id = $1 AND f.friend_id = u.id) OR (f.friend_id = $1 AND f.user_id = u.id))
      LEFT JOIN activities a ON u.id = a.user_id 
        AND a.created_at >= DATE_TRUNC('week', NOW())
        AND a.created_at < DATE_TRUNC('week', NOW()) + interval '7 days'
      WHERE (u.id = $1 OR f.status = 'accepted')
      GROUP BY u.id, u.username, u.first_name
      ORDER BY total_minutes DESC
    `;

    const result = await pool.query(query, [userId]);

    res.json({
      groupAnalytics: result.rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
