const express = require('express');
const cors = require('cors'); // Import cors
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');

// Initialize Express app
const app = express(); // Initialize 'app' here
const port = 3000;

// Middleware
app.use(cors()); // Use CORS after initializing 'app'
app.use(bodyParser.json()); // Parse JSON bodies

// PostgreSQL client configuration
const pool = new Pool({
  user: 'postgres',      // replace with your PostgreSQL username
  host: 'localhost',          // replace with your PostgreSQL host if different
  database: 'weather_app',    // replace with your database name
  password: 'sasmitha',  // replace with your PostgreSQL password
  port: 5432,                 // default PostgreSQL port
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
      user: result.rows[0], // Return the created user (optional)
    });
  } catch (error) {
    console.error('Error creating account:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
