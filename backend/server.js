const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const pool = require('./config/db');
const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const userRoutes = require('./routes/users');
const uploadRoutes = require('./routes/upload');
const errorHandler = require('./middleware/errorHandler');
const path = require('path');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/users', userRoutes);
app.use('/api/upload', uploadRoutes);

// Static uploads folder
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Health
app.get('/api/health', (req, res) => res.json({ ok: true }));

// Central error handler
app.use(errorHandler);

// Try simple DB connection on start
(async () => {
  try {
    await pool.getConnection();
    console.log('Connected to MySQL');
  } catch (err) {
    console.error('MySQL connection failed:', err.message);
  }
})();

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
