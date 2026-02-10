-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  profile_picture VARCHAR(500),
  bio TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Friends/Connections Table
CREATE TABLE IF NOT EXISTS friends (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  friend_id INT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, blocked
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(friend_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(user_id, friend_id)
);

-- Activities Table
CREATE TABLE IF NOT EXISTS activities (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  activity_type VARCHAR(50), -- study, exercise, project, etc.
  subject VARCHAR(100),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  duration_minutes INT,
  category VARCHAR(50),
  tags VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_date (user_id, created_at)
);

-- Goals Table
CREATE TABLE IF NOT EXISTS goals (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  goal_type VARCHAR(50), -- weekly, monthly, custom
  title VARCHAR(255) NOT NULL,
  description TEXT,
  target_value INT,
  target_unit VARCHAR(50), -- hours, pages, problems, etc.
  start_date DATE,
  end_date DATE,
  status VARCHAR(20) DEFAULT 'active', -- active, completed, abandoned
  progress INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Notes Table
CREATE TABLE IF NOT EXISTS notes (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  subject VARCHAR(100),
  is_shared BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Shared Notes (Many-to-many relationship)
CREATE TABLE IF NOT EXISTS shared_notes (
  id SERIAL PRIMARY KEY,
  note_id INT NOT NULL,
  shared_with_user_id INT NOT NULL,
  shared_by_user_id INT NOT NULL,
  shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(note_id) REFERENCES notes(id) ON DELETE CASCADE,
  FOREIGN KEY(shared_with_user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(shared_by_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Memories Table
CREATE TABLE IF NOT EXISTS memories (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255),
  description TEXT,
  image_url VARCHAR(500) NOT NULL,
  tags VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Messages/Chat Table
CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  sender_id INT NOT NULL,
  recipient_id INT NOT NULL,
  message TEXT NOT NULL,
  image_url VARCHAR(500),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(sender_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(recipient_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_conversation (sender_id, recipient_id, created_at)
);

-- Analytics/Statistics Table
CREATE TABLE IF NOT EXISTS analytics (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  week_start DATE,
  total_study_hours INT DEFAULT 0,
  total_activities INT DEFAULT 0,
  goals_completed INT DEFAULT 0,
  goals_total INT DEFAULT 0,
  subjects_studied VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_activities_user ON activities(user_id);
CREATE INDEX idx_activities_date ON activities(created_at);
CREATE INDEX idx_goals_user ON goals(user_id);
CREATE INDEX idx_notes_user ON notes(user_id);
CREATE INDEX idx_memories_user ON memories(user_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_friends_user ON friends(user_id);
