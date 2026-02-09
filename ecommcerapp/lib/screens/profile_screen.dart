// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:ecommcerapp/core/theme.dart';
import 'package:ecommcerapp/providers/user_provider.dart';
import 'package:ecommcerapp/providers/theme_provider.dart';
import 'package:ecommcerapp/screens/login_screen.dart';
import 'package:ecommcerapp/screens/wishlist_screen.dart';
import 'package:ecommcerapp/screens/order_history_screen.dart';
import 'package:ecommcerapp/screens/admin_dashboard_screen.dart';
import 'package:ecommcerapp/screens/admin/product_management_screen.dart';
import 'package:ecommcerapp/screens/edit_profile_screen.dart';
import 'package:ecommcerapp/screens/payment_methods_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final name = user?['name'] ?? 'Guest';
        final email = user?['email'] ?? 'Log in to see more';
        final isAdmin = userProvider.isAdmin;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                onPressed: () => _showSettingsSheet(context), 
                icon: const Icon(Iconsax.setting_2)
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                FadeInDown(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user != null && user['image_url'] != null && user['image_url'].toString().isNotEmpty
                        ? NetworkImage(user['image_url'])
                        : null,
                    child: user == null || user['image_url'] == null || user['image_url'].toString().isEmpty
                        ? const Icon(Iconsax.user, size: 48, color: AppTheme.primaryColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(email, style: const TextStyle(color: AppTheme.greyColor)),
                ),
                const SizedBox(height: 40),
                
                if (isAdmin)
                  FadeInUp(
                    child: _buildProfileOption(context, Iconsax.graph, 'Admin Dashboard', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                    }),
                  ),

                FadeInUp(
                  child: _buildProfileOption(context, Iconsax.user, 'My Account', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  }),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: _buildProfileOption(context, Iconsax.location, 'Shipping Address', () => _showNotification(context, "Shipping Addresses")),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildProfileOption(context, Iconsax.card, 'Payment Methods', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                  }),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildProfileOption(context, Iconsax.box, 'My Orders', () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
                  }),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildProfileOption(context, Iconsax.heart, 'Wishlist', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                  }),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildProfileOption(context, Iconsax.logout, 'Logout', () {
                    userProvider.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }, isLogout: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(themeProvider.isDarkMode ? Iconsax.moon : Iconsax.sun_1, color: AppTheme.primaryColor),
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) => themeProvider.toggleTheme(value),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Iconsax.notification, color: AppTheme.primaryColor),
                    title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showNotification(context, "Notification settings coming soon!"),
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.language_square, color: AppTheme.primaryColor),
                    title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Text('English (US)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    onTap: () => _showNotification(context, "Language settings coming soon!"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red : AppTheme.primaryColor),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLogout ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (!isLogout) const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.greyColor),
          ],
        ),
      ),
    );
  }
}
