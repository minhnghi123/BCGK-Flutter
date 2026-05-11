const pool = require("../config/db");

// GET /api/foods  hoặc  GET /api/foods?categoryId=1
const getAll = async (req, res) => {
  const { categoryId } = req.query;

  try {
    let query = `
      SELECT f.*, c.name AS category_name, c.culture
      FROM foods f
      LEFT JOIN categories c ON f.category_id = c.id
    `;
    const params = [];

    if (categoryId) {
      query += " WHERE f.category_id = $1";
      params.push(categoryId);
    }

    query += " ORDER BY f.id ASC";

    const { rows } = await pool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("Get foods error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

// GET /api/foods/:id
const getById = async (req, res) => {
  const { id } = req.params;

  try {
    const { rows } = await pool.query(
      `SELECT f.*, c.name AS category_name, c.culture
       FROM foods f
       LEFT JOIN categories c ON f.category_id = c.id
       WHERE f.id = $1`,
      [id],
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Food not found" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error("Get food by id error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { getAll, getById };
