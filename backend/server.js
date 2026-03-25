require("dotenv").config();

const express = require("express");
const pool = require("./db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Basketball App API running...");
});

app.get("/zones", async (req, res) => {
  try {
    const zones = await pool.query(
      "SELECT * FROM zones ORDER BY display_order"
    );

    res.json(zones.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.post("/register", async (req, res) => {
  try {
    const { first_name, last_name, nickname, email, password } = req.body;

    if (!first_name || !last_name || !nickname || !email || !password) {
      return res.status(400).send("All fields are required!");
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await pool.query(
      `INSERT INTO users 
      (first_name, last_name, nickname, email, password_hash)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *`,
      [first_name, last_name, nickname, email, hashedPassword]
    );

    res.json(newUser.rows[0]);
  } catch (err) {
    console.error(err);

    if (err.code === "23505") {
      return res.status(400).send("Email or nickname already exists!");
    }

    res.status(500).send("Server error!");
  }
});

app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).send("Email and password are required!");
    }

    const userResult = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (userResult.rows.length === 0) {
      return res.status(400).send("Invalid email or password!");
    }

    const user = userResult.rows[0];

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).send("Invalid email or password!");
    }

    const token = jwt.sign(
      { user_id: user.user_id },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.json({
      token,
      user: {
        user_id: user.user_id,
        first_name: user.first_name,
        last_name: user.last_name,
        nickname: user.nickname,
        email: user.email
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/trainings", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.user_id;

    const trainings = await pool.query(
      "SELECT * FROM trainings WHERE user_id = $1 ORDER BY started_at DESC",
      [userId]
    );

    res.json(trainings.rows);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.post("/trainings", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { training_name, template_id } = req.body;

    if (!training_name) {
      return res.status(400).send("Training name is required!");
    }

    const newTraining = await pool.query(
      `INSERT INTO trainings 
      (user_id, training_name, template_id)
      VALUES ($1, $2, $3)
      RETURNING *`,
      [user_id, training_name, template_id]
    );

    res.json(newTraining.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

function authMiddleware(req, res, next) {
  const token = req.headers.authorization && req.headers.authorization.split(" ")[1];

  if (!token) {
    return res.status(401).send("No token, authorization denied!");
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    req.user = decoded;

    next();
  } catch (err) {
    console.error(err);
    res.status(403).send("Invalid token!");
  }
}

app.listen(3000, () => {
  console.log("Server running on port 3000...");
});