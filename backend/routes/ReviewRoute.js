const express = require("express")
const router = express.Router();
const { findAll, save, findById, deleteById, update } = require("../controller/ReviewController");
const PackageValidation = require("../validation/ReviewValidation");


router.get("/", findAll);
router.post("/", ReviewValidation, save);
router.get("/:id", findById);
router.delete("/:id", deleteById);
router.put("/:id", update)



module.exports = router;
