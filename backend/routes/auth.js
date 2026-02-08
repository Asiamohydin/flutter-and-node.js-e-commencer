const express = require('express');
const { body } = require('express-validator');
const router = express.Router();
const authController = require('../controllers/authController');
const { validate } = require('../middleware/validationMiddleware');
const { auth } = require('../middleware/authMiddleware');

router.post('/register',
  [
    body('name').isLength({ min: 2 }).withMessage('Name too short'),
    body('email').isEmail().withMessage('Invalid email'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 chars')
  ],
  validate,
  authController.register
);

router.post('/login',
  [
    body('email').isEmail().withMessage('Invalid email'),
    body('password').exists().withMessage('Password required')
  ],
  validate,
  authController.login
);

router.put('/update-me', auth, authController.updateMe);

module.exports = router;
