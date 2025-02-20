/*const express = require('express');
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
});*/

/*
"users": {
  "userId123": {
    "email": "user@example.com",
    "selections": [
      {
        "selection": "Provide Information",
        "weather": "Sunny",
        "rainAmount": 10,
        "stayingOrMoving": "Staying"
      },
      {
        "selection": "Provide Information",
        "weather": "Rainy",
        "rainAmount": 50,
        "stayingOrMoving": "Moving"
      }
    ]
  }
}
*/

const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');
const session = require('express-session');
const path = require('path');

// ✅ Load Firebase Admin SDK
const serviceAccount = require(path.join(__dirname, 'weather-app-8dff8-firebase-adminsdk-fbsvc-341ee5b4cb.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://weather-app-8dff8-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.database();
const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

app.use(session({
  secret: 'simple_secret_key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false }
}));

// ✅ Firebase Debugging Log
admin.database.enableLogging(true);

// ✅ Check if Firebase is working
app.get('/test-firebase', async (req, res) => {
  try {
    const testRef = db.ref('test');
    await testRef.set({ message: "Firebase is working!" });
    res.status(200).send({ message: "Firebase connection successful!" });
  } catch (error) {
    console.error("Firebase Test Error:", error);
    res.status(500).send({ message: "Firebase connection failed!", error });
  }
});

// ✅ Create Account
app.post('/create-account', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).send({ message: 'All fields are required.' });
  }

  try {
    const usersRef = db.ref('users');
    const newUserRef = usersRef.push();
    await newUserRef.set({ username, email, password });

    console.log(`Account created for ${email}`);
    res.status(201).send({ message: 'Account created.', userKey: newUserRef.key });
  } catch (error) {
    console.error('Error creating account:', error);
    res.status(500).send({ message: 'Error creating account.', error });
  }
});

// ✅ Login
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
        req.session.userKey = userKey;
        return res.status(200).send({ message: 'Login successful.', email: users[userKey].email, username: users[userKey].username });
      }
    }

    res.status(401).send({ message: 'Invalid credentials.' });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).send({ message: 'Login error.', error });
  }
});

// Save User Selection
app.post('/save-selection', async (req, res) => {
  const { email, selection, weather, rainAmount, movement, location, isCurrentLocation } = req.body;

  console.log('Received data:', req.body);

  if (!email || !selection || !weather || rainAmount === undefined || !movement) {
    return res.status(400).send({ message: 'All fields are required.' });
  }

  try {
    const usersRef = db.ref('users');
    const usersSnapshot = await usersRef.orderByChild('email').equalTo(email).once('value');

    if (!usersSnapshot.exists()) {
      return res.status(404).send({ message: 'User not found.' });
    }

    const userKey = Object.keys(usersSnapshot.val())[0];
    const userSelectionsRef = db.ref(`users/${userKey}/selections`);

    let selectionsSnapshot = await userSelectionsRef.once('value');
    let selections = selectionsSnapshot.val() || [];

    let newSelection = {
      selection,
      weather,
      rainAmount: Number(rainAmount),
      stayingOrMoving: movement
    };

    // Handle location storage when "Get Information" is selected
    if (selection === "Get Information") {
      if (isCurrentLocation) {
        newSelection.trackedLocation = location;  // Store user's current location (latitude, longitude)
      } else {
        newSelection.selectedPlace = location;  // Store manually selected place from the map
      }
    }

    // Add new selection to the array
    selections.push(newSelection);

    // Save updated selections array
    await userSelectionsRef.set(selections);

    return res.status(200).send({ message: 'Selection saved successfully.', selections });

  } catch (error) {
    console.error('Error saving selection:', error);
    return res.status(500).send({
      message: 'Error saving selection.',
      error: error.message || error
    });
  }
});


// ✅ Start Server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
