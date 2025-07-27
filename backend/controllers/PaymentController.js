const Payment = require('../model/Payment')
const findAll = async (req, res) => {
    try {
        const payments = await Payment.find().populate(["bookingId"]);
        res.status(200).json(payments);
    } catch (e) {
        res.json(e)
    }

}
const save = async (req, res) => {
    try {
        const { amount, paymentMethod, paymentStatus, PaidAt, } = req.body
        const payment = new Payment({
            amount,
            paymentMethod,
            paymentStatus,
            PaidAt,
            bookingId: req.body.bookingId




        });
        await payment.save();
        res.status(201).json(payment)
    } catch (e) {
        res.json(e)
    }

}
const findById = async (req, res) => {
    try {
        const payment = await Payment.findById(req.params.id);
        res.status(200).json(payment)
    } catch (e) {
        res.json(e)

    }


}
const deleteById = async (req, res) => {
    try {
        const payment = await Payment.findByIdAndDelete(req.params.id);
        res.status(200).json("data Deleted")
    } catch (e) {
        res.json(e)

    }


}
const update = async (req, res) => {
    try {
        const payment = await Payment.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(201).json(payment)
    } catch (e) {
        res.json(e)

    }


}

module.exports = {
    findAll,
    save,
    findById,
    deleteById,
    update

}