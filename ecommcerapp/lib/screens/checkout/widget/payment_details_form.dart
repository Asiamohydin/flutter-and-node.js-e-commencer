import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import 'package:app/screens/checkout/checkout_screen.dart';

class PaymentDetailsForm extends StatelessWidget {
  final PaymentMethod method;

  final TextEditingController cardNumberCtrl;
  final TextEditingController cardNameCtrl;
  final TextEditingController cardExpiryCtrl;
  final TextEditingController cardCvvCtrl;
  final TextEditingController paypalEmailCtrl;

  const PaymentDetailsForm({
    super.key,
    required this.method,
    required this.cardNumberCtrl,
    required this.cardNameCtrl,
    required this.cardExpiryCtrl,
    required this.cardCvvCtrl,
    required this.paypalEmailCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title(), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (method == PaymentMethod.card) ..._cardFields(),
          if (method == PaymentMethod.paypal) ..._paypalFields(),
          if (method == PaymentMethod.googlePay) ..._googlePayInfo(),
        ],
      ),
    );
  }

  String _title() {
    if (method == PaymentMethod.card) return "Card Information";
    if (method == PaymentMethod.paypal) return "PayPal Information";
    return "Google Pay";
    }

  List<Widget> _cardFields() => [
        _field(
          controller: cardNumberCtrl,
          label: "Card Number",
          hint: "1234 5678 9012 3456",
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.replaceAll(' ', '').trim().length < 12)
              ? "Enter a valid card number"
              : null,
        ),
        const SizedBox(height: 12),
        _field(
          controller: cardNameCtrl,
          label: "Cardholder Name",
          hint: "Your name",
          validator: (v) => (v == null || v.trim().isEmpty) ? "Enter cardholder name" : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _field(
                controller: cardExpiryCtrl,
                label: "Expiry",
                hint: "MM/YY",
                keyboardType: TextInputType.datetime,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter expiry" : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                controller: cardCvvCtrl,
                label: "CVV",
                hint: "123",
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().length < 3) ? "Enter CVV" : null,
              ),
            ),
          ],
        ),
      ];

  List<Widget> _paypalFields() => [
        _field(
          controller: paypalEmailCtrl,
          label: "PayPal Email",
          hint: "example@gmail.com",
          keyboardType: TextInputType.emailAddress,
          validator: (v) => (v == null || !v.contains("@")) ? "Enter a valid email" : null,
        ),
      ];

  List<Widget> _googlePayInfo() => const [
        Text(
          "Google Pay will open on your device when placing the order.",
          style: TextStyle(color: AppTheme.greyColor),
        ),
      ];

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
    );
  }
}
