const express = require('express');
const { body } = require('express-validator');
const router = express.Router();
const productController = require('../controllers/productController');
const { auth } = require('../middleware/authMiddleware');
const { permit } = require('../middleware/roleMiddleware');
const { validate } = require('../middleware/validationMiddleware');

router.get('/', productController.list);
router.get('/:id', productController.get);

// Admin only
router.post('/',
  auth,
  permit('admin'),
  [
    body('name').isLength({ min: 1 }).withMessage('Name required'),
    body('price').isFloat({ gt: 0 }).withMessage('Price must be > 0')
  ],
  validate,
  productController.create
);

router.put('/:id', auth, permit('admin'), productController.update);
router.delete('/:id', auth, permit('admin'), productController.remove);

module.exports = router;
