import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/qr_scanner.dart';
import 'package:gatecheck/Security_Screens/checkin_sucess_screen.dart';
import 'package:gatecheck/Security_Screens/checkout_sucess_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:dio/dio.dart';

class EntryOtpScreen extends StatefulWidget {
  const EntryOtpScreen({super.key});

  @override
  State<EntryOtpScreen> createState() => _EntryOtpScreenState();
}

class _EntryOtpScreenState extends State<EntryOtpScreen> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final VisitorApiService _visitorApiService = VisitorApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    focusNodes.first.requestFocus();
  }

  void handleOtpInput(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  Future<void> verifyOtp() async {
    String otp = controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the complete 6-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _visitorApiService.verifyEntryOtp(otp);

      if (!mounted) return;

      final responseData = response.data;

      // Check for logical errors in 200 OK response
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('error')) {
        _showErrorDialog(responseData['error'].toString());
        return;
      }

      // Backend returns data in 'visitor' key (or top-level)
      final visitorData =
          (responseData is Map<String, dynamic> &&
              responseData.containsKey('visitor'))
          ? responseData['visitor'] as Map<String, dynamic>
          : (responseData is Map<String, dynamic>
                ? responseData
                : <String, dynamic>{});

      // If backend explicitly returned an error key, show it
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('error') &&
          (responseData['error']?.toString().isNotEmpty ?? false)) {
        _showErrorDialog(responseData['error'].toString());
        return;
      }

      // Determine action/status to route to check-in or check-out
      final String action =
          (visitorData['action'] ?? responseData['action'] ?? '').toString();
      final String status =
          (visitorData['status'] ?? responseData['status'] ?? '').toString();

      if (action.toUpperCase() == 'EXIT' || status.toLowerCase() == 'outside') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CheckOutSuccessScreen(visitorData: visitorData, qrCode: otp),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CheckInSuccessScreen(visitorData: visitorData, qrCode: otp),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      // Show backend error message in popup
      String errorMsg = _visitorApiService.getErrorMessage(e);
      if (e.response?.data is Map<String, dynamic> &&
          (e.response?.data as Map).containsKey('error')) {
        errorMsg = e.response!.data['error'].toString();
      }
      _showErrorDialog(errorMsg);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Verification Failed",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(color: const Color(0xFF9C27FF)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "OTP Check-In/Out",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: w * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            children: [
              SizedBox(height: h * 0.08),

              // Card
              Container(
                width: w,
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.05,
                  horizontal: w * 0.06,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(blurRadius: 20, color: Colors.purple.shade50),
                  ],
                ),
                child: Column(
                  children: [
                    // Lock Icon Circle
                    Container(
                      height: w * 0.22,
                      width: w * 0.22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.purple.shade100,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15,
                            color: Colors.purple.shade50,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock,
                        size: w * 0.12,
                        color: Colors.purple,
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // Title
                    Text(
                      "Enter OTP",
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.06,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: h * 0.01),

                    Text(
                      "Ask the visitor for the 6-digit entry\ncode sent to their mobile device.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.035,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    SizedBox(height: h * 0.04),

                    // OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: w * 0.12,
                          height: w * 0.12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.purple.shade200,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: w * 0.05,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (value) =>
                                  handleOtpInput(value, index),
                              decoration: const InputDecoration(
                                counterText: "",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.05),

              // Verify Button
              GestureDetector(
                onTap: verifyOtp,
                child: Container(
                  width: w,
                  padding: EdgeInsets.symmetric(vertical: h * 0.018),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27FF),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Verify OTP",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.025),

              // Scan QR Instead
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(),
                    ),
                  );
                },
                child: Container(
                  width: w,
                  padding: EdgeInsets.symmetric(vertical: h * 0.017),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Scan QR Instead   ",
                          style: GoogleFonts.poppins(
                            fontSize: w * 0.045,
                            color: const Color(0xFF9C27FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.qr_code,
                          size: w * 0.06,
                          color: const Color(0xFF9C27FF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
