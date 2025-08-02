const express = require("express");
const router = express.Router();
const { verifyKhaltiPayment } = require("../controllers/khaltiController");
router.post("/verify", verifyKhaltiPayment);

module.exports = router;