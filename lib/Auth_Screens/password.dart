import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/dashboard_screen.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:gatecheck/Auth_Screens/forgot_password.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_dashboard.dart';
//import 'package:gatecheck/Admin_Screens/Dashboard_Screens/dashboard.dart';

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
      _captcha = _generateCaptcha();
    });
  }

  String _generateCaptcha() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return List.generate(5, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _onSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final captchaInput = _captchaController.text.trim();
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

    final passwordInput = _passwordController.text.trim();
    final identifier = widget.email?.trim() ?? '';

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(
        identifier: identifier,
        password: passwordInput,
      );
      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.data;
        debugPrint('Login success. Raw response: $responseBody');

        String userName = 'User';
        String userRole = 'user';

        if (responseBody is Map<String, dynamic>) {
          // Step 1: get nested user map
          Map<String, dynamic>? userMap;
          if (responseBody.containsKey('data') &&
              responseBody['data'] is Map<String, dynamic>) {
            final d = responseBody['data'] as Map<String, dynamic>;
            if (d.containsKey('user') && d['user'] is Map<String, dynamic>) {
              userMap = d['user'] as Map<String, dynamic>;
            }
          }
          userMap ??= responseBody;

          // Step 2: extract userName
          userName =
              userMap['username']?.toString() ??
              userMap['name']?.toString() ??
              'User';

          // Step 3: extract role (correct field ‘roles’)
          String rawRole =
              userMap['roles ']?.toString() ??
              userMap['role']?.toString() ??
              userMap['user_type']?.toString() ??
              '';

          debugPrint('Raw role string from API: "$rawRole"');

          rawRole = rawRole.trim().toLowerCase();

          // Step 4: apply your rule: if empty or “null” treat as admin
          if (rawRole.isEmpty || rawRole == 'null') {
            userRole = 'admin';
          } else {
            userRole = rawRole;
          }
        }

        debugPrint('Determined userRole: $userRole');

        // Persist user info in the in-memory UserService so other screens can access it
        UserService().setCurrentUser({
          'name': userName,
          'username': userName,
          'role': userRole,
          'email': identifier,
        });

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
          if (!mounted) return;

          _navigateByRole(userRole);
        }
        debugPrint('\n\n\n\n\n');
        debugPrint('Extracted userRole: $userRole');
        debugPrint('Extracted userRole: $userName');
        debugPrint('\n\n\n\n\n');
        debugPrint('Login response data: ${response.data}');
      } else if (response.statusCode == 400) {
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

  void _navigateByRole(String role) {
    if (role == 'admin' || role == 'null') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      // any non‐admin goes to user dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    String displayName = 'User';
    String userInitials = 'U';
    if (widget.email != null) {
      final parts = widget.email!.split('@');
      if (parts.isNotEmpty) {
        displayName = parts[0];
        if (displayName.isNotEmpty) {
          userInitials = displayName.substring(0, 1).toUpperCase();
        }
      }
    }

    final cardWidth = screenWidth * 0.9 > 400 ? 400.0 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                        const SizedBox(height: 20),

                        // Password field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password *',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
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

                        // Captcha section
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

                        // Sign In button
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
                                        Colors.white,
                                      ),
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
                              disabledBackgroundColor: const Color(
                                0xFF6A1B9A,
                              ).withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Forgot password link
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
