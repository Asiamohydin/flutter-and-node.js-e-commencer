import 'package:flutter/material.dart';
import 'package:ecommcerapp/core/theme.dart';
import 'package:ecommcerapp/services/api_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ecommcerapp/screens/admin/product_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _apiService = ApiService();
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _statsFuture = _apiService.getAdminStats();
      _ordersFuture = _apiService.getOrders().then((val) => val['body'] as List<dynamic>);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _refresh,
              icon: const Icon(Iconsax.refresh, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: const Text('Business Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            
            // Stats Section
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildStatsLoader();
                final stats = snapshot.data!;
                // Safely parse stats using tryParse to handle Strings or Numbers
                final double totalIncome = double.tryParse(stats['totalIncome'].toString()) ?? 0.0;
                final int totalOrders = int.tryParse(stats['totalOrders'].toString()) ?? 0;

                return Column(
                  children: [
                    FadeInUp(
                      child: Row(
                        children: [
                          _buildStatCard('Revenue', '\$${totalIncome.toStringAsFixed(2)}', Iconsax.money_send, [Colors.green, Colors.greenAccent]),
                          const SizedBox(width: 15),
                          _buildStatCard('Orders', '$totalOrders', Iconsax.bag_2, [Colors.blue, Colors.blueAccent]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.purple[400]!, Colors.purple[700]!]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.box, color: Colors.white, size: 30),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Manage Products", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text("Add, Update or Remove", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 35),
            FadeInLeft(
              child: const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),

            // Orders list
            FutureBuilder<List<dynamic>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildOrdersLoader();
                final orders = snapshot.data!;
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Icon(Iconsax.box, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 20),
                          const Text('No orders found yet', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: _buildOrderCard(order),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    String status = (order['status'] ?? 'pending').toString().toLowerCase().trim();
    Color statusColor = _getStatusColor(status);

    // Safely parse total
    final double orderTotal = double.tryParse(order['total'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(18),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.user, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        order['customer_name'] ?? 'Unknown Customer',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Iconsax.wallet_1, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(order['payment_method'] ?? 'Manual', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                Text('\$${orderTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
              ],
            ),
          ),
          children: [
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text("Order Items:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            if (order['items'] != null && (order['items'] as List).isNotEmpty)
              ...((order['items'] as List).map((item) {
                // Safely parse quantity and price
                final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
                final price = double.tryParse(item['price'].toString()) ?? 0.0;
                final total = quantity * price;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                          image: item['image_url'] != null && item['image_url'].toString().isNotEmpty
                              ? DecorationImage(image: NetworkImage(item['image_url']), fit: BoxFit.cover)
                              : null,
                        ),
                        child: item['image_url'] == null || item['image_url'].toString().isEmpty
                            ? const Icon(Iconsax.image, size: 16, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] ?? 'Unknown Product', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Row(
                              children: [
                                Text('$quantity x \$${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                if (item['selected_color'] != null || item['selected_size'] != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    "[${item['selected_color'] ?? ''} ${item['selected_size'] ?? ''}]".trim(),
                                    style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                );
              }).toList())
            else
              const Text("No items details available", style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            if (status == 'pending') ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _changeStatus(order['id'], 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _changeStatus(order['id'], 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept Order'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
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

  Widget _buildStatCard(String title, String val, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsLoader() {
    return Row(
      children: [
        Expanded(child: _buildLoaderBox()),
        const SizedBox(width: 15),
        Expanded(child: _buildLoaderBox()),
      ],
    );
  }

  Widget _buildLoaderBox() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOrdersLoader() {
    return Column(
      children: List.generate(3, (index) => Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      )),
    );
  }

  void _changeStatus(int id, String status) async {
    try {
      final result = await _apiService.updateOrderStatus(id, status);
      
      if (result != null && (result['id'] != null || result['success'] == true)) {
        _refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order marked as $status"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _getStatusColor(status),
          ),
        );
      } else {
        if (!mounted) return;
        final errorMsg = result?['message'] ?? "Failed to update order status";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
