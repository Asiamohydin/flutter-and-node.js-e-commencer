import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';

class PlaceOrderBar extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onTap;

  const PlaceOrderBar({
    super.key,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: GestureDetector(
        onTap: isProcessing ? null : onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Place Order',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
