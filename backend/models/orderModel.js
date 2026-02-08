const pool = require('../config/db');

const Order = {
  async create({ userId, total, paymentMethod, items }) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();
      const [orderResult] = await conn.query(
        'INSERT INTO orders (user_id, total, payment_method) VALUES (?, ?, ?)',
        [userId, total, paymentMethod]
      );
      const orderId = orderResult.insertId;
      const itemPromises = items.map(item => {
        return conn.query(
          'INSERT INTO order_items (order_id, product_id, title, image_url, price, quantity) VALUES (?, ?, ?, ?, ?, ?)',
          [orderId, item['productId'] || item.productId, item.title, item.imageUrl ?? item.image_url ?? '', item.price, item.quantity]
        );
      });
      await Promise.all(itemPromises);
      await conn.commit();
      return this.findById(orderId);
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  },

  async findById(id) {
    const [rows] = await pool.query('SELECT * FROM orders WHERE id = ?', [id]);
    const order = rows[0];
    if (!order) return null;
    const [items] = await pool.query('SELECT * FROM order_items WHERE order_id = ?', [id]);
    order.items = items;
    return order;
  },

  async findByUserId(userId) {
    const [rows] = await pool.query('SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC', [userId]);
    // attach items
    for (const r of rows) {
      const [items] = await pool.query('SELECT * FROM order_items WHERE order_id = ?', [r.id]);
      r.items = items;
    }
    return rows;
  },

  async findAll() {
    const [rows] = await pool.query(`
      SELECT o.*, u.name as customer_name, u.email as customer_email 
      FROM orders o 
      LEFT JOIN users u ON o.user_id = u.id 
      ORDER BY o.id DESC
    `);
    for (const r of rows) {
      const [items] = await pool.query('SELECT * FROM order_items WHERE order_id = ?', [r.id]);
      r.items = items;
    }
    return rows;
  },

  async update(id, { status }) {
    await pool.query('UPDATE orders SET status = ? WHERE id = ?', [status, id]);
    return this.findById(id);
  },

  async delete(id) {
    // Delete items first if not on cascade
    await pool.query('DELETE FROM order_items WHERE order_id = ?', [id]);
    await pool.query('DELETE FROM orders WHERE id = ?', [id]);
  },

  async getStats() {
    const [incomeResult] = await pool.query('SELECT SUM(total) as totalIncome FROM orders');
    const [countResult] = await pool.query('SELECT COUNT(*) as totalOrders FROM orders');
    const [statsResult] = await pool.query("SELECT status, COUNT(*) as count FROM orders GROUP BY status");

    return {
      totalIncome: Number(incomeResult[0].totalIncome || 0),
      totalOrders: countResult[0].totalOrders || 0,
      byStatus: statsResult
    };
  }
};

module.exports = Order;
