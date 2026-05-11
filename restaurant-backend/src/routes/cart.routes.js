const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth.middleware");
const {
  getCart,
  addItem,
  updateItem,
  removeItem,
} = require("../controllers/cart.controller");

router.use(auth); // Tất cả cart routes đều cần đăng nhập

router.get("/", getCart);
router.post("/", addItem);
router.put("/:id", updateItem);
router.delete("/:id", removeItem);

module.exports = router;
