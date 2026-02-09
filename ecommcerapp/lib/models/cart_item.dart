import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;
  final String key;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.key,
    this.selectedColor,
    this.selectedSize,
  });

  CartItem copyWith({int? quantity, String? selectedColor, String? selectedSize}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      key: key,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}
