import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Row(
            children: [
              // Left side - Orange background with doctor image
              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xFFFE3001),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: SvgPicture.asset(
                          'assets/background-effect.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Doctor image and logo in center
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo above doctor
                            Image.asset(
                              'assets/horizental-logo-white.png',
                              height: 70,
                            ),
                            const SizedBox(height: 50),
                            // Doctor image - using PNG (SVG has embedded image)
                            Image.asset(
                              'assets/doctor.png',
                              width: 450,
                              height: 450,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side - Login form
              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.08,
                          vertical: 40,
                        ),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
                                const Text(
                                  'Enter Your Smarter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    height: 1.3,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Care Space',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFE3001),
                                    height: 1.3,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 60),
                                
                                // Login Card
                                Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF5F3),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFFFE3001),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Email field
                                      const Text(
                                        'Email',
                                        style: TextStyle(
                                          fontFamily: 'ProductSans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          hintText: 'Dr. A.F.M. Helal Uddin',
                                          hintStyle: TextStyle(
                                            fontFamily: 'ProductSans',
                                            color: Colors.grey.shade500,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFFE3001),
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                          isDense: true,
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'ProductSans',
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 32),
                                
                                      // Password field
                                      const Text(
                                        'Password',
                                        style: TextStyle(
                                          fontFamily: 'ProductSans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          hintText: '••••••••••••',
                                          hintStyle: TextStyle(
                                            fontFamily: 'ProductSans',
                                            color: Colors.grey.shade500,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFFE3001),
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                          isDense: true,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.grey.shade600,
                                              size: 20,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'ProductSans',
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 30),  // ⬅️ Add this line for more gap
                                      // Error message
                                      if (authProvider.errorMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.red.shade200),
                                            ),
                                            child: Text(
                                              authProvider.errorMessage!,
                                              style: TextStyle(
                                                fontFamily: 'ProductSans',
                                                color: Colors.red.shade700,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      
                                      // Login button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: authProvider.isLoading ? null : _handleLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFE3001),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: authProvider.isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  'Log In',
                                                  style: TextStyle(
                                                    fontFamily: 'ProductSans',
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 50),
                                
                                // Footer
                                Text(
                                  '© 2026 DoctorsHero.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'All Rights Reserved by Modern Mediks Ltd',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
