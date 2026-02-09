import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:ecommcerapp/core/theme.dart';
import 'package:ecommcerapp/models/product.dart';
import 'package:ecommcerapp/providers/cart_provider.dart';
import 'package:ecommcerapp/providers/wishlist_provider.dart';
import 'package:ecommcerapp/screens/main_screen.dart';
class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize; 
  String? _selectedColorName;

  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _selectedSize = _sizes[1]; // Default to M
    if (widget.product.colors.isNotEmpty) {
      _selectedColorName = widget.product.colors[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlist, child) {
              bool isFavorite = wishlist.isExist(widget.product);
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    color: isFavorite ? Colors.red : Colors.black,
                    size: 20,
                  ),
                  onPressed: () => wishlist.toggleWishlist(widget.product),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-${widget.product.id}',
              child: Container(
                height: 450,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInLeft(
                                child: Text(
                                  widget.product.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FadeInLeft(
                                delay: const Duration(milliseconds: 100),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.product.rating} (120 Reviews)',
                                      style: const TextStyle(color: AppTheme.greyColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        FadeInRight(
                          child: Text(
                            '\$${widget.product.price}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    FadeInUp(
                      child: const Text(
                        'Description',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        "${widget.product.description} This is a premium product designed for style and comfort. Perfect for any occasion.",
                        style: const TextStyle(color: AppTheme.greyColor, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 25),
                    FadeInUp(
                      child: const Text(
                        'Select Size',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Wrap(
                        spacing: 12,
                        children: _sizes.map((size) {
                          bool isSelected = _selectedSize == size;
                          return ChoiceChip(
                            label: Text(size),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                            selectedColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                          );
                        }).toList(),
                      ),
                    ),
                    if (widget.product.colors.isNotEmpty) ...[
                      const SizedBox(height: 25),
                      FadeInUp(
                        child: const Text(
                          'Select Color',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Wrap(
                          spacing: 12,
                          children: widget.product.colors.map((colorName) {
                            bool isSelected = _selectedColorName == colorName;
                            return ChoiceChip(
                              label: Text(colorName),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedColorName = colorName;
                                });
                              },
                              selectedColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.findAncestorStateOfType<MainScreenState>()?.setIndex(2);
              },
              child: Container(
                height: 60,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: const Icon(Iconsax.bag_2),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: widget.product.stock <= 0 ? null : () {
                  Provider.of<CartProvider>(context, listen: false).addToCart(
                    widget.product,
                    color: _selectedColorName,
                    size: _selectedSize,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} Added!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.primaryColor,
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                          context.findAncestorStateOfType<MainScreenState>()?.setIndex(2);
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.product.stock <= 0 ? Colors.grey : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.product.stock <= 0 ? Colors.grey : AppTheme.primaryColor).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.product.stock <= 0 ? 'Out of Stock' : 'Add to Cart',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
