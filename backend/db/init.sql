-- Users
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  image_url VARCHAR(1024),
  role ENUM('user','admin') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  stock INT DEFAULT 0,
  category VARCHAR(100) DEFAULT 'General',
  image_url VARCHAR(1024),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- sample products
INSERT IGNORE INTO products (id, name, description, price) VALUES
(1, 'Sample T-Shirt', 'Comfortable cotton t-shirt', 19.99),
(2, 'Wireless Earbuds', 'High quality sound', 59.99),
(3, 'Ceramic Mug', '350ml mug for coffee', 9.50);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(100),
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Order items
CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  title VARCHAR(255),
  image_url VARCHAR(1024),
  price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Payments / events
CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  provider VARCHAR(100),
  provider_reference VARCHAR(255),
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'completed',
  raw_payload JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Event log (optional)
CREATE TABLE IF NOT EXISTS events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(100),
  payload JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
