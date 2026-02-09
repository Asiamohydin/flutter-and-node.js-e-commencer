import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ecommcerapp/providers/order_provider.dart';
import 'package:ecommcerapp/core/theme.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderProvider>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    child: Icon(Iconsax.box, size: 100, color: Colors.grey.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    child: const Text(
                      'No orders yet',
                      style: TextStyle(fontSize: 18, color: AppTheme.greyColor),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                final orderId = order.id.length >= 8 ? order.id.substring(0, 8) : order.id;
                final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt);

                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #$orderId',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Date
                        Text(
                          formattedDate,
                          style: const TextStyle(color: AppTheme.greyColor, fontSize: 13),
                        ),

                        const SizedBox(height: 8),

                        // Payment method (optional but helpful)
                        Text(
                          'Payment: ${order.paymentMethod}',
                          style: const TextStyle(color: AppTheme.greyColor, fontSize: 13),
                        ),

                        const Divider(height: 30),

                        // Items (Map-based)
                        ...order.items.map((item) {
                          final title = item['title']?.toString() ?? 'Unknown Item';
                          final qty = int.tryParse(item['quantity'].toString()) ?? 0;
                          final price = double.tryParse(item['price'].toString()) ?? 0.0;
                          final imageUrl = item['imageUrl']?.toString() ?? '';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                _OrderImage(imageUrl: imageUrl),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$qty x \$${price.toStringAsFixed(2)}',
                                        style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Divider(height: 30),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '\$${double.parse((order.total).toString()).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'paid': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }
}

class _OrderImage extends StatelessWidget {
  final String imageUrl;

  const _OrderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: imageUrl.isEmpty
          ? const Icon(Iconsax.image, color: AppTheme.greyColor, size: 20)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Iconsax.image, color: AppTheme.greyColor, size: 20),
            ),
    );
  }
}
