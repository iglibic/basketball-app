require("dotenv").config();

const express = require("express");
const pool = require("./db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const app = express();

app.use(express.json());

console.log("DB_USER:", process.env.DB_USER);
console.log("DB_HOST:", process.env.DB_HOST);
console.log("DB_PORT:", process.env.DB_PORT);
console.log("DB_NAME:", process.env.DB_NAME);
console.log("DB_PASSWORD exists:", !!process.env.DB_PASSWORD);

pool.query("SELECT NOW()")
  .then(() => console.log("Database connected successfully"))
  .catch(err => console.error("Database connection error:", err));

app.get("/", (req, res) => {
  res.send("Basketball App API running...");
});

app.get("/zones", async (req, res) => {
  try {
    const zones = await pool.query(
      `SELECT * 
      FROM zones 
      ORDER BY display_order`
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

    const user = newUser.rows[0];

    res.json({
      user_id: user.user_id,
      first_name: user.first_name,
      last_name: user.last_name,
      nickname: user.nickname,
      email: user.email,
      is_verified: user.is_verified,
      created_at: user.created_at
    });
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

app.post("/shots", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;

    const { training_id, zone_id, made } = req.body;

    if (!training_id || !zone_id || made === undefined) {
      return res.status(400).send("Training ID, zone ID and made status are required!");
    }

    if (typeof made !== "boolean") {
      return res.status(400).send("Made status must be a boolean!");
    }

    const trainingCheck = await pool.query(
      "SELECT * FROM trainings WHERE training_id = $1 AND user_id = $2",
      [training_id, user_id]
    );

    if (trainingCheck.rows.length === 0) {
      return res.status(404).send("Training not found!");
    }

    const zoneCheck = await pool.query(
      "SELECT * FROM zones WHERE zone_id = $1",
      [zone_id]
    );

    if (zoneCheck.rows.length === 0) {
      return res.status(404).send("Zone not found!");
    }

    const newShot = await pool.query(
      `INSERT INTO shots 
      (training_id, zone_id, made)
      VALUES ($1, $2, $3)
      RETURNING *`,
      [training_id, zone_id, made]
    );

    res.json(newShot.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/trainings/:trainingId/shots", authMiddleware, async (req, res) => {
  try {

    const user_id = req.user.user_id;
    const { training_Id } = req.params;

    const trainingCheck = await pool.query(
      "SELECT * FROM trainings WHERE training_id = $1 AND user_id = $2",
      [training_Id, user_id]
    );

    if (trainingCheck.rows.length === 0) {
      return res.status(404).send("Training not found!");
    }

    const shots = await pool.query(
      `SELECT s.*, z.zone_name
    FROM shots s
    JOIN zones z ON s.zone_id = z.zone_id
    WHERE s.training_id = $1
    ORDER BY s.shot_order ASC, s.shot_time ASC`,
      [training_Id]
    );

    res.json(shots.rows);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.put("/trainings/:trainingId/finish", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { trainingId } = req.params;

    const trainingCheck = await pool.query(
      "SELECT * FROM trainings WHERE training_id = $1 AND user_id = $2",
      [trainingId, user_id]
    );

    if (trainingCheck.rows.length === 0) {
      return res.status(404).send("Training not found!");
    }

    if (trainingCheck.rows[0].finished_at) {
      return res.status(400).send("Training is already finished!");
    }

    const finishedTraining = await pool.query(
      `UPDATE trainings 
      SET finished_at = CURRENT_TIMESTAMP 
      WHERE training_id = $1 
      RETURNING *`,
      [trainingId]
    );

    res.json(finishedTraining.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/trainings/:trainingId/stats", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { trainingId } = req.params;

    const trainingCheck = await pool.query(
      "SELECT * FROM trainings WHERE training_id = $1 AND user_id = $2",
      [trainingId, user_id]
    );

    if (trainingCheck.rows.length === 0) {
      return res.status(404).send("Training not found!");
    }

    const stats = await pool.query(
      `SELECT
      training_id,
      COUNT(*) AS total_shots,
      COUNT(*) FILTER (WHERE made = true) AS made_shots,
      COUNT(*) FILTER (WHERE made = false) AS missed_shots
      FROM shots
      WHERE training_id = $1
      GROUP BY training_id`,
      [trainingId]
    );

    if (stats.rows.length === 0) {
      return res.json({
        training_id: Number(trainingId),
        total_shots: 0,
        made_shots: 0,
        missed_shots: 0,
        percentage: 0
      });
    }

    const statsData = stats.rows[0];

    const total_shots = Number(statsData.total_shots);
    const made_shots = Number(statsData.made_shots);
    const missed_shots = Number(statsData.missed_shots);

    const percentage =
      total_shots === 0 ? 0 : Math.round((made_shots / total_shots) * 100);

    res.json({
      training_id: Number(trainingId),
      total_shots,
      made_shots,
      missed_shots,
      percentage
    });

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/trainings/:trainingId/zone-stats", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { trainingId } = req.params;

    const trainingCheck = await pool.query(
      "SELECT * FROM trainings WHERE training_id = $1 AND user_id = $2",
      [trainingId, user_id]
    );

    if (trainingCheck.rows.length === 0) {
      return res.status(404).send("Training not found!");
    }

    const stats = await pool.query(
      `SELECT
        z.zone_id,
        z.zone_name,
        COUNT(*) AS total_shots,
        COUNT(*) FILTER (WHERE s.made = true) AS made_shots,
        COUNT(*) FILTER (WHERE s.made = false) AS missed_shots
       FROM shots s
       JOIN zones z ON s.zone_id = z.zone_id
       WHERE s.training_id = $1
       GROUP BY z.zone_id, z.zone_name, z.display_order
       ORDER BY z.display_order`,
      [trainingId]
    );

    if (stats.rows.length === 0) {
      return res.json({
        training_id: Number(trainingId),
        zones: []
      });
    }

    const zoneStats = stats.rows.map((row) => {
      const total_shots = Number(row.total_shots);
      const made_shots = Number(row.made_shots);
      const missed_shots = Number(row.missed_shots);

      const percentage =
        total_shots === 0 ? 0 : Math.round((made_shots / total_shots) * 100);

      return {
        zone_id: row.zone_id,
        zone_name: row.zone_name,
        total_shots,
        made_shots,
        missed_shots,
        percentage
      };
    });

    res.json({
      training_id: Number(trainingId),
      zones: zoneStats
    });

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.delete("/shots/:shotId", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { shotId } = req.params;

    const shotCheck = await pool.query(
      `SELECT s.* 
      FROM shots s
      JOIN trainings t ON s.training_id = t.training_id
      WHERE s.shot_id = $1 AND t.user_id = $2`,
      [shotId, user_id]
    );

    if (shotCheck.rows.length === 0) {
      return res.status(404).send("Shot not found!");
    }

    const deletedShot = await pool.query(
      "DELETE FROM shots WHERE shot_id = $1 RETURNING *",
      [shotId]
    );

    res.json(deletedShot.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.put("/shots/:shotId", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { shotId } = req.params;
    const { made } = req.body;

    if (made === undefined) {
      return res.status(400).send("Made status is required!");
    }

    if (typeof made !== "boolean") {
      return res.status(400).send("Made status must be a boolean!");
    }

    const shotCheck = await pool.query(
      `SELECT s.* 
      FROM shots s
      JOIN trainings t ON s.training_id = t.training_id
      WHERE s.shot_id = $1 AND t.user_id = $2`,
      [shotId, user_id]
    );

    if (shotCheck.rows.length === 0) {
      return res.status(404).send("Shot not found!");
    }

    const updatedShot = await pool.query(
      "UPDATE shots SET made = $1 WHERE shot_id = $2 RETURNING *",
      [made, shotId]
    );

    res.json(updatedShot.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/templates", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;

    const templates = await pool.query(
      `SELECT * FROM training_templates
       WHERE is_public = true OR creator_user_id = $1
       ORDER BY created_at DESC`,
      [user_id]
    );

    res.json(templates.rows);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.post("/templates", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { template_name, total_shots, is_public } = req.body;

    if (!template_name || total_shots === undefined || is_public === undefined) {
      return res.status(400).send("All fields are required!");
    }

    if (typeof total_shots !== "number" || total_shots >= 0) {
      return res.status(400).send("Total shots must be a positive number greater than 0!");
    }

    if (typeof is_public !== "boolean") {
      return res.status(400).send("is_public must be a boolean!");
    }

    const newTemplate = await pool.query(
      `INSERT INTO training_templates 
      (creator_user_id, template_name, total_shots, is_public)
      VALUES ($1, $2, $3, $4)
      RETURNING *`,
      [user_id, template_name, total_shots, is_public]
    );

    res.json(newTemplate.rows[0]);
  } catch (err) {
    console.error(err);

    if (err.code === "23505") {
      return res.status(400).send("Template with this name already exists!");
    }
    res.status(500).send("Server error!");
  }
});

app.post("/templates/:templateId/zones", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { templateId } = req.params;
    const {zone_id, planned_shots } = req.body;

    if(!zone_id || planned_shots === undefined) {
      return res.status(400).send("Zone ID and planned shots are required!");
    }

    if(planned_shots <= 0 || typeof planned_shots !== "number") {
      return res.status(400).send("Planned shots must be a positive number!");
    }
    
    const templateCheck = await pool.query(
      `SELECT * FROM training_templates 
       WHERE template_id = $1 AND creator_user_id = $2`,
      [templateId, user_id]
    );

    if (templateCheck.rows.length === 0) {
      return res.status(404).send("Template not found!");
    }

    const zoneCheck = await pool.query(
      "SELECT * FROM zones WHERE zone_id = $1",
      [zone_id]
    );

    if (zoneCheck.rows.length === 0) {
      return res.status(404).send("Zone not found!");
    }

    const newTemplateZone = await pool.query(
      `INSERT INTO template_zones 
      (template_id, zone_id, planned_shots)
      VALUES ($1, $2, $3)
      RETURNING *`,
      [templateId, zone_id, planned_shots]
    );
    res.json(newTemplateZone.rows[0]);
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
};

app.listen(3000, () => {
  console.log("Server running on port 3000...");
});