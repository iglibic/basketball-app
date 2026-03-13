const express = require("express");
const pool = require("./db");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Basketball App API running");
});

app.get("/zones", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM zones ORDER BY display_order"
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

app.post("/register", async (req, res) => {
  try {
    const { first_name, last_name, nickname, email, password } = req.body;

    const result = await pool.query(
      `INSERT INTO users 
      (first_name, last_name, nickname, email, password_hash)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *`,
      [first_name, last_name, nickname, email, password]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});