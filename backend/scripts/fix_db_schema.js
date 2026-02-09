require('dotenv').config({ path: '../.env' });
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'purple_shop',
    port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
});

async function migrate() {
    const conn = await pool.getConnection();
    try {
        console.log('Connected to database.');

        // 1. Check and add columns to products
        console.log('Migrating products table...');
        const [prodColumns] = await conn.query('SHOW COLUMNS FROM products');
        const prodColNames = prodColumns.map(c => c.Field);

        if (!prodColNames.includes('stock')) {
            console.log('Adding stock column...');
            await conn.query('ALTER TABLE products ADD COLUMN stock INT NOT NULL DEFAULT 0');
        }

        if (!prodColNames.includes('category')) {
            console.log('Adding category column...');
            await conn.query('ALTER TABLE products ADD COLUMN category VARCHAR(100) DEFAULT "General"');
        }

        if (!prodColNames.includes('image_url')) {
            console.log('Adding image_url column...');
            await conn.query('ALTER TABLE products ADD COLUMN image_url VARCHAR(1024)');
        }

        if (!prodColNames.includes('colors')) {
            console.log('Adding colors column...');
            await conn.query('ALTER TABLE products ADD COLUMN colors TEXT');
        }

        // 2. Check and add columns to users
        console.log('Migrating users table...');
        const [userColumns] = await conn.query('SHOW COLUMNS FROM users');
        const userColNames = userColumns.map(c => c.Field);

        if (!userColNames.includes('image_url')) {
            console.log('Adding image_url column to users...');
            await conn.query('ALTER TABLE users ADD COLUMN image_url VARCHAR(1024)');
        }

        // 3. Ensure Order status default
        console.log('Ensuring order status default...');
        // We can't easily check default value via simple query without parsing, but we can try to modify it to be safe
        // Or just rely on the code change. 
        // Let's explicitly set the default for status if it exists.
        await conn.query("ALTER TABLE orders MODIFY status VARCHAR(50) DEFAULT 'pending'");

        console.log('Migration completed successfully.');

    } catch (err) {
        console.error('Migration failed:', err);
    } finally {
        conn.release();
        pool.end();
    }
}

migrate();
