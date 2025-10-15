import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'confirm_password.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Single input for the full code (design shows a single full-field input)
  final TextEditingController _otpController = TextEditingController();

  int _secondsRemaining = 30;
  bool _enableResend = false;
  Timer? _timer;

  // Example expected OTP (6 digits to match UI guide)
  final String _expectedOtp = "123456";

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

  void _verifyOtp() {
    // Validate form first
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final enteredOtp = _otpController.text.trim();
    if (enteredOtp == _expectedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Verified Successfully!")),
      );
      // Navigate to confirm password screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect OTP, try again.")),
      );
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
                    "Enter the verification code sent to your email",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: verticalSpacing * 1.2),

                  // Single full-width OTP input to match design
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

                  // Verify Button (styled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isOtpFilled ? _verifyOtp : null,
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Verify Code →',
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

                  // Resend (moved below Verify button)
                  Align(
                    alignment: Alignment.center,
                    child: _enableResend
                        ? GestureDetector(
                            onTap: startTimer,
                            child: Text(
                              'Resend Code',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9C27B0),
                                decoration: TextDecoration.underline,
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

                  // Footer
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back, // arrow icon
                          size: 18, // arrow size
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 4), // spacing between arrow and text
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
