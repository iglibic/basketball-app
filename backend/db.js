const { Pool } = require("pg");

const pool = new Pool({
  host: "localhost",
  port: 5432,
  user: "postgres",
  password: "ErenYeager",
  database: "basketball_app"
});

module.exports = pool;