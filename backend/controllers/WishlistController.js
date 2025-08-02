const Wishlist = require("../models/Wishlist");
const Shoe = require("../models/Shoe");

// Add shoe to wishlist
exports.addToWishlist = async (req, res) => {
    try {
        const { shoeId } = req.body;
        const customerId = req.user.id; // Assuming authentication middleware sets req.user

        // Check if the shoe exists
        const shoeExists = await Shoe.findById(shoeId);
        if (!shoeExists) {
            return res.status(404).json({ success: false, message: "Shoe not found" });
        }

        // Find or create wishlist for the customer
        let wishlist = await Wishlist.findOne({ customer: customerId });
        if (!wishlist) {
            wishlist = new Wishlist({ customer: customerId, shoes: [] });
        }

        // Check if the shoe is already in the wishlist
        if (wishlist.shoes.includes(shoeId)) {
            return res.status(400).json({ success: false, message: "Shoe already in wishlist" });
        }

        // Add shoe to wishlist
        wishlist.shoes.push(shoeId);
        await wishlist.save();

        // Fetch updated count
        const updatedCount = wishlist.shoes.length;

        res.status(200).json({ 
            success: true, 
            message: "Added to wishlist", 
            wishlist, 
            count: updatedCount // Return count to update frontend 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};


// Remove shoe from wishlist
exports.removeFromWishlist = async (req, res) => {
    try {
        const { shoeId } = req.params;  // Use body instead of params
        const customerId = req.user.id;

        console.log("Customer ID:", customerId); // Debugging log

        const wishlist = await Wishlist.findOne({ customer: customerId });
        if (!wishlist) {
            return res.status(404).json({ success: false, message: "Wishlist not found" });
        }

        if (!wishlist.shoes.includes(shoeId)) {
            return res.status(400).json({ success: false, message: "Shoe not in wishlist" });
        }

        // Remove shoe from wishlist
        wishlist.shoes = wishlist.shoes.filter(id => id.toString() !== shoeId);
        await wishlist.save();

        // Fetch updated wishlist with populated shoes
        const updatedWishlist = await Wishlist.findOne({ customer: customerId }).populate("shoes");

        // Return updated wishlist count
        res.status(200).json({
            success: true,
            message: "Removed from wishlist",
            wishlist: updatedWishlist,
            count: updatedWishlist.shoes.length, // Send updated count
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};


exports.getWishlistCount = async (req, res) => {
  try {
    const wishlist = await Wishlist.findOne({ user: req.user.id });

    if (!wishlist) {
      return res.status(200).json({ success: true, count: 0 });
    }

    return res.status(200).json({ success: true, count: wishlist.shoes.length });
  } catch (error) {
    console.error("Error fetching wishlist count:", error);
    return res.status(500).json({ success: false, message: "Server Error" });
  }
};

// Get wishlist of a customer
exports.getWishlist = async (req, res) => {
    try {
        const customerId = req.user.id;
        const wishlist = await Wishlist.findOne({ customer: customerId }).populate("shoes");

        if (!wishlist) {
            return res.status(404).json({ success: false, message: "Wishlist not found" });
        }

        res.status(200).json({ success: true, wishlist });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.deleteWishlistItem = async (req, res) => {
    try {
      const userId = req.user.id; // Get user ID from `protect` middleware
      const shoeId = req.params.shoeId;
  
      // Find the user's wishlist
      const wishlist = await Wishlist.findOne({ customer: userId });
  
      if (!wishlist) {
        return res.status(404).json({ success: false, message: "Wishlist not found" });
      }
  
      // Check if shoe exists in wishlist
      const shoeIndex = wishlist.shoes.findIndex(shoe => shoe._id.toString() === shoeId);
      if (shoeIndex === -1) {
        return res.status(404).json({ success: false, message: "Shoe not found in wishlist" });
      }
  
      // Remove shoe from wishlist array
      wishlist.shoes.splice(shoeIndex, 1);
      await wishlist.save();
  
      res.status(200).json({ success: true, message: "Shoe deleted from wishlist" });
    } catch (error) {
      console.error("Error deleting from wishlist:", error);
      res.status(500).json({ success: false, message: "Server error" });
    }
};
