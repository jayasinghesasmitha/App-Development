const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');

// Initialize Express app
const app = express();
const port = 12330;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// PostgreSQL client configuration
const pool = new Pool({
  user: 'postgres', // Your PostgreSQL username
  host: 'localhost',
  database: 'weather_app', // Your database name
  password: 'sasmitha', // Your PostgreSQL password
  port: 5432,
});

// Test database connection
pool.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err);
  } else {
    console.log('Connected to the database');
  }
});

// API endpoint for creating an account
app.post('/create_account', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Please provide all fields.' });
  }

  try {
    // Hash the password before storing
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert the new user into the database
    const result = await pool.query(
      'INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING *',
      [username, email, hashedPassword]
    );

    // Send back success response
    return res.status(200).json({
      message: 'Account created successfully',
      user: result.rows[0],
    });
  } catch (error) {
    if (error.code === '23505') { // Unique constraint violation (e.g., duplicate email)
      return res.status(400).json({ message: 'Email already exists.' });
    }
    console.error('Error creating account:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// Start the server and bind to localhost
app.listen(port, 'localhost', () => {
  console.log(`Server running on http://localhost:${port}`);
});
