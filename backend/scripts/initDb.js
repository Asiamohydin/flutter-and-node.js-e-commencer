const fs = require('fs');
const bcrypt = require('bcrypt');
const pool = require('../config/db');

async function columnExists(schema, table, column) {
  const [rows] = await pool.query(
    'SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?',
    [schema, table, column]
  );
  return (rows[0].cnt || rows[0].COUNT || 0) > 0;
}

(async function init() {
  try {
    const sql = fs.readFileSync(__dirname + '/../db/init.sql', 'utf8');
    const statements = sql.split(';').map(s => s.trim()).filter(s => s.length);
    for (const stmt of statements) {
      await pool.query(stmt);
    }

    // Ensure users table has password and role columns (handle older schemas)
    const dbName = process.env.DB_NAME || 'purple_shop';
    if (!(await columnExists(dbName, 'users', 'password'))) {
      console.log('Adding missing column `password` to users table');
      await pool.query("ALTER TABLE users ADD COLUMN password VARCHAR(255) NOT NULL DEFAULT ''");
    }
    if (!(await columnExists(dbName, 'users', 'role'))) {
      console.log('Adding missing column `role` to users table');
      await pool.query("ALTER TABLE users ADD COLUMN role ENUM('user','admin') DEFAULT 'user'");
    }

    // Fix orders table if necessary
    const [orderCols] = await pool.query("SHOW COLUMNS FROM orders");
    const hasTotal = orderCols.some(c => c.Field === 'total');
    const hasTotalAmount = orderCols.some(c => c.Field === 'total_amount');
    const hasPaymentMethod = orderCols.some(c => c.Field === 'payment_method');

    if (!hasTotal && hasTotalAmount) {
      await pool.query("ALTER TABLE orders CHANGE COLUMN total_amount total DECIMAL(10,2) NOT NULL");
    } else if (!hasTotal && !hasTotalAmount) {
      await pool.query("ALTER TABLE orders ADD COLUMN total DECIMAL(10,2) NOT NULL AFTER user_id");
    }

    if (!hasPaymentMethod) {
      await pool.query("ALTER TABLE orders ADD COLUMN payment_method VARCHAR(100) AFTER total");
    }

    // Fix status enum to include 'completed'
    await pool.query("ALTER TABLE orders MODIFY COLUMN status ENUM('pending','paid','shipped','delivered','cancelled','completed') DEFAULT 'pending'");

    // Fix order_items table if necessary
    const [itemCols] = await pool.query("SHOW COLUMNS FROM order_items");
    const hasTitle = itemCols.some(c => c.Field === 'title');
    const hasImageUrl = itemCols.some(c => c.Field === 'image_url');
    const hasPrice = itemCols.some(c => c.Field === 'price');
    const hasUnitPrice = itemCols.some(c => c.Field === 'unit_price');

    if (!hasTitle) await pool.query("ALTER TABLE order_items ADD COLUMN title VARCHAR(255) AFTER product_id");
    if (!hasImageUrl) await pool.query("ALTER TABLE order_items ADD COLUMN image_url VARCHAR(1024) AFTER title");

    if (!hasPrice && hasUnitPrice) {
      await pool.query("ALTER TABLE order_items CHANGE COLUMN unit_price price DECIMAL(10,2) NOT NULL");
    } else if (!hasPrice && !hasUnitPrice) {
      await pool.query("ALTER TABLE order_items ADD COLUMN price DECIMAL(10,2) NOT NULL AFTER image_url");
    }

    // seed products if empty or update them
    const products = [
      { id: 1, name: 'Wireless Headphones', description: 'High-quality sound with noise cancellation.', price: 129.99 },
      { id: 2, name: 'Running Shoes', description: 'Lightweight and breathable for all-day comfort.', price: 89.99 },
      { id: 3, name: 'Smart Watch', description: 'Track your fitness and stay connected.', price: 199.99 },
      { id: 4, name: 'Leather Backpack', description: 'Durable and stylish for everyday use.', price: 59.99 },
      { id: 5, name: 'Skin Care Set', description: 'Natural ingredients for glowing skin.', price: 45.00 },
      { id: 6, name: 'Minimalist Lamp', description: 'Modern design for your living room.', price: 35.50 },
      { id: 7, name: 'Gold Necklace', description: 'Elegant piece for special occasions.', price: 250.00 },
      { id: 8, name: 'Yoga Mat', description: 'Non-slip grip for your fitness routine.', price: 25.00 },
    ];

    for (const p of products) {
      await pool.query(
        'INSERT INTO products (id, name, description, price) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), price=VALUES(price)',
        [p.id, p.name, p.description, p.price]
      );
    }

    // seed admin if not exists
    const [rows] = await pool.query("SELECT COUNT(*) as cnt FROM users WHERE role='admin'");
    const cnt = rows[0].cnt || rows[0].COUNT || 0;
    if (cnt === 0) {
      const hash = await bcrypt.hash('admin123', 10);
      await pool.query('INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)', ['Admin', 'admin@example.com', hash, 'admin']);
      console.log('Seeded admin: admin@example.com / admin123');
    }

    console.log('Database initialized');
    process.exit(0);
  } catch (err) {
    console.error('Failed to init DB', err);
    process.exit(1);
  }
})();
