const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const generateToken = (user) => {
  return jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
};

/**
 * Register a new user
 * @route POST /api/auth/register
 */
exports.register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    const existing = await User.findByEmail(email);
    if (existing) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }
    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password: hashed });
    const token = generateToken(user);
    res.status(201).json({ success: true, user: { id: user.id, name: user.name, email: user.email, role: user.role, image_url: user.image_url }, token });
  } catch (err) {
    next(err);
  }
};

/**
 * Login user and return JWT
 * @route POST /api/auth/login
 */
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await User.findByEmail(email);
    if (!user) return res.status(401).json({ success: false, message: 'Invalid credentials' });
    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ success: false, message: 'Invalid credentials' });
    const token = generateToken(user);
    res.json({ success: true, user: { id: user.id, name: user.name, email: user.email, role: user.role, image_url: user.image_url }, token });
  } catch (err) {
    next(err);
  }
};

exports.updateMe = async (req, res, next) => {
  try {
    const { name, password, image_url } = req.body;
    let hashed = undefined;
    if (password) {
      hashed = await bcrypt.hash(password, 10);
    }
    const user = await User.updateProfile(req.user.id, { name, password: hashed, image_url });
    res.json({ success: true, user });
  } catch (err) {
    next(err);
  }
};
