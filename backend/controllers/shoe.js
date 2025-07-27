const Shoe = require("../models/Shoe");

// Create a new shoe
exports.createShoe = async (req, res) => {
  try {
    const { 
      name, description, brand, price, originalPrice, 
      availableSizes, category, color, colors, condition, 
      inStock, featured, stockQuantity, material 
    } = req.body;
    const image = req.file ? req.file.filename : null;

    // Handle stockQuantity and availableSizes
    let finalSizes = [];
    if (availableSizes && typeof availableSizes === 'string') {
      try {
        finalSizes = JSON.parse(availableSizes);
      } catch (e) {
        console.error("Invalid JSON for availableSizes:", availableSizes);
      }
    } else if (stockQuantity) {
      // If form sends stockQuantity, create a default size entry.
      finalSizes.push({ size: 0, quantity: parseInt(stockQuantity, 10) });
    }

    // Handle colors
    let finalColors = [];
    if (colors && typeof colors === 'string') {
      finalColors = colors.split(",").map(c => c.trim());
    } else if (color) {
      finalColors = [color];
    }

    // Handle originalPrice
    const finalOriginalPrice = originalPrice || price;

    const newShoe = new Shoe({
      name,
      description,
      brand,
      price,
      originalPrice: finalOriginalPrice,
      image,
      availableSizes: finalSizes,
      category,
      colors: finalColors,
      condition: condition || "New",
      inStock: inStock !== undefined ? inStock : true,
      featured: featured || false,
      material
    });

    const savedShoe = await newShoe.save();
    res.status(201).json(savedShoe);
  } catch (error) {
    console.error("Error creating shoe:", error); // Add detailed logging
    res.status(500).json({ error: error.message });
  }
};

// Get all shoes
exports.getAllShoes = async (req, res) => {
  try {
    const { category, brand, minPrice, maxPrice, inStock, featured } = req.query;
    let query = {};

    // Apply filters
    if (category) query.category = category;
    if (brand) query.brand = { $regex: brand, $options: 'i' };
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }
    if (inStock !== undefined) query.inStock = inStock === 'true';
    if (featured === 'true') query.featured = true;

    const shoes = await Shoe.find(query).sort({ createdAt: -1 });
    res.status(200).json(shoes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get a single shoe by ID
exports.getShoeById = async (req, res) => {
  try {
    const shoe = await Shoe.findById(req.params.id);
    if (!shoe) return res.status(404).json({ message: "Shoe not found" });
    res.status(200).json(shoe);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update a shoe
exports.updateShoe = async (req, res) => {
  try {
    const { availableSizes, colors } = req.body;

    // Parse availableSizes if it's a string
    if (availableSizes && typeof availableSizes === 'string') {
      req.body.availableSizes = JSON.parse(availableSizes);
    }

    // Parse colors if it's a string
    if (colors && typeof colors === 'string') {
      req.body.colors = colors.split(",").map(color => color.trim());
    }

    const updatedShoe = await Shoe.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedShoe) return res.status(404).json({ message: "Shoe not found" });
    res.status(200).json(updatedShoe);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete a shoe
exports.deleteShoe = async (req, res) => {
  try {
    const deletedShoe = await Shoe.findByIdAndDelete(req.params.id);
    if (!deletedShoe) return res.status(404).json({ message: "Shoe not found" });
    res.status(200).json({ message: "Shoe deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get featured shoes
exports.getFeaturedShoes = async (req, res) => {
  try {
    const featuredShoes = await Shoe.find({ featured: true, inStock: true }).limit(8);
    res.status(200).json(featuredShoes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get shoes by category
exports.getShoesByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const shoes = await Shoe.find({ category, inStock: true });
    res.status(200).json(shoes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
