import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_password.dart';
import 'dart:math' as math;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isEmailValid = false;
  bool _isSending = false;
  String? _emailError;

  final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final text = _emailController.text.trim();
    final valid = text.isNotEmpty && _emailRegExp.hasMatch(text);
    if (valid != _isEmailValid) {
      setState(() {
        _isEmailValid = valid;
        if (_isEmailValid) _emailError = null;
      });
    }
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter your email.';
    }
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  Future<void> _sendResetCode() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      setState(() {
        _emailError = _validateEmail(_emailController.text);
      });
      return;
    }

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate API
    setState(() => _isSending = false);

    final email = _emailController.text.trim();

    // TODO: Replace with backend call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reset code sent to $email'),
        //backgroundColor: const Color(0xFF7B1FA2),
      ),
    );
    // Navigate to the OTP / reset screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF7B1FA2);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final cardWidth = math.min(width * 0.92, 400);
    final titleSize = (width * 0.05).clamp(18.0, 26.0);
    final subtitleSize = (width * 0.035).clamp(12.0, 16.0);
    final spacingS = (height * 0.01).clamp(8.0, 18.0);
    final spacingM = (height * 0.02).clamp(12.0, 28.0);
    final padH = (width * 0.06).clamp(20.0, 24.0);
    final padV = (height * 0.02).clamp(20.0, 28.0);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: spacingM),
            child: Container(
              width: cardWidth.toDouble(),
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: purple.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CHECK',
                    style: GoogleFonts.poppins(
                      fontSize: subtitleSize * 0.9,
                      fontWeight: FontWeight.w600,
                      color: purple,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: spacingS / 2.5),
                  Text(
                    'Reset Password',
                    style: GoogleFonts.poppins(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: spacingS),
                  Text(
                    'Enter your email to receive a reset code',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: spacingM * 2),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              text: 'Email Address ',
                              style: GoogleFonts.poppins(
                                fontSize: subtitleSize * 0.95,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: GoogleFonts.poppins(
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: spacingS / 2),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your registered email',
                            suffix: const Icon(Icons.email_outlined),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.orange.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.orange.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: purple, width: 1.6),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red.shade700,
                                width: 1.4,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red.shade700,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                        if (_emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _emailError!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: spacingM),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (!_isEmailValid || _isSending)
                                ? null
                                : _sendResetCode,
                            icon: const Icon(
                              Icons.email,
                              size: 20,
                              color: Colors.white,
                            ),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                'Send Reset Code →',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purple,
                              disabledBackgroundColor: purple.withOpacity(0.45),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                        SizedBox(height: spacingS * 2),
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              debugPrint('Back to Login tapped');
                            }
                          },
                          child: Text(
                            '← Back to Login',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: purple,
                              fontWeight: FontWeight.w600,
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
