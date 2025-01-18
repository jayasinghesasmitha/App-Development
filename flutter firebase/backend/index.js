const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');

// Initialize Express app
const app = express();
const port = 12330;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Initialize Firebase Admin SDK
const serviceAccount = require('./path-to-service-account-key.json'); // Replace with your downloaded Firebase Admin SDK JSON file
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://weather-app-8dff8.firebaseio.com"
});

// API endpoint for creating an account
app.post('/create_account', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Please provide all fields.' });
  }

  try {
    // Create user in Firebase Authentication
    const user = await admin.auth().createUser({
      email,
      password,
      displayName: username,
    });

    // Save additional user data in Firestore
    await admin.firestore().collection('users').doc(user.uid).set({
      username,
      email,
    });

    return res.status(200).json({ message: 'Account created successfully', user });
  } catch (error) {
    console.error('Error creating account:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// Start the server
app.listen(port, 'localhost', () => {
  console.log(`Server running on http://localhost:${port}`);
});
