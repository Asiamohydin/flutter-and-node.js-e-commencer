import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';

class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final double discount;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
  });

  double get total => subtotal + shippingFee - discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
          _row("Shipping Fee", "\$${shippingFee.toStringAsFixed(2)}"),
          _row("Discount", "-\$${discount.toStringAsFixed(2)}"),
          const Divider(height: 26),
          _row("Total", "\$${total.toStringAsFixed(2)}", isTotal: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isTotal ? Colors.black : AppTheme.greyColor,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 18 : 14)),
          Text(value,
              style: TextStyle(
                  color: isTotal ? AppTheme.primaryColor : Colors.black,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}
