const express = require("express");
const router = express.Router();
const shoeController = require("../controllers/shoe");
const upload = require("../middleware/uploads");
const { protect, authorize } = require("../middleware/auth");

// Create a new shoe (Admin only)
router.post("/", protect, authorize("admin"), upload.single("image"), shoeController.createShoe);

// Get all shoes with optional filters (Public)
router.get("/", shoeController.getAllShoes);

// Get all shoes for admin dashboard (Admin only)
router.get("/admin/all", protect, authorize("admin"), shoeController.getAllShoes);

// Get featured shoes (Public)
router.get("/featured", shoeController.getFeaturedShoes);

// Get shoes by category (Public)
router.get("/category/:category", shoeController.getShoesByCategory);

// Get a single shoe by ID (Public)
router.get("/:id", shoeController.getShoeById);

// Update a shoe (Admin only)
router.put("/:id", protect, authorize("admin"), upload.single("image"), shoeController.updateShoe);

// Delete a shoe (Admin only)
router.delete("/:id", protect, authorize("admin"), shoeController.deleteShoe);

module.exports = router;






