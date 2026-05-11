const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth.middleware");
const { checkout, getOrderById } = require("../controllers/order.controller");

router.use(auth);

router.post("/checkout", checkout);
router.get("/:id", getOrderById);

module.exports = router;
