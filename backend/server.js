require("dotenv").config();

const express = require("express");
const pool = require("./db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");
const multer = require("multer");
const path = require("path");

const app = express();

// Omogućimo da se fajlovi iz /uploads serviraju klijentu.
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

transporter.verify((error, success) => {
  if (error) {
    console.log("Mail config error:", error);
  } else {
    console.log("Mail server ready");
  }
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },

  filename: (req, file, cb) => {
    cb(
      null,
      `profile_${req.user.user_id}${path.extname(file.originalname)}`
    );
  },
});

const upload = multer({ storage });

app.use(express.json());

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

    const verificationToken = jwt.sign(
      { email },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    const newUser = await pool.query(
      `INSERT INTO users 
      (first_name, last_name, nickname, email, password_hash, verification_token)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *`,
      [first_name, last_name, nickname, email, hashedPassword, verificationToken]
    );

    const verificationLink = `http://localhost:3000/verify/${verificationToken}`;

    console.log("Trying to send email to:", email);

    try {
      const info = await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Verify your email for Basketball App",
        html: `
      <h1>Welcome to Basketball App, ${first_name}!</h1>
      <p>Please click the link below to verify your email address:</p>

      <a href="${verificationLink}">
        Verify Email
      </a>
    `,
      });

      console.log("EMAIL SENT:", info.messageId);

    } catch (mailError) {
      console.error("MAIL ERROR:");
      console.error(mailError);
    }

    const user = newUser.rows[0];

    res.json({
      message: "Registration successful. Check your email."
    });
  } catch (err) {
    console.error(err);

    if (err.code === "23505") {

      if (err.detail.includes("(email)")) {
        return res
          .status(400)
          .send("Email already exists.");
      }

      if (err.detail.includes("(nickname)")) {
        return res
          .status(400)
          .send("Nickname already exists.");
      }
    }

    res.status(500).send("Server error!");
  }
});

