const mongoose = require("mongoose");
const { string } = require("three/webgpu");
const paymentSchema = new mongoose.Schema({
    bookingId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "bookings"
    },
    amount: {
        type: Number,
        required: true
    },
    method: {
        type: String,
        required: true
    },
    status: {
        type: String,
        required: true
    },
    date: {
        type: Date,
        required: true
    }

})
const Payment = mongoose.model("payments", paymentSchema);

module.exports = Payment;