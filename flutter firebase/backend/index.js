const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');

// Initialize Firebase Admin SDK
const serviceAccount = require('C:\\Users\\ASUS\\Documents\\GitHub\\App-Development\\flutter firebase\\backend\\weather-app-8dff8-firebase-adminsdk-fbsvc-341ee5b4cb.json');


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://weather-app-8dff8-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.database();
const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

// Route to create a new user
app.post('/create-account', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).send({ message: 'All fields are required.' });
  }

  try {
    const usersRef = db.ref('users');
    await usersRef.push({ username, email, password });
    res.status(201).send({ message: 'Account created successfully.' });
  } catch (error) {
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
      const isValid = Object.values(users).some(
        (user) => user.email === email && user.password === password
      );

      if (isValid) {
        return res.status(200).send({ message: 'Login successful.' });
      }
    }

    res.status(401).send({ message: 'Invalid email or password.' });
  } catch (error) {
    res.status(500).send({ message: 'Error validating user.', error });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

