const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');

// Initialize Firebase Admin SDK
const serviceAccount = require('./weather-app-8dff8-firebase-adminsdk-fbsvc-341ee5b4cb.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://weather-app-8dff8-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.database();
const app = express();
const PORT = 3000;

app.use(cors());

// To parse incoming JSON payloads
app.use(bodyParser.json()); 

// Route to create a new user
app.post('/create-account', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).send({ message: 'All fields are required.' });
  }

  try {
    const usersRef = db.ref('users');
    const newUserRef = usersRef.push(); 
    await newUserRef.set({ username, email, password });
    res.status(201).send({ message: 'Account created successfully.', userKey: newUserRef.key });
  } catch (error) {
    console.error('Error creating account:', error);
    res.status(500).send({ message: 'Failed to create account.', error });
  }
});

// Route to validate user login
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).send({ message: 'Email and password are required.' });
  }

  try {
    const usersSnapshot = await db.ref('users').once('value');
    const users = usersSnapshot.val();

    if (users) {
      const userKey = Object.keys(users).find(key => users[key].email === email && users[key].password === password);
      if (userKey) {
        const user = users[userKey];
        return res.status(200).send({ message: 'Login successful.', email: user.email, username: user.username });
      }
    }

    res.status(401).send({ message: 'Invalid email or password.' });
  } catch (error) {
    console.error('Error validating user:', error);
    res.status(500).send({ message: 'Error validating user.', error });
  }
});

// Route to save selection
app.post('/save-selection', async (req, res) => {
  const { email, selection } = req.body;

  if (!email || !selection) {
    return res.status(400).send({ message: 'Email and selection are required.' });
  }

  try {
    const usersRef = db.ref('users');
    const usersSnapshot = await usersRef.orderByChild('email').equalTo(email).once('value');

    if (usersSnapshot.exists()) {
      const userKey = Object.keys(usersSnapshot.val())[0];
      const userSelectionsRef = db.ref(`users/${userKey}/selections`);

      const selectionsSnapshot = await userSelectionsRef.once('value');
      const existingSelections = selectionsSnapshot.val() || [];
      const updatedSelections = [...existingSelections, selection];

      await userSelectionsRef.set(updatedSelections);

      res.status(200).send({ message: 'Selection added successfully.' });
    } else {
      res.status(404).send({ message: 'User not found.' });
    }
  } catch (error) {
    console.error('Error saving selection:', error);
    res.status(500).send({ message: 'Error saving selection.', error });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});


/*
const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');
const session = require('express-session'); // For session management

// Initialize Firebase Admin SDK
const serviceAccount = require('./weather-app-8dff8-firebase-adminsdk-fbsvc-341ee5b4cb.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://weather-app-8dff8-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.database();
const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

// Set up sessions
app.use(session({
  secret: 'simple_secret_key', // Simple session secret
  resave: false,
  saveUninitialized: true,
  cookie: { secure: false } // Secure: false allows HTTP (change to true for HTTPS)
}));

// Route to create a new user
app.post('/create-account', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).send({ message: 'All fields are required.' });
  }

  try {
    const usersRef = db.ref('users');
    const newUserRef = usersRef.push();
    await newUserRef.set({ username, email, password });
    res.status(201).send({ message: 'Account created successfully.', userKey: newUserRef.key });
  } catch (error) {
    console.error('Error creating account:', error);
    res.status(500).send({ message: 'Failed to create account.', error });
  }
});

// Route to validate user login
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).send({ message: 'Email and password are required.' });
  }

  try {
    const usersSnapshot = await db.ref('users').once('value');
    const users = usersSnapshot.val();

    if (users) {
      const userKey = Object.keys(users).find(key => users[key].email === email && users[key].password === password);
      if (userKey) {
        req.session.userKey = userKey; // Store userKey in session
        return res.status(200).send({ message: 'Login successful.', email: users[userKey].email, username: users[userKey].username });
      }
    }

    res.status(401).send({ message: 'Invalid email or password.' });
  } catch (error) {
    console.error('Error validating user:', error);
    res.status(500).send({ message: 'Error validating user.', error });
  }
});

// Route to save selection under the logged-in user
app.post('/save-selection', async (req, res) => {
  if (!req.session.userKey) {
    return res.status(401).json({ message: 'User not logged in.' });
  }

  const { selection, weather, rainAmount, stayingOrMoving } = req.body;

  if (!selection) {
    return res.status(400).json({ message: 'Selection is required.', receivedData: req.body });
  }

  try {
    const userSelectionsRef = db.ref(`users/${req.session.userKey}/selections/${selection}`);

    // Create a new selection entry with all provided data
    const newSelectionData = {
      weather: weather !== undefined ? weather : null,
      rainAmount: rainAmount !== undefined ? rainAmount : null,
      stayingOrMoving: stayingOrMoving !== undefined ? stayingOrMoving : null,
      timestamp: Date.now()
    };

    // Use `push()` to append new data instead of overwriting existing selections
    await userSelectionsRef.push(newSelectionData);

    res.status(200).json({ message: 'Selection saved successfully.', savedData: newSelectionData });
  } catch (error) {
    console.error('Error saving selection:', error);
    res.status(500).json({ message: 'Error saving selection.', error: error.message });
  }
});

// Route to logout the user
app.post('/logout', (req, res) => {
  req.session.destroy(err => {
    if (err) {
      return res.status(500).send({ message: 'Logout failed.' });
    }
    res.status(200).send({ message: 'Logged out successfully.' });
  });
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});      */