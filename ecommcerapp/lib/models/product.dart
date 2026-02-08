class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final double rating;
  final bool isFavorite;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.stock = 0,
    this.rating = 4.5,
    this.isFavorite = false,
    this.category = 'General',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      stock: json['stock'] ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 4.5,
      category: json['category'] ?? 'General',
    );
  }
}

final List<Product> mockProducts = [
  Product(
    id: '1',
    name: 'Wireless Headphones',
    description: 'High-quality sound with noise cancellation.',
    price: 129.99,
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500&auto=format&fit=crop',
    rating: 4.8,
    category: 'Electronics',
  ),
  Product(
    id: '2',
    name: 'Running Shoes',
    description: 'Lightweight and breathable for all-day comfort.',
    price: 89.99,
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500&auto=format&fit=crop',
    rating: 4.5,
    category: 'Fashion',
  ),
  Product(
    id: '3',
    name: 'Smart Watch',
    description: 'Track your fitness and stay connected.',
    price: 199.99,
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500&auto=format&fit=crop',
    rating: 4.7,
    category: 'Electronics',
  ),
  Product(
    id: '4',
    name: 'Leather Backpack',
    description: 'Durable and stylish for everyday use.',
    price: 59.99,
    imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=500&auto=format&fit=crop',
    rating: 4.3,
    category: 'Fashion',
  ),
  Product(
    id: '5',
    name: 'Skin Care Set',
    description: 'Natural ingredients for glowing skin.',
    price: 45.00,
    imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=500&auto=format&fit=crop',
    rating: 4.6,
    category: 'Beauty',
  ),
  Product(
    id: '6',
    name: 'Minimalist Lamp',
    description: 'Modern design for your living room.',
    price: 35.50,
    imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?q=80&w=500&auto=format&fit=crop',
    rating: 4.4,
    category: 'Home',
  ),
  Product(
    id: '7',
    name: 'Gold Necklace',
    description: 'Elegant piece for special occasions.',
    price: 250.00,
    imageUrl: 'https://images.unsplash.com/photo-1512163143273-bde0e3cc7407?q=80&w=500&auto=format&fit=crop',
    rating: 4.9,
    category: 'Jewelry',
  ),
  Product(
    id: '8',
    name: 'Yoga Mat',
    description: 'Non-slip grip for your fitness routine.',
    price: 25.00,
    imageUrl: 'https://images.unsplash.com/photo-1592432678016-e910b452f9a2?q=80&w=500&auto=format&fit=crop',
    rating: 4.5,
    category: 'Sport',
  ),
];
