import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:ecommcerapp/core/theme.dart';
import 'package:ecommcerapp/providers/user_provider.dart';
import 'package:ecommcerapp/screens/main_screen.dart';
import 'package:ecommcerapp/screens/register_screen.dart';
import 'package:ecommcerapp/services/api_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _apiService = ApiService();

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Attempt local sign-in first for demo purposes if server is not running
    // In a real app, you'd only use the API
    try {
      final result = await _apiService.login(_emailController.text, _passwordController.text);
      
      if (result['success'] == true) {
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setUser(result['user'], result['token'] ?? '');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Invalid credentials')),
        );
      }
    } catch (e) {
      // Fallback for demo when server isn't running
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Iconsax.shop, color: AppTheme.primaryColor, size: 40),
              ),
            ),
            const SizedBox(height: 30),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: const Text('Welcome Back!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: const Text('Sign in to continue your shopping journey.', style: TextStyle(color: AppTheme.greyColor, fontSize: 16)),
            ),
            const SizedBox(height: 50),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildTextField('Email', Iconsax.sms, false, _emailController),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildTextField('Password', Iconsax.lock, true, _passwordController),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: FadeInRight(
                child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: _isLoading ? null : _handleLogin,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('OR', style: TextStyle(color: AppTheme.greyColor)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialBtn(Icons.g_mobiledata, Colors.red),
                  const SizedBox(width: 25),
                  _buildSocialBtn(Icons.apple, Colors.black),
                  const SizedBox(width: 25),
                  _buildSocialBtn(Icons.facebook, Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppTheme.greyColor),
                    children: [
                      TextSpan(text: "Don't have an account? "),
                      TextSpan(text: "Sign Up", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, bool isPassword, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.greyColor, size: 20),
          hintText: label,
          hintStyle: const TextStyle(color: AppTheme.greyColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
