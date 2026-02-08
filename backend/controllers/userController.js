const User = require('../models/userModel');

exports.list = async (req, res, next) => {
    try {
        const users = await User.findAll();
        res.json(users);
    } catch (err) {
        next(err);
    }
};

exports.get = async (req, res, next) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({ message: 'User not found' });
        res.json(user);
    } catch (err) {
        next(err);
    }
};

exports.update = async (req, res, next) => {
    try {
        const user = await User.update(req.params.id, req.body);
        res.json(user);
    } catch (err) {
        next(err);
    }
};

exports.remove = async (req, res, next) => {
    try {
        await User.delete(req.params.id);
        res.json({ success: true, message: 'User deleted' });
    } catch (err) {
        next(err);
    }
};
