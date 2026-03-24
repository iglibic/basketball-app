const express = require("express");
const pool = require("./db");
const bcrypt = require("bcrypt");


const app = express();

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Basketball App API running");
});

app.get("/zones", async (req, res) => {
  try {
    const zones = await pool.query(
      "SELECT * FROM zones ORDER BY display_order"
    );

    res.json(zones.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

app.post("/register", async (req, res) => {
  try {
    const { first_name, last_name, nickname, email, password } = req.body;

    if (!first_name || !last_name || !nickname || !email || !password) {
      return res.status(400).send("All fields are required");
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
      return res.status(400).send("Email or nickname already exists");
    }

    res.status(500).send("Server error");
  }
});

app.get("/trainings/:user_id", async (req, res) => {
  try {
    const userId = parseInt(req.params.user_id);

    if (isNaN(userId)) {
      return res.status(400).send("Invalid user_id");
    }

    const trainings = await pool.query(
      "SELECT * FROM trainings WHERE user_id = $1 ORDER BY started_at DESC",
      [userId]
    );

    res.json(trainings.rows);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});