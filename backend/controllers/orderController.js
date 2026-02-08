const Order = require('../models/orderModel');
const Payment = require('../models/paymentModel');

exports.create = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { items, total, paymentMethod, paymentInfo } = req.body;
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(422).json({ message: 'No items provided' });
    }
    const order = await Order.create({ userId, total, paymentMethod, items });
    // create payment record (assuming synchronous capture)
    await Payment.create({ orderId: order.id, provider: paymentMethod, provider_reference: paymentInfo['reference'] ?? null, amount: total, raw_payload: paymentInfo });
    res.status(201).json(order);
  } catch (err) {
    next(err);
  }
};

exports.list = async (req, res, next) => {
  try {
    if (req.user.role === 'admin') {
      const orders = await Order.findAll();
      return res.json(orders);
    }
    const orders = await Order.findByUserId(req.user.id);
    res.json(orders);
  } catch (err) {
    next(err);
  }
};

exports.get = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (req.user.role !== 'admin' && order.user_id !== req.user.id) return res.status(403).json({ message: 'Forbidden' });
    res.json(order);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Only admins can update order status' });
    }
    const orderId = parseInt(req.params.id);
    const updated = await Order.update(orderId, req.body);
    res.json({ success: true, message: 'Status updated', id: updated?.id, ...updated });
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (req.user.role !== 'admin' && order.user_id !== req.user.id) return res.status(403).json({ message: 'Forbidden' });
    await Order.delete(req.params.id);
    res.json({ success: true, message: 'Order deleted' });
  } catch (err) {
    next(err);
  }
};

exports.stats = async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ message: 'Forbidden' });
    const stats = await Order.getStats();
    res.json(stats);
  } catch (err) {
    next(err);
  }
};