const axios = require("axios");



exports.verifyKhaltiPayment = async (req, res) => {
    try {
        const { token, amount } = req.body;

        const response = await axios.post(
            "https://khalti.com/api/v2/payment/verify/",
            { token, amount: amount * 100 },
            {
                headers: {
                    Authorization: "Key test_secret_key_3f78fb6364ef4bd1b5fc670ce33a06f5",
                    "Content-Type": "application/json",
                },
            }
        );

        if (response.data.state.name === "Completed") {
            res.status(200).json({ message: "Payment verified successfully", data: response.data });
        } else {
            res.status(400).json({ message: "Payment verification failed" });
        }
    } catch (error) {
        console.error("Khalti Verification Error:", error);
        res.status(500).json({ message: "Failed to verify Khalti payment" });
    }
};