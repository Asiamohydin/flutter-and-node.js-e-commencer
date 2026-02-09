const pool = require('../config/db');

const User = {
  async create({ name, email, password, role = 'user' }) {
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
      [name, email, password, role]
    );
    return { id: result.insertId, name, email, role };
  },

  async findByEmail(email) {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0];
  },

  async findById(id) {
    const [rows] = await pool.query('SELECT id, name, email, role, image_url FROM users WHERE id = ?', [id]);
    return rows[0];
  },

  async findAll() {
    const [rows] = await pool.query('SELECT id, name, email, role FROM users');
    return rows;
  },

  async update(id, { name, email, role }) {
    await pool.query(
      'UPDATE users SET name = ?, email = ?, role = ? WHERE id = ?',
      [name, email, role, id]
    );
    return this.findById(id);
  },

  async delete(id) {
    await pool.query('DELETE FROM users WHERE id = ?', [id]);
  },

  async updateProfile(id, { name, password, image_url }) {
    if (password) {
      if (image_url) {
        await pool.query('UPDATE users SET name = ?, password = ?, image_url = ? WHERE id = ?', [name, password, image_url, id]);
      } else {
        await pool.query('UPDATE users SET name = ?, password = ? WHERE id = ?', [name, password, id]);
      }
    } else {
      if (image_url) {
        await pool.query('UPDATE users SET name = ?, image_url = ? WHERE id = ?', [name, image_url, id]);
      } else {
        await pool.query('UPDATE users SET name = ? WHERE id = ?', [name, id]);
      }
    }
    return this.findById(id);
  }
};

module.exports = User;
