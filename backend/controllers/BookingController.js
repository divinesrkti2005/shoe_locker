const Booking = require("../models/Booking");
const Shoe = require("../models/Shoe");

// Create a new booking
const createBooking = async (req, res) => {
  try {
    const { shoeId, quantity, size } = req.body;

    // Check if shoe exists and has enough stock
    const shoe = await Shoe.findById(shoeId);
    if (!shoe) {
      return res.status(404).json({ error: "Shoe not found" });
    }

    const availableSize = shoe.availableSizes.find(s => s.size === size);
    if (!availableSize || availableSize.quantity < quantity) {
      return res.status(400).json({ error: "Not enough stock for the selected size" });
    }

    const newBooking = new Booking(req.body);
    const savedBooking = await newBooking.save();

    // Decrease stock
    availableSize.quantity -= quantity;
    await shoe.save();
    
    res.status(201).json({ message: "Booking successful!", booking: savedBooking });
  } catch (error) {
    res.status(500).json({ error: "Failed to create booking" });
  }
};

// Get all bookings
const getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.find().populate("shoeId");
    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch bookings" });
  }
};

// Get a single booking by ID
const getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id).populate("shoeId");
    if (!booking) return res.status(404).json({ error: "Booking not found" });
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch booking" });
  }
};

// Cancel a booking
const cancelBooking = async (req, res) => {
  try {
    const updatedBooking = await Booking.findByIdAndUpdate(
      req.params.id,
      { status: "cancelled" },
      { new: true }
    );
    if (!updatedBooking) return res.status(404).json({ error: "Booking not found" });
    res.status(200).json({ message: "Booking cancelled", booking: updatedBooking });
  } catch (error) {
    res.status(500).json({ error: "Failed to cancel booking" });
  }
};

// Get bookings by user ID
const getBookingsByUserId = async (req, res) => {
  try {
    const { userId } = req.params;
    const bookings = await Booking.find({ userId }).populate("shoeId");
    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch user bookings" });
  }
};

module.exports = {
  createBooking,
  getAllBookings,
  getBookingById,
  cancelBooking,
  getBookingsByUserId,
};
