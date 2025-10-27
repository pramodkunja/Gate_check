import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'gatecheck_signin.dart';

class ConfirmPasswordScreen extends StatefulWidget {
  final String email;

  const ConfirmPasswordScreen({super.key, required this.email});

  @override
  State<ConfirmPasswordScreen> createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isResetting = false;

  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;
  bool _showRequirements = false;

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$%\^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;
      _showRequirements = password.isNotEmpty;
    });
  }

  bool get _isPasswordStrong =>
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecialChar &&
      _hasMinLength;

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isResetting = true);

    try {
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      final response = await _apiService.setNewPassword(
        identifier: widget.email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      setState(() => _isResetting = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password reset successfully!',
                style: GoogleFonts.poppins(),
              ),
              // backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 1200));

          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const GateCheckSignIn()),
            (route) => false,
          );
        }
      }
    } on DioException catch (e) {
      setState(() => _isResetting = false);

      String errorMessage = "Failed to reset password. Please try again.";

      if (e.response?.statusCode == 400) {
        errorMessage =
            e.response?.data['message'] ??
            "Password does not meet requirements.";
      } else if (e.response?.statusCode == 404) {
        errorMessage = "Session expired. Please request a new reset code.";
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            "Connection timeout. Please check your internet connection.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Cannot connect to server. Please try again later.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isResetting = false);

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
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _passwordRequirement(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          color: met ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: met ? Colors.green : Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: screenWidth > 500 ? 400 : double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF9C27B0)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'CHECK',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF9C27B0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new strong password for',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9C27B0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // New Password
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          enabled: !_isResetting,
                          decoration: InputDecoration(
                            labelText: 'New Password *',
                            hintText: 'Enter new password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF9C27B0),
                                width: 1.6,
                              ),
                            ),
                          ),
                          onChanged: _checkPasswordStrength,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter new password';
                            }
                            if (!_isPasswordStrong) {
                              return 'Password does not meet all requirements';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_showRequirements)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _passwordRequirement(
                                'At least 8 characters',
                                _hasMinLength,
                              ),
                              _passwordRequirement(
                                'One uppercase letter',
                                _hasUppercase,
                              ),
                              _passwordRequirement(
                                'One lowercase letter',
                                _hasLowercase,
                              ),
                              _passwordRequirement('One number', _hasNumber),
                              _passwordRequirement(
                                'One special character',
                                _hasSpecialChar,
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          enabled: !_isResetting,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password *',
                            hintText: 'Confirm new password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF9C27B0),
                                width: 1.6,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Reset Password Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),
                              disabledBackgroundColor: const Color(
                                0xFF9C27B0,
                              ).withOpacity(0.6),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isResetting ? null : _resetPassword,
                            icon: _isResetting
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
                                : const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isResetting
                                  ? 'Resetting...'
                                  : 'Reset Password →',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Back to Login
                        TextButton(
                          onPressed: _isResetting
                              ? null
                              : () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const GateCheckSignIn(),
                                    ),
                                    (route) => false,
                                  );
                                },
                          child: Text(
                            '← Back to Login',
                            style: GoogleFonts.poppins(
                              color: _isResetting
                                  ? Colors.grey
                                  : const Color(0xFF9C27B0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
