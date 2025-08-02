const mongoose = require("mongoose");

const shoeSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String, required: true },
    brand: { type: String, required: true },
    price: { type: Number, required: true },
    originalPrice: { type: Number },
    image: { type: String },
    availableSizes: [{ 
      size: { type: Number, required: true },
      quantity: { type: Number, required: true, min: 0 }
    }],
    category: { type: String, required: true, enum: ["Running", "Casual", "Basketball", "Lifestyle", "Athletic"] },
    colors: [{ type: String }],
    condition: { type: String, required: true, enum: ["New", "Like New", "Good", "Fair"], default: "New" },
    inStock: { type: Boolean, default: true },
    featured: { type: Boolean, default: false },
    material: { type: String },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Shoe", shoeSchema);
