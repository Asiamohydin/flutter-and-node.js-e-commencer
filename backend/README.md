# Backend setup

Prereqs: Node.js, MySQL

1. Install dependencies:
   npm install

2. Set environment variables: copy `.env.example` to `.env` and edit values.

3. Initialize DB (creates tables and seeds an admin user admin@example.com / admin123):
   npm run init-db

4. Start server:
   npm run dev

API endpoints:
- POST /api/auth/register { name, email, password }
- POST /api/auth/login { email, password }
- GET /api/products
- POST /api/products (admin only)
- PUT /api/products/:id (admin only)
- DELETE /api/products/:id (admin only)

Auth: Bearer <token> in Authorization header
