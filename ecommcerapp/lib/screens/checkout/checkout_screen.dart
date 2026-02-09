import 'package:ecommcerapp/screens/checkout/widget/order_summary_card.dart';
import 'package:ecommcerapp/screens/checkout/widget/payment_details_form.dart';
import 'package:ecommcerapp/screens/checkout/widget/payment_method_tile.dart';
import 'package:ecommcerapp/screens/checkout/widget/place_order_bar.dart';
import 'package:ecommcerapp/screens/checkout/widget/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommcerapp/providers/cart_provider.dart';
import 'package:ecommcerapp/providers/order_provider.dart';
import 'package:ecommcerapp/core/theme.dart';

enum PaymentMethod { card, evc, edahab, cod }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  PaymentMethod _method = PaymentMethod.card;
  bool _isProcessing = false;

  // Controllers for payment fields
  final cardNumberCtrl = TextEditingController();
  final cardNameCtrl = TextEditingController();
  final cardExpiryCtrl = TextEditingController();
  final cardCvvCtrl = TextEditingController();
  final phoneNumberCtrl = TextEditingController();

  @override
  void dispose() {
    cardNumberCtrl.dispose();
    cardNameCtrl.dispose();
    cardExpiryCtrl.dispose();
    cardCvvCtrl.dispose();
    phoneNumberCtrl.dispose();
    super.dispose();
  }

  String get methodName {
    switch (_method) {
      case PaymentMethod.card:
        return "Card";
      case PaymentMethod.evc:
        return "EVC Plus";
      case PaymentMethod.edahab:
        return "eDahab";
      case PaymentMethod.cod:
        return "Cash on Delivery";
    }
  }

  Map<String, dynamic> buildPaymentInfo() {
    if (_method == PaymentMethod.card) {
      final digits = cardNumberCtrl.text.replaceAll(' ', '').trim();
      final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '';
      return {"cardLast4": last4, "cardName": cardNameCtrl.text.trim()};
    }
    if (_method == PaymentMethod.evc || _method == PaymentMethod.edahab) {
      return {"phoneNumber": phoneNumberCtrl.text.trim()};
    }
    return {"type": "cod"};
  }

  Future<void> _placeOrder() async {
    // Validate payment fields
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isProcessing = true);

    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();

    try {
      // Call backend to place order
      final success = await orders.placeOrder(cart.items, cart.totalAmount, paymentMethod: methodName, paymentInfo: buildPaymentInfo());

      if (success) {
        cart.clearCart();
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        if (!mounted) return;
        _showErrorDialog(orders.lastError ?? 'There was an error processing your payment.');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Shipping Address'),
              const SizedBox(height: 12),
              _shippingCard(),
              const SizedBox(height: 24),

              const SectionTitle('Payment Method'),
              const SizedBox(height: 12),
              PaymentMethodTile(
                title: "Card Payment",
                icon: Icons.credit_card,
                selected: _method == PaymentMethod.card,
                onTap: () => setState(() => _method = PaymentMethod.card),
              ),
              const SizedBox(height: 12),
              PaymentMethodTile(
                title: "EVC Plus",
                icon: Icons.phone_android,
                selected: _method == PaymentMethod.evc,
                onTap: () => setState(() => _method = PaymentMethod.evc),
              ),
              const SizedBox(height: 12),
              PaymentMethodTile(
                title: "eDahab",
                icon: Icons.account_balance_wallet,
                selected: _method == PaymentMethod.edahab,
                onTap: () => setState(() => _method = PaymentMethod.edahab),
              ),
              const SizedBox(height: 12),
              PaymentMethodTile(
                title: "Cash on Delivery",
                icon: Icons.money,
                selected: _method == PaymentMethod.cod,
                onTap: () => setState(() => _method = PaymentMethod.cod),
              ),

              const SizedBox(height: 16),

              PaymentDetailsForm(
                method: _method,
                cardNumberCtrl: cardNumberCtrl,
                cardNameCtrl: cardNameCtrl,
                cardExpiryCtrl: cardExpiryCtrl,
                cardCvvCtrl: cardCvvCtrl,
                phoneNumberCtrl: phoneNumberCtrl,
              ),

              const SizedBox(height: 24),

              const SectionTitle('Order Summary'),
              const SizedBox(height: 12),
              OrderSummaryCard(
                subtotal: cart.totalAmount,
                shippingFee: 5.0,
                discount: 20.0,
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
      bottomSheet: PlaceOrderBar(
        isProcessing: _isProcessing,
        onTap: _placeOrder,
      ),
    );
  }

  Widget _shippingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Home Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('123 Modern Street, New York, USA',
                    style: TextStyle(color: AppTheme.greyColor, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.edit, size: 18, color: AppTheme.greyColor),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 18),
              const Text('Order Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your items are on the way.\nCheck progress in My Orders.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppTheme.greyColor)),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}