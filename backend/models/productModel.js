const pool = require('../config/db');

const Product = {
  async create({ name, description, price, image_url, stock, category, colors }) {
    const [result] = await pool.query(
      'INSERT INTO products (name, description, price, image_url, stock, category, colors) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [name, description, price, image_url, stock || 0, category || 'General', colors ? JSON.stringify(colors) : null]
    );
    return { id: result.insertId, name, description, price, image_url, stock: stock || 0, category, colors };
  },

  async findAll() {
    const [rows] = await pool.query('SELECT * FROM products ORDER BY id DESC');
    return rows.map(r => ({ ...r, colors: r.colors ? JSON.parse(r.colors) : [] }));
  },

  async findById(id) {
    const [rows] = await pool.query('SELECT * FROM products WHERE id = ?', [id]);
    const r = rows[0];
    if (r) r.colors = r.colors ? JSON.parse(r.colors) : [];
    return r;
  },

  async update(id, { name, description, price, image_url, stock, category, colors }) {
    await pool.query(
      'UPDATE products SET name = ?, description = ?, price = ?, image_url = ?, stock = ?, category = ?, colors = ? WHERE id = ?',
      [name, description, price, image_url, stock, category, colors ? JSON.stringify(colors) : null, id]
    );
    return this.findById(id);
  },

  async delete(id) {
    await pool.query('DELETE FROM products WHERE id = ?', [id]);
    return;
  },
};

module.exports = Product;
