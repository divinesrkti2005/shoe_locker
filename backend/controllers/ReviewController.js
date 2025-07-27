const Review = require('../model/Review');
const findAll = async (req, res) => {
    try {
        const reviews = await Review.find().populate(["customerId", "packageId"]);
        res.status(200).json(reviews);
    } catch (e) {
        res.json(e)
    }

}
const save = async (req, res) => {
    try {
        const reviews = new Review(req.body);
        await reviews.save();
        res.status(201).json(reviews)
    } catch (e) {
        res.json(e)
    }

}
const findById = async (req, res) => {
    try {
        const review = await Review.findById(req.params.id);
        res.status(200).json(review)
    } catch (e) {
        res.json(e)

    }


}
const deleteById = async (req, res) => {
    try {
        const review = await Review.findByIdAndDelete(req.params.id);
        res.status(200).json("data Deleted")
    } catch (e) {
        res.json(e)

    }


}
const update = async (req, res) => {
    try {
        const review = await Review.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(201).json(review)
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