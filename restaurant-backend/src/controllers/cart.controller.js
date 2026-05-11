const pool = require("../config/db");

// GET /api/cart
const getCart = async (req, res) => {
  const userId = req.user.id;

  try {
    const { rows } = await pool.query(
      `SELECT ci.id, ci.quantity,
              f.id AS food_id, f.name, f.price, f.image_url, f.description,
              c.name AS category_name
       FROM cart_items ci
       JOIN foods f ON ci.food_id = f.id
       LEFT JOIN categories c ON f.category_id = c.id
       WHERE ci.user_id = $1
       ORDER BY ci.id ASC`,
      [userId],
    );
    res.json(rows);
  } catch (err) {
    console.error("Get cart error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

// POST /api/cart
// Body: { foodId, quantity }
const addItem = async (req, res) => {
  const userId = req.user.id;
  const { foodId, quantity = 1 } = req.body;

  if (!foodId) {
    return res.status(400).json({ message: "foodId is required" });
  }

  try {
    // Nếu món đã có trong cart thì tăng số lượng
    const { rows } = await pool.query(
      `INSERT INTO cart_items (user_id, food_id, quantity)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id, food_id)
       DO UPDATE SET quantity = cart_items.quantity + EXCLUDED.quantity
       RETURNING *`,
      [userId, foodId, quantity],
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error("Add cart item error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

// PUT /api/cart/:id
// Body: { quantity }
const updateItem = async (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;
  const { quantity } = req.body;

  if (!quantity || quantity < 1) {
    return res.status(400).json({ message: "Quantity must be at least 1" });
  }

  try {
    const { rows } = await pool.query(
      `UPDATE cart_items
       SET quantity = $1
       WHERE id = $2 AND user_id = $3
       RETURNING *`,
      [quantity, id, userId],
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Cart item not found" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error("Update cart item error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

// DELETE /api/cart/:id
const removeItem = async (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;

  try {
    const { rows } = await pool.query(
      `DELETE FROM cart_items
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, userId],
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Cart item not found" });
    }

    res.json({ message: "Item removed from cart" });
  } catch (err) {
    console.error("Remove cart item error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { getCart, addItem, updateItem, removeItem };
