const pool = require('../config/db');

const Payment = {
  async create({ orderId, provider, provider_reference, amount, status = 'completed', raw_payload = null }) {
    const [result] = await pool.query(
      'INSERT INTO payments (order_id, provider, provider_reference, amount, status, raw_payload) VALUES (?, ?, ?, ?, ?, ?)',
      [orderId, provider, provider_reference, amount, status, raw_payload ? JSON.stringify(raw_payload) : null]
    );
    return { id: result.insertId, orderId, provider, provider_reference, amount, status };
  },
};

module.exports = Payment;
