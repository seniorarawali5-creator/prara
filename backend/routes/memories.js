const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pool = require('../config/database');
const authMiddleware = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const router = express.Router();

// Setup multer for file uploads
const uploadDir = process.env.UPLOAD_DIR || './uploads/memories';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5242880 }
});

// Add Memory
router.post('/', authMiddleware, upload.single('image'), [
  body('title').optional(),
  body('description').optional()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    if (!req.file) {
      return res.status(400).json({ message: 'Image is required' });
    }

    const { title, description, tags } = req.body;
    const userId = req.user.userId;
    const imageUrl = `/uploads/memories/${req.file.filename}`;

    const result = await pool.query(
      `INSERT INTO memories (user_id, title, description, image_url, tags) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [userId, title || null, description || null, imageUrl, tags || null]
    );

    res.status(201).json({
      message: 'Memory added successfully',
      memory: result.rows[0]
    });
  } catch (error) {
    // Delete uploaded file if there's an error
    if (req.file) {
      fs.unlink(path.join(uploadDir, req.file.filename), () => {});
    }
    console.error(error);
    res.status(500).json({ message: error.message || 'Server error' });
  }
});

// Get User Memories
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM memories WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );

    res.json({
      memories: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get Friend Memories (shared)
router.get('/friend/:friendId', authMiddleware, async (req, res) => {
  try {
    const { friendId } = req.params;

    // Check if they are friends
    const friendCheck = await pool.query(
      `SELECT * FROM friends 
       WHERE ((user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1))
       AND status = 'accepted'`,
      [req.user.userId, friendId]
    );

    if (friendCheck.rows.length === 0) {
      return res.status(403).json({ message: 'Not friends with this user' });
    }

    const result = await pool.query(
      'SELECT * FROM memories WHERE user_id = $1 ORDER BY created_at DESC',
      [friendId]
    );

    res.json({
      memories: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete Memory
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'DELETE FROM memories WHERE id = $1 AND user_id = $2 RETURNING image_url',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Memory not found' });
    }

    // Delete file from server
    const filePath = path.join(uploadDir, path.basename(result.rows[0].image_url));
    fs.unlink(filePath, () => {});

    res.json({ message: 'Memory deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
