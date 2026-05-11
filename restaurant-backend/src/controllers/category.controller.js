const pool = require("../config/db");

const getAll = async (req, res) => {
  try {
    const { rows } = await pool.query(
      "SELECT * FROM categories ORDER BY id ASC",
    );
    res.json(rows);
  } catch (err) {
    console.error("Get categories error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { getAll };
