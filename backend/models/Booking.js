const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema({
  shoeId: { type: mongoose.Schema.Types.ObjectId, ref: "Shoe", required: true },
  fullName: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, required: true },
  quantity: { type: Number, required: true, min: 1 },
  size: { type: Number, required: true },
  color: { type: String },
  shippingAddress: { type: String, required: true },
  paymentMethod: { type: String, enum: ["credit-card", "debit-card", "upi", "paypal"], required: true },
  status: { type: String, enum: ["pending", "confirmed", "shipped", "delivered", "cancelled"], default: "pending" },
  totalAmount: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Booking", bookingSchema);
