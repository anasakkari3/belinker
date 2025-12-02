import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediator_mvp/app_widgets/MainScreen.dart';
import 'package:mediator_mvp/start_page/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediator_mvp/app_widgets/home_page.dart';
import 'package:mediator_mvp/start_page/userDetails.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});


  static String routeName = 'Register';
  static String routePath = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 60,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      spreadRadius: 20,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Logo
                    Container(child: Image.asset("assets/logo.png")),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Create Account',
                      style: GoogleFonts.readexPro(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please fill the details below to register.',
                      style: GoogleFonts.readexPro(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Social buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Apple Login
                        _socialButton(
                          icon: const FaIcon(FontAwesomeIcons.apple),
                          onTap: () async {
                            try {
                              await auth().signInWithApple();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const UserDetailsScreen()),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Apple login failed: $e")),
                              );
                            }
                          },),

                        // Google Login
                        _socialButton(
                          image: 'assets/Logogoogle.png',
                          onTap: () async {
                            try {
                              await auth().signInWithGoogle();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const UserDetailsScreen()),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Google login failed: $e")),
                              );
                            }
                          },
                        ),

                        // Facebook Login
                        _socialButton(
                          image: 'assets/Facebook_Logo.png',
                          onTap: () async {
                            try {
                              // هون لازم تضيف دالة signInWithFacebook بالـ auth class
                              await auth().signInWithFacebook();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const UserDetailsScreen()),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Facebook login failed: $e")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[400])),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider(color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Email field
                    _buildLabel("Email Address"),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 22),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    _buildLabel("Password"),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 22),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildLabel("Confirm Password"),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 22),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Accept Terms
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (val) {
                            setState(() {
                              _acceptTerms = val ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "I accept the ",
                              style: GoogleFonts.readexPro(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "Terms & Conditions",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register button
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await auth().createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          // ✅ بعد إنشاء الحساب: روح على شاشة التفاصيل
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserDetailsScreen(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0057D9),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Register"),
                    ),

                    const SizedBox(height: 24),

                    // Already have account
                    RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: GoogleFonts.readexPro(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                               Navigator.of(context).pop();
                              },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.readexPro(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _socialButton({FaIcon? icon, String? image, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: 90,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: icon ??
              Image.asset(
                image!,
                width: 28,
                height: 28,
              ),
        ),
      ),
    );
  }
}
