import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/models/visitor_model.dart';
import 'package:gatecheck/Services/visitor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

enum EntryExitAction { entry, exit }

class EntryOtpScreen extends StatefulWidget {
  final Visitor visitor;
  final EntryExitAction action;

  const EntryOtpScreen({
    super.key,
    required this.visitor,
    required this.action,
  });

  @override
  State<EntryOtpScreen> createState() => _EntryOtpScreenState();
}

class _EntryOtpScreenState extends State<EntryOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final VisitorApiService _visitorService = VisitorApiService();

  bool isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isVerifying = true;
    });

    try {
      final Response response;

      if (widget.action == EntryExitAction.entry) {
        response = await _visitorService.checkInVisitor(
          passId: widget.visitor.passId,
          otp: _otpController.text.trim(),
        );
      } else {
        response = await _visitorService.checkOutVisitor(
          passId: widget.visitor.passId,
          otp: _otpController.text.trim(),
        );
      }

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.action == EntryExitAction.entry
                    ? 'Check-in successful!'
                    : 'Check-out successful!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Visitor cannot check in before the scheduled visiting date.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errorMessage = 'Invalid OTP';

        if (e.response?.data != null) {
          if (e.response!.data is Map) {
            errorMessage =
                e.response!.data['message'] ??
                e.response!.data['error'] ??
                'Invalid OTP';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final dialogWidth = width > 600 ? 400.0 : width * 0.85;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),
            child: Container(
              width: dialogWidth,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Section
                    Container(
                      padding: EdgeInsets.all(width * 0.035),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.action == EntryExitAction.entry
                            ? Icons.login
                            : Icons.logout,
                        color: const Color(0xFF3B82F6),
                        size: width * 0.11,
                      ),
                    ),
                    SizedBox(height: height * 0.02),

                    // Title
                    Text(
                      widget.action == EntryExitAction.entry
                          ? "Entry OTP Verification"
                          : "Exit OTP Verification",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: width < 360 ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: height * 0.012),

                    // Subtitle
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: width < 360 ? 13 : 14,
                          color: const Color(0xFF333333),
                        ),
                        children: [
                          TextSpan(
                            text: widget.action == EntryExitAction.entry
                                ? "Enter the entry OTP for "
                                : "Enter the exit OTP for ",
                          ),
                          TextSpan(
                            text: widget.visitor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.01),

                    // Pass ID
                    Text(
                      'Pass ID: ${widget.visitor.passId}',
                      style: GoogleFonts.poppins(
                        fontSize: width < 360 ? 12 : 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    // OTP Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "OTP Code",
                        style: GoogleFonts.poppins(
                          fontSize: width < 360 ? 13 : 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),

                    // OTP TextFormField
                    TextFormField(
                      controller: _otpController,
                      maxLength: 6,
                      enabled: !isVerifying,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: width < 360 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        hintText: "000000",
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: height * 0.018,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter OTP";
                        } else if (value.length != 6) {
                          return "OTP must be 6 digits";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.03),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.018,
                              ),
                            ),
                            onPressed: isVerifying
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize: width < 360 ? 14 : 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.03),

                        // Verify OTP Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.018,
                              ),
                            ),
                            onPressed: isVerifying ? null : _verifyOtp,
                            child: isVerifying
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Verify OTP",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: width < 360 ? 14 : 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
