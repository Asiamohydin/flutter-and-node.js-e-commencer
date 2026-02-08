class Order {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  final DateTime createdAt;
  final String paymentMethod;
  final Map<String, dynamic> paymentInfo;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.paymentMethod,
    required this.paymentInfo,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "items": items,
        "total": total,
        "createdAt": createdAt.toIso8601String(),
        "paymentMethod": paymentMethod,
        "paymentInfo": paymentInfo,
        "status": status,
      };
}
