const express = require('express');
const { body } = require('express-validator');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { auth } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validationMiddleware');

router.post('/',
    auth,
    [
        body('items').isArray({ min: 1 }).withMessage('Items must be a non-empty array'),
        body('total').isFloat({ gt: 0 }).withMessage('Total must be greater than 0'),
        body('paymentMethod').notEmpty().withMessage('Payment method required')
    ],
    validate,
    orderController.create
);
router.get('/', auth, orderController.list);
router.get('/stats', auth, orderController.stats);
router.get('/:id', auth, orderController.get);
router.put('/:id', auth, orderController.update);
router.delete('/:id', auth, orderController.remove);

module.exports = router;
