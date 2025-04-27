const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');
const session = require('express-session');
const path = require('path');

const serviceAccount = require(path.join(__dirname, 'weather-app-8dff8-firebase-adminsdk-fbsvc-341ee5b4cb.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://weather-app-8dff8-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.database();
const app = express();
const PORT = 3000;

// Expiry durations (in milliseconds)
const EXPIRY_DURATION_STAYING_MS = 15 * 60 * 1000; // 15 minutes for Staying
const EXPIRY_DURATION_MOVING_MS = 5 * 60 * 1000;  // 5 minutes for Moving

app.use(cors());
app.use(bodyParser.json());

app.use(session({
  secret: 'simple_secret_key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false }
}));

admin.database.enableLogging(true);

// Test Firebase connection
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

// Create account endpoint
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

// Login endpoint
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

// Save selection endpoint with dynamic expiration based on movement
app.post('/save-selection', async (req, res) => {
  const { email, selection, weather, rainAmount, movement, timestamp, location } = req.body;

  if (!email || !selection || !weather || rainAmount === undefined || !movement) {
    return res.status(400).send({ message: 'Email, selection, weather, rainAmount, and movement are required.' });
  }

  try {
    const usersRef = db.ref('users');
    const usersSnapshot = await usersRef.orderByChild('email').equalTo(email).once('value');

    if (!usersSnapshot.exists()) {
      return res.status(404).send({ message: 'User not found.' });
    }

    const userKey = Object.keys(usersSnapshot.val())[0];
    const userInfoRef = db.ref(`users/${userKey}/information`);

    let infoSnapshot = await userInfoRef.once('value');
    let information = infoSnapshot.val() || [];

    // Use server timestamp if client timestamp is not provided
    const submissionTimestamp = timestamp ? new Date(timestamp).getTime() : admin.database.ServerValue.TIMESTAMP;

    // Set expiration time based on movement
    const expiryDuration = movement === 'Moving' ? EXPIRY_DURATION_MOVING_MS : EXPIRY_DURATION_STAYING_MS;
    const expirationTimestamp = (typeof submissionTimestamp === 'number' ? submissionTimestamp : Date.now()) + expiryDuration;

    const newInfo = {
      weather,
      rainAmount: Number(rainAmount),
      movement,
      timestamp: submissionTimestamp,
      expirationTimestamp: expirationTimestamp,
      location: location || null
    };

    information.push(newInfo);
    await userInfoRef.set(information);

    return res.status(200).send({ message: 'Information saved successfully.' });
  } catch (error) {
    console.error('Error saving information:', error);
    return res.status(500).send({
      message: 'Error saving information.',
      error: error.message || error
    });
  }
});

// Get non-expired weather information endpoint
app.get('/get-information', async (req, res) => {
  try {
    const usersRef = db.ref('users');
    const usersSnapshot = await usersRef.once('value');
    const users = usersSnapshot.val();

    if (!users) {
      return res.status(200).send({ message: 'No data available.', data: [] });
    }

    const currentTime = Date.now();
    let allInformation = [];

    // Iterate through all users and their information
    for (const userKey of Object.keys(users)) {
      const userInfoRef = db.ref(`users/${userKey}/information`);
      const infoSnapshot = await userInfoRef.once('value');
      const information = infoSnapshot.val();

      if (!information) continue;

      // Filter out expired data
      const nonExpiredInfo = information.filter(entry => {
        const expirationTimestamp = entry.expirationTimestamp;
        return expirationTimestamp && currentTime < expirationTimestamp;
      });

      // Add user email to each entry for client-side display
      const userEmail = users[userKey].email;
      const formattedInfo = nonExpiredInfo.map(entry => ({
        email: userEmail,
        weather: entry.weather,
        rainAmount: entry.rainAmount,
        movement: entry.movement,
        timestamp: entry.timestamp,
        location: entry.location
      }));

      allInformation = allInformation.concat(formattedInfo);
    }

    if (allInformation.length === 0) {
      return res.status(200).send({ message: 'No non-expired data available.', data: [] });
    }

    return res.status(200).send({ message: 'Information retrieved successfully.', data: allInformation });
  } catch (error) {
    console.error('Error retrieving information:', error);
    return res.status(500).send({
      message: 'Error retrieving information.',
      error: error.message || error
    });
  }
});

// Function to move expired data to expired_data node
async function moveExpiredData() {
  try {
    const usersRef = db.ref('users');
    const usersSnapshot = await usersRef.once('value');
    const users = usersSnapshot.val();

    if (!users) return;

    const expiredDataRef = db.ref('expired_data');
    let expiredEntries = [];

    for (const userKey of Object.keys(users)) {
      const userInfoRef = db.ref(`users/${userKey}/information`);
      const infoSnapshot = await userInfoRef.once('value');
      let information = infoSnapshot.val();

      if (!information) continue;

      const currentTime = Date.now();
      let updatedInformation = [];
      let expiredForUser = [];

      for (const entry of information) {
        const expirationTimestamp = entry.expirationTimestamp;
        if (expirationTimestamp && currentTime >= expirationTimestamp) {
          // Remove user-specific data and prepare for expired_data
          const expiredEntry = {
            weather: entry.weather,
            rainAmount: entry.rainAmount,
            movement: entry.movement,
            timestamp: entry.timestamp,
            location: entry.location,
            expiredAt: currentTime
          };
          expiredForUser.push(expiredEntry);
        } else {
          updatedInformation.push(entry);
        }
      }

      // Update user's information by removing expired entries
      if (updatedInformation.length !== information.length) {
        await userInfoRef.set(updatedInformation.length > 0 ? updatedInformation : null);
      }

      expiredEntries = expiredEntries.concat(expiredForUser);
    }

    // Save expired entries to expired_data node
    if (expiredEntries.length > 0) {
      const newExpiredRef = expiredDataRef.push();
      await newExpiredRef.set(expiredEntries);
      console.log(`Moved ${expiredEntries.length} expired entries to expired_data.`);
    }
  } catch (error) {
    console.error('Error moving expired data:', error);
  }
}

// Run the expiration check every minute
setInterval(moveExpiredData, 60 * 1000);

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});