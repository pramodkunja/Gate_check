import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'confirm_password.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final ApiService _apiService = ApiService();

  int _secondsRemaining = 30;
  bool _enableResend = false;
  bool _isVerifying = false;
  bool _isResending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    _secondsRemaining = 30;
    _enableResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _enableResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      final response = await _apiService.forgotPassword(widget.email);

      setState(() => _isResending = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'New code sent to ${widget.email}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: const Color(0xFF9C27B0),
            ),
          );
          startTimer();
        }
      }
    } on DioException catch (e) {
      setState(() => _isResending = false);

      String errorMessage = "Failed to resend code. Please try again.";

      if (e.response?.statusCode == 429) {
        errorMessage = "Too many requests. Please wait before trying again.";
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isResending = false);

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

  Future<void> _verifyOtp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isVerifying = true);

    try {
      final enteredOtp = _otpController.text.trim();
      final response = await _apiService.verifyOtp(widget.email, enteredOtp);

      setState(() => _isVerifying = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "OTP Verified Successfully!",
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to confirm password screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ConfirmPasswordScreen(email: widget.email),
            ),
          );
        }
      }
    } on DioException catch (e) {
      setState(() => _isVerifying = false);

      String errorMessage = "Invalid OTP. Please try again.";

      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data['message'] ?? "Invalid or expired OTP.";
      } else if (e.response?.statusCode == 404) {
        errorMessage = "OTP session expired. Please request a new code.";
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);

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

  bool get _isOtpFilled => _otpController.text.trim().length == 6;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = screenWidth * 0.9 < 400 ? screenWidth * 0.9 : 400;
    final headingSize = screenWidth * 0.05;
    final subheadingSize = screenWidth * 0.035;
    final verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF9C27B0)),
            ),
            elevation: 4,
            child: Container(
              width: cardWidth.toDouble(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "CHECK",
                    style: GoogleFonts.poppins(
                      fontSize: headingSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF9C27B0),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: verticalSpacing / 3),
                  Text(
                    "Reset Password",
                    style: GoogleFonts.poppins(
                      fontSize: subheadingSize + 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: verticalSpacing / 4),
                  Text(
                    "Enter the verification code sent to",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF9C27B0),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: verticalSpacing * 1.2),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification Code *',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          enabled: !_isVerifying,
                          onChanged: (v) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit code',
                            suffixIcon: const Icon(Icons.person_outline),
                            counterText: '',
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
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Please enter the code.';
                            if (v.length < 6)
                              return 'Enter the full 6-digit code.';
                            return null;
                          },
                        ),

                        const SizedBox(height: 6),
                        Text(
                          '6-digit code sent to your email',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: verticalSpacing * 1.4),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isOtpFilled && !_isVerifying)
                          ? _verifyOtp
                          : null,
                      icon: _isVerifying
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
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _isVerifying ? 'Verifying...' : 'Verify Code →',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        disabledBackgroundColor: const Color(
                          0xFF9C27B0,
                        ).withOpacity(0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  Align(
                    alignment: Alignment.center,
                    child: _enableResend
                        ? GestureDetector(
                            onTap: _isResending ? null : _resendCode,
                            child: Text(
                              _isResending ? 'Sending...' : 'Resend Code',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isResending
                                    ? Colors.grey
                                    : const Color(0xFF9C27B0),
                                decoration: _isResending
                                    ? null
                                    : TextDecoration.underline,
                              ),
                            ),
                          )
                        : Text(
                            'Resend code in ${_secondsRemaining}s',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                  ),

                  SizedBox(height: verticalSpacing),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Back to Login',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
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
