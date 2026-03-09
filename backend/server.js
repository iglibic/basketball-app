const express = require("express");
const pool = require("./db");

const app = express();

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

app.listen(3000, () => {
  console.log("Server running on port 3000");
});