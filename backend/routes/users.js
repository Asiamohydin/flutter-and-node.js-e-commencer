const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { auth } = require('../middleware/authMiddleware');
const { permit } = require('../middleware/roleMiddleware');

// All user management routes are admin only
router.use(auth, permit('admin'));

router.get('/', userController.list);
router.get('/:id', userController.get);
router.put('/:id', userController.update);
router.delete('/:id', userController.remove);

module.exports = router;