app.get("/verify/:token", async (req, res) => {
  try {
    const { token } = req.params;

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    await pool.query(
      `UPDATE users
       SET is_verified = true,
           verification_token = NULL
       WHERE email = $1`,
      [decoded.email]
    );

    res.send("Email verified successfully!");
  } catch (err) {
    console.error(err);
    res.status(400).send("Invalid or expired token!");
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

    if (!user.is_verified) {
      return res
        .status(403)
        .send("Please verify your email first!");
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).send("Invalid email or password!");
    }

    const token = jwt.sign(
      { user_id: user.user_id },
      process.env.JWT_SECRET,
      { expiresIn: "3h" }
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

app.get("/zones", authMiddleware, async (req, res) => {
  try {

    const zones = await pool.query(
      `SELECT *
       FROM zones
       WHERE is_active = true
       ORDER BY display_order`
    );

    res.json(zones.rows);

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

    if (training_id === undefined || zone_id === undefined || made === undefined) {
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
    const { trainingId } = req.params;

    const trainingCheck = await pool.query(
      "SELECT * FROM trainings WHERE training_id = $1 AND user_id = $2",
      [trainingId, user_id]
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
      [trainingId]
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

    let percentage = 0;

    if (total_shots > 0) {
      percentage = Math.round(
        (made_shots / total_shots) * 100
      );
    }

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

      let percentage = 0;

      if (total_shots > 0) {
        percentage = Math.round(
          (made_shots / total_shots) * 100
        );
      }

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

    if (typeof total_shots !== "number" || total_shots <= 0) {
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
    const { zone_id, planned_shots } = req.body;

    if (zone_id === undefined || planned_shots === undefined) {
      return res.status(400).send("Zone ID and planned shots are required!");
    }

    if (planned_shots <= 0 || typeof planned_shots !== "number") {
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

app.get("/templates/:templateId/zones", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { templateId } = req.params;
    const templateCheck = await pool.query(
      `SELECT * FROM training_templates 
       WHERE template_id = $1 AND (is_public = true OR creator_user_id = $2)`,
      [templateId, user_id]
    );

    if (templateCheck.rows.length === 0) {
      return res.status(404).send("Template not found!");
    }

    const zones = await pool.query(
      `SELECT tz.*, z.zone_name 
       FROM template_zones tz 
        JOIN zones z ON tz.zone_id = z.zone_id
        WHERE tz.template_id = $1
        ORDER BY z.display_order`,
      [templateId]
    );

    res.json(zones.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/global-stats", authMiddleware, async (req, res) => {
  try {

    const stats = await pool.query(
      `SELECT
        z.zone_id,
        z.zone_name,
        COUNT(*) AS total_shots,
        COUNT(*) FILTER (WHERE s.made = true) AS made_shots
       FROM shots s
       JOIN zones z
       ON s.zone_id = z.zone_id
       GROUP BY z.zone_id, z.zone_name, z.display_order
       ORDER BY z.display_order`
    );

    const zones = stats.rows.map((row) => {

      const total_shots = Number(row.total_shots);
      const made_shots = Number(row.made_shots);

      let percentage = 0;

      if (total_shots > 0) {
        percentage = Math.round(
          (made_shots / total_shots) * 100
        );
      }

      return {
        zone_id: row.zone_id,
        zone_name: row.zone_name,
        total_shots,
        made_shots,
        percentage
      };
    });

    const overall = await pool.query(
      `SELECT
       COUNT(*) AS total_shots,
       COUNT(*) FILTER (WHERE made = true) AS made_shots
       FROM shots`
    );

    const totalShots =
      Number(overall.rows[0].total_shots);

    const madeShots =
      Number(overall.rows[0].made_shots);

    let overallPercentage = 0;

    if (totalShots > 0) {
      overallPercentage = Math.round(
        (madeShots / totalShots) * 100
      );
    }
    res.json({
      overall_percentage: overallPercentage,
      zones
    });

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/my-stats", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;

    const stats = await pool.query(
      `SELECT
        COUNT(*) AS total_shots,
        COUNT(*) FILTER (WHERE s.made = true) AS made_shots
       FROM shots s
       JOIN trainings t
       ON s.training_id = t.training_id
       WHERE t.user_id = $1`,
      [user_id]
    );

    const trainings = await pool.query(
      `SELECT
        COUNT(*) AS trainings_count
       FROM trainings
       WHERE user_id = $1`,
      [user_id]
    );

    const total_shots =
      Number(stats.rows[0].total_shots);

    const made_shots =
      Number(stats.rows[0].made_shots);

    const missed_shots =
      total_shots - made_shots;

    let percentage = 0;

    if (total_shots > 0) {
      percentage = Math.round(
        (made_shots / total_shots) * 100
      );
    }

    res.json({
      total_shots,
      made_shots,
      missed_shots,
      trainings: Number(
        trainings.rows[0].trainings_count
      ),
      percentage
    });

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/me", authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT
        user_id,
        first_name,
        last_name,
        nickname,
        email,
        position,
        dominant_hand,
        profile_image
      FROM users
      WHERE user_id = $1
      `,
      [req.user.user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: "Server error",
    });
  }
});

app.get("/recent-workouts", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;

    const result = await pool.query(
      `
      SELECT
        t.training_id,
        t.training_name,
        t.started_at,

        COUNT(s.shot_id) AS total_shots,

        COUNT(*) FILTER (WHERE s.made = true) AS made_shots,

        CASE
          WHEN COUNT(s.shot_id) = 0 THEN 0
          ELSE ROUND(
            COUNT(*) FILTER (WHERE s.made = true) * 100.0
            / COUNT(s.shot_id)
          )
        END AS percentage

      FROM trainings t

      LEFT JOIN shots s
      ON t.training_id = s.training_id

      WHERE t.user_id = $1

      GROUP BY
        t.training_id,
        t.training_name,
        t.started_at

      ORDER BY t.started_at DESC

      LIMIT 2
      `,
      [user_id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});


app.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;

    const userResult = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).send("User not found!");
    }

    const resetCode =
      Math.floor(100000 + Math.random() * 900000)
        .toString();

    const expires = new Date(
      Date.now() + 10 * 60 * 1000
    );

    await pool.query(
      `UPDATE users
       SET reset_code = $1,
           reset_code_expires = $2
       WHERE email = $3`,
      [resetCode, expires, email]
    );

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: "BasketIQ Password Reset",
      html: `
        <h2>Password Reset</h2>

        <p>Your reset code is:</p>

        <h1>${resetCode}</h1>

        <p>This code expires in 10 minutes.</p>
      `,
    });

    res.send("Reset code sent!");
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.post("/verify-reset-code", async (req, res) => {
  try {
    const { email, code } = req.body;

    const result = await pool.query(
      `SELECT *
       FROM users
       WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).send("User not found!");
    }

    const user = result.rows[0];

    if (user.reset_code !== code) {
      return res.status(400).send("Invalid code!");
    }

    if (
      !user.reset_code_expires ||
      new Date(user.reset_code_expires) < new Date()
    ) {
      return res.status(400).send("Code expired!");
    }

    res.send("Code verified!");
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.post("/reset-password", async (req, res) => {
  try {
    const {
      email,
      code,
      newPassword
    } = req.body;

    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).send("User not found!");
    }

    const user = result.rows[0];

    if (user.reset_code !== code) {
      return res.status(400).send("Invalid code!");
    }

    if (
      !user.reset_code_expires ||
      new Date(user.reset_code_expires) < new Date()
    ) {
      return res.status(400).send("Code expired!");
    }

    const hashedPassword =
      await bcrypt.hash(newPassword, 10);

    await pool.query(
      `UPDATE users
       SET password_hash = $1,
           reset_code = NULL,
           reset_code_expires = NULL
       WHERE email = $2`,
      [hashedPassword, email]
    );

    res.send("Password reset successful!");
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.get("/all-trainings", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.user_id;

    const result = await pool.query(
      `
      SELECT
        t.training_id,
        t.training_name,
        t.started_at,
        t.finished_at,
        t.duration_minutes,

        COUNT(s.shot_id) AS total_shots,

        CASE
          WHEN COUNT(s.shot_id) = 0 THEN 0
          ELSE ROUND(
            COUNT(*) FILTER (WHERE s.made = true) * 100.0
            / COUNT(s.shot_id)
          )
        END AS percentage

      FROM trainings t

      LEFT JOIN shots s
      ON s.training_id = t.training_id

      WHERE t.user_id = $1

      GROUP BY
        t.training_id,
        t.training_name,
        t.started_at

      ORDER BY t.started_at DESC
      `,
      [user_id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).send("Server error!");
  }
});

app.put("/change-password", authMiddleware, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        message: "All fields are required",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        message: "Password must be at least 6 characters long",
      });
    }

    const users = await pool.query(
      "SELECT password_hash FROM users WHERE user_id = $1",
      [req.user.user_id]
    );

    if (users.rows.length === 0) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    const validPassword = await bcrypt.compare(
      currentPassword,
      users.rows[0].password_hash
    );

    if (!validPassword) {
      return res.status(400).json({
        message: "Current password is incorrect!",
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({
        message: "Password must be at least 8 characters!",
      });
    }

    if (!/[A-Z]/.test(newPassword)) {
      return res.status(400).json({
        message: "Password must contain at least one uppercase letter!",
      });
    }

    if (!/[0-9]/.test(newPassword)) {
      return res.status(400).json({
        message: "Password must contain at least one number!",
      });
    }

    if (!/[!@#$%^&*(),.?":{}|<>]/.test(newPassword)) {
      return res.status(400).json({
        message: "Password must contain at least one special character!",
      });
    }

    const hashedPassword = await bcrypt.hash(
      newPassword,
      10
    );

    await pool.query(
      "UPDATE users SET password_hash = $1 WHERE user_id = $2",
      [hashedPassword, req.user.user_id]
    );

    res.json({
      message: "Password changed successfully!",
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Server error!",
    });
  }
});

app.put("/update-profile", authMiddleware, async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      nickname,
      position,
      dominantHand,
    } = req.body;

    if (!firstName || !lastName || !nickname) {
      return res.status(400).json({
        message: "All fields are required",
      });
    }

    const existingUser = await pool.query(
      `
      SELECT user_id
      FROM users
      WHERE nickname = $1
      AND user_id != $2
      `,
      [nickname, req.user.user_id]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        message: "Nickname already taken",
      });
    }

    await pool.query(
      `
      UPDATE users
      SET
        first_name = $1,
        last_name = $2,
        nickname = $3,
        position = $4,
        dominant_hand = $5
      WHERE user_id = $6
      `,
      [
        firstName,
        lastName,
        nickname,
        position,
        dominantHand,
        req.user.user_id,
      ]
    );

    res.json({
      message: "Profile updated successfully",
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Server error",
    });
  }
});

app.post("/upload-profile-image", authMiddleware, upload.single("image"),
  async (req, res) => {
    try {
      const userId = req.user.user_id;
      const newImagePath = `/uploads/${req.file.filename}`;

      // 1) Obrisi stari fajl (ako postoji)
      const oldUser = await pool.query(
        `SELECT profile_image FROM users WHERE user_id = $1`,
        [userId]
      );

      const oldImage = oldUser.rows[0]?.profile_image;
      if (oldImage) {
        const oldFilePath = path.join(__dirname, oldImage.startsWith('/uploads/') ? oldImage : `uploads/${path.basename(oldImage)}`);
        const fs = require('fs');
        fs.promises.unlink(oldFilePath).catch(() => {});
      }

      // 2) Update u bazi
      await pool.query(
        `
        UPDATE users
        SET profile_image = $1
        WHERE user_id = $2
        `,
        [newImagePath, userId]
      );

      res.json({
        image: newImagePath,
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        message: "Server error",
      });
    }
  }
);

app.delete("/delete-profile-image", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.user_id;

    // 1) Uzmi i obriši fajl
    const oldUser = await pool.query(
      `SELECT profile_image FROM users WHERE user_id = $1`,
      [userId]
    );

    const oldImage = oldUser.rows[0]?.profile_image;

    if (oldImage) {
      const oldFilePath = path.join(__dirname, oldImage.startsWith('/uploads/') ? oldImage : `uploads/${path.basename(oldImage)}`);
      const fs = require('fs');
      fs.promises.unlink(oldFilePath).catch(() => {});
    }

    // 2) Ukloni iz baze
    await pool.query(
      `
      UPDATE users
      SET profile_image = NULL
      WHERE user_id = $1
      `,
      [userId]
    );

    res.json({
      message: 'Profile image deleted successfully',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: "Server error",
    });
  }
});


function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).send("No token, authorization denied!");
  }

  const token = authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).send("No token, authorization denied!");
  }

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    req.user = decoded;

    next();

  } catch (err) {
    console.error(err);
    return res.status(403).send("Invalid token!");
  }
}

app.listen(3000, () => {
  console.log("Server running on port 3000...");
});