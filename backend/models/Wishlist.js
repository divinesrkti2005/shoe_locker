const mongoose = require("mongoose");

const wishlistSchema = new mongoose.Schema({
    customer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Customer",
        required: true,
    },
    shoes: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Shoe",
        }
    ],
}, { timestamps: true }); // Automatically adds createdAt & updatedAt

module.exports = mongoose.model("Wishlist", wishlistSchema);
