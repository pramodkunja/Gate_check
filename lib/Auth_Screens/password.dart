import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:gatecheck/Auth_Screens/forgot_password.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_dashboard.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/dashboard.dart';

class SignInScreen extends StatefulWidget {
  final String? email;

  const SignInScreen({super.key, this.email});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final ApiService _apiService = ApiService();

  late String _captcha;
  bool _obscurePassword = true;
  bool _isLoading = false;

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

  Future<void> _onSignIn() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final captchaInput = _captchaController.text.trim();
    final passwordInput = _passwordController.text.trim();

    // First check captcha
    if (captchaInput != _captcha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Captcha'),
          backgroundColor: Colors.red,
        ),
      );
      _regenerateCaptcha();
      _captchaController.clear();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare login credentials - try different formats
      // ignore: unused_local_variable
      final credentials = {
        'email': widget.email ?? '',
        'password': passwordInput,
      };

      debugPrint('Attempting login with email: ${widget.email}');
      
      // Call login API using required named parameters
      final response = await _apiService.login(
        identifier: widget.email ?? '',
        password: passwordInput,
      );

      setState(() => _isLoading = false);

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data;
        
        // Extract user information
        String userName = 'User';
        String userRole = 'user';
        
        if (userData is Map<String, dynamic>) {
          userName = userData['name']?.toString() ?? 
                     userData['username']?.toString() ?? 
                     userData['user']?.toString() ?? 
                     'User';
          userRole = userData['role']?.toString().toLowerCase() ?? 
                     userData['user_type']?.toString().toLowerCase() ?? 
                     'user';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back, $userName!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: const Color(0xFF6A1B9A),
              duration: const Duration(milliseconds: 700),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 700));

          // Navigate based on role
          if (userRole.contains('admin')) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const UserDashboardScreen(),
              ),
              (route) => false,
            );
          }
        }
      } else if (response.statusCode == 400) {
        // Handle 400 Bad Request
        final errorMsg = _apiService.getErrorMessage(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
          ),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg, style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        // Handle other status codes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login failed. Status: ${response.statusCode}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);

      final errorMessage = _apiService.getErrorMessage(e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      _regenerateCaptcha();
      _captchaController.clear();
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unexpected error: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      _regenerateCaptcha();
      _captchaController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;

    String displayName = 'User';
    String userInitials = 'U';

    if (widget.email != null) {
      final emailParts = widget.email!.split('@');
      if (emailParts.isNotEmpty) {
        displayName = emailParts[0];
        userInitials = displayName.isNotEmpty
            ? displayName.substring(0, min(1, displayName.length)).toUpperCase()
            : 'U';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF6A1B9A),
                          child: Text(
                            userInitials,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // const SizedBox(height: 6),
                        // Text(
                        //   'Welcome, ${widget.email ?? 'user@example.com'}',
                        //   style: GoogleFonts.poppins(
                        //     fontSize: 12,
                        //     color: Colors.grey[700],
                        //   ),
                        // ),
                        const SizedBox(height: 20),

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

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !_isLoading,
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

                        TextFormField(
                          controller: _captchaController,
                          enabled: !_isLoading,
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
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

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

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _onSignIn,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.login, color: Colors.white),
                            label: Text(
                              _isLoading ? 'Signing In...' : 'Sign In →',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              disabledBackgroundColor: 
                                  const Color(0xFF6A1B9A).withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        InkWell(
                          onTap: () {
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