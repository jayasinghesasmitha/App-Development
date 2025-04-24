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

app.use(cors());
app.use(bodyParser.json());

app.use(session({
  secret: 'simple_secret_key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false }
}));

admin.database.enableLogging(true);

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

    const newInfo = {
      weather,
      rainAmount: Number(rainAmount),
      movement,
      timestamp: timestamp || admin.database.ServerValue.TIMESTAMP,
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

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});