const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const SECRET_KEY = "d2f78ec5c4eb64c0bfe582ae6228a6059806a082724c9193836754dd3b8f14c4"
const Credential = require("../model/Credential")

const register = async (req, res) => {
    console.log('Register endpoint received body:', req.body); // Debug print
    const { username, password, role } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    const cred = new Credential({ username, password: hashedPassword, role })
    cred.save();
    res.status(201).send(cred);

};

const login = async (req, res) => {
    const { username, password } = req.body;
    const cred = await Credential.findOne({ username });
    if (!cred || !(await bcrypt.compare(password, cred.password))) {
        return res.status(403).send('Invalid username or password');
    }

    const token = jwt.sign({ username: cred.username, role: cred.role }, SECRET_KEY, { expiresIn: '1h' });
    res.json({ token });

};
module.exports = {
    login,
    register
}