const pool = require("../config/db");

// POST /api/orders/checkout
const checkout = async (req, res) => {
  const userId = req.user.id;

  try {
    // 1. Lấy tất cả items trong cart
    const { rows: cartItems } = await pool.query(
      `SELECT ci.quantity, f.id AS food_id, f.price, f.name
       FROM cart_items ci
       JOIN foods f ON ci.food_id = f.id
       WHERE ci.user_id = $1`,
      [userId],
    );

    if (cartItems.length === 0) {
      return res.status(400).json({ message: "Cart is empty" });
    }

    // 2. Tính toán
    const itemsTotal = cartItems.reduce(
      (sum, item) => sum + parseFloat(item.price) * item.quantity,
      0,
    );
    const discount = parseFloat((itemsTotal * 0.017).toFixed(2)); // 1.7% discount
    const tax = parseFloat((itemsTotal * 0.08).toFixed(2)); // 8% tax
    const delivery = 30;
    const totalPay = parseFloat(
      (itemsTotal - discount + tax + delivery).toFixed(2),
    );

    // 3. Tạo order
    const { rows: orderRows } = await pool.query(
      `INSERT INTO orders (user_id, items_total, discount, tax, delivery_charge, total_pay, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'paid')
       RETURNING *`,
      [userId, itemsTotal, discount, tax, delivery, totalPay],
    );

    const order = orderRows[0];

    // 4. Insert order items
    for (const item of cartItems) {
      await pool.query(
        `INSERT INTO order_items (order_id, food_id, quantity, unit_price)
         VALUES ($1, $2, $3, $4)`,
        [order.id, item.food_id, item.quantity, item.price],
      );
    }

    // 5. Xóa cart sau khi checkout
    await pool.query("DELETE FROM cart_items WHERE user_id = $1", [userId]);

    res.status(201).json({
      message: "Payment successful",
      order: {
        id: order.id,
        itemsTotal,
        discount,
        tax,
        deliveryCharge: delivery,
        totalPay,
        status: order.status,
        createdAt: order.created_at,
      },
    });
  } catch (err) {
    console.error("Checkout error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

// GET /api/orders/:id
const getOrderById = async (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;

  try {
    const { rows: orderRows } = await pool.query(
      "SELECT * FROM orders WHERE id = $1 AND user_id = $2",
      [id, userId],
    );

    if (orderRows.length === 0) {
      return res.status(404).json({ message: "Order not found" });
    }

    const { rows: items } = await pool.query(
      `SELECT oi.quantity, oi.unit_price,
              f.id AS food_id, f.name, f.image_url
       FROM order_items oi
       JOIN foods f ON oi.food_id = f.id
       WHERE oi.order_id = $1`,
      [id],
    );

    res.json({ ...orderRows[0], items });
  } catch (err) {
    console.error("Get order error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { checkout, getOrderById };
