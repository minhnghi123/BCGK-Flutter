const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../config/db");

const generateToken = (user) =>
  jwt.sign(
    { id: user.id, email: user.email, fullName: user.full_name },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || "7d" },
  );

// POST /api/auth/register
const register = async (req, res) => {
  const { email, password, fullName } = req.body;

  if (!email || !password || !fullName) {
    return res
      .status(400)
      .json({ message: "Email, password and full name are required" });
  }

  try {
    const existing = await pool.query("SELECT id FROM users WHERE email = $1", [
      email,
    ]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ message: "Email already registered" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const { rows } = await pool.query(
      `INSERT INTO users (email, password_hash, full_name)
       VALUES ($1, $2, $3)
       RETURNING id, email, full_name`,
      [email, passwordHash, fullName],
    );

    const user = rows[0];
    const token = generateToken(user);

    res.status(201).json({
      message: "Account created successfully",
      token,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
      },
    });
  } catch (err) {
    console.error("Register error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

// POST /api/auth/login
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required" });
  }

  try {
    const { rows } = await pool.query("SELECT * FROM users WHERE email = $1", [
      email,
    ]);

    if (rows.length === 0) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const token = generateToken(user);

    res.json({
      message: "Login successful",
      token,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
      },
    });
  } catch (err) {
    console.error("Login error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

// POST /api/auth/forgot-password
// Đơn giản hóa cho exam: reset password trực tiếp nếu email tồn tại
const forgotPassword = async (req, res) => {
  const { email, newPassword } = req.body;

  if (!email || !newPassword) {
    return res
      .status(400)
      .json({ message: "Email and new password are required" });
  }

  try {
    const { rows } = await pool.query("SELECT id FROM users WHERE email = $1", [
      email,
    ]);

    if (rows.length === 0) {
      return res.status(404).json({ message: "Email not found" });
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);

    await pool.query("UPDATE users SET password_hash = $1 WHERE email = $2", [
      passwordHash,
      email,
    ]);

    res.json({ message: "Password reset successfully" });
  } catch (err) {
    console.error("Forgot password error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { register, login, forgotPassword };
