import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:ecommcerapp/core/theme.dart';
import 'package:ecommcerapp/providers/cart_provider.dart';
import 'package:ecommcerapp/screens/checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    // Use a List for ListView.builder (Map is not indexable)
    final items = cart.itemsList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    child: Icon(Iconsax.shopping_cart, size: 100, color: Colors.grey.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    child: const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: AppTheme.greyColor)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return FadeInLeft(
                        delay: Duration(milliseconds: 100 * index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: NetworkImage(item.product.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    if (item.selectedColor != null || item.selectedSize != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "${item.selectedColor ?? ''} ${item.selectedSize ?? ''}".trim(),
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                      ),
                                    Text('\$${item.product.price}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => cart.updateQuantity(item.key, -1),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () => cart.updateQuantity(item.key, 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: AppTheme.greyColor)),
                          Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping Fee', style: TextStyle(color: AppTheme.greyColor)),
                          Text('\$5.00', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${(cart.totalAmount + 5).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                          );
                        },
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Checkout',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
