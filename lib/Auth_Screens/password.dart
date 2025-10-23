// lib/screens/auth/sign_in_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gatecheck/Auth_Screens/forgot_password.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/dashboard.dart';

class SignInScreen extends StatefulWidget {
  final String? email;

  const SignInScreen({Key? key, this.email}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();

  late String _captcha;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _regenerateCaptcha();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _regenerateCaptcha() {
    setState(() {
      _captcha = generateCaptcha();
    });
  }

  String generateCaptcha() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return List.generate(5, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  void _onSignIn() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final captchaInput = _captchaController.text.trim();

    // Here you would normally check password against backend.
    // For this screen we only check that password isn't empty (already validated)
    // and captcha matches.
    if (captchaInput == _captcha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful'),
          backgroundColor: Color(0xFF6A1B9A),
        ),
      );
      // Navigate to dashboard after a short delay so the SnackBar is visible
      Future.delayed(const Duration(milliseconds: 700), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Captcha or Password'),
          backgroundColor: Colors.red,
        ),
      );
      // Optionally regenerate captcha after a failed attempt:
      _regenerateCaptcha();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // card width: min(screenWidth * 0.9, 400)
            final cardWidth = min(screenWidth * 0.9, 400.0);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Container(
                  width: cardWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF9C27B0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header: avatar, name, email
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF6A1B9A),
                          child: Text(
                            'S-C',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SRIA',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Welcome, ${widget.email ?? 'user@example.com'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              children: [
                                const TextSpan(text: 'Password '),
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.poppins(),
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            hintStyle: GoogleFonts.poppins(fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF6A1B9A),
                                width: 1.5,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Captcha Label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Captcha *',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Captcha Input (full width)
                        TextFormField(
                          controller: _captchaController,
                          style: GoogleFonts.poppins(),
                          decoration: InputDecoration(
                            hintText: 'Enter the captcha…',
                            hintStyle: GoogleFonts.poppins(fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF6A1B9A),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the captcha.';
                            }
                            if (value.trim() != _captcha) {
                              return 'Captcha does not match.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Captcha display with refresh button to the right
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _captcha,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16 * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36),
                              icon: const Icon(Icons.refresh),
                              color: const Color(0xFF6A1B9A),
                              onPressed: _regenerateCaptcha,
                              tooltip: 'Refresh Captcha',
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _onSignIn,
                            icon: const Icon(Icons.login, color: Colors.white),
                            label: Text(
                              'Sign In →',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Forgot Password
                        InkWell(
                          onTap: () {
                            // Navigate to the forgot-password screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ResetPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6A1B9A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
