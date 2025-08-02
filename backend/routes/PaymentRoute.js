const express = require("express")
const router = express.Router();
const { findAll, save, findById, deleteById, update } = require("../controller/PaymentController");
const PackageValidation = require("../validation/PaymentValidation");


router.get("/", findAll);
router.post("/", PaymentValidation, save);
router.get("/:id", findById);
router.delete("/:id", deleteById);
router.put("/:id", update)



module.exports = router;
