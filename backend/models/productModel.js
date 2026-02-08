const pool = require('../config/db');

const Product = {
  async create({ name, description, price, image_url, stock }) {
    const [result] = await pool.query(
      'INSERT INTO products (name, description, price, image_url, stock) VALUES (?, ?, ?, ?, ?)',
      [name, description, price, image_url, stock || 0]
    );
    return { id: result.insertId, name, description, price, image_url, stock: stock || 0 };
  },

  async findAll() {
    const [rows] = await pool.query('SELECT * FROM products ORDER BY id DESC');
    return rows;
  },

  async findById(id) {
    const [rows] = await pool.query('SELECT * FROM products WHERE id = ?', [id]);
    return rows[0];
  },

  async update(id, { name, description, price, image_url, stock }) {
    await pool.query(
      'UPDATE products SET name = ?, description = ?, price = ?, image_url = ?, stock = ? WHERE id = ?',
      [name, description, price, image_url, stock, id]
    );
    return this.findById(id);
  },

  async delete(id) {
    await pool.query('DELETE FROM products WHERE id = ?', [id]);
    return;
  },
};

module.exports = Product;
