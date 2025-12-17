import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/visitor_verify.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  final VisitorApiService _visitorApiService = VisitorApiService();
  
  bool _flashOn = false;
  bool _popupVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // --- Blur Background ---
          // Positioned.fill(
          //   child: ImageFiltered(
          //     imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          //     child: Container(
          //       decoration: const BoxDecoration(
          //         image: DecorationImage(
          //           image: AssetImage("assets/bg.jpg"),
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // --- QR Scanner ---
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: (barcode) async {
                if (!_popupVisible && !_isLoading) {
                  final String? code = barcode.barcodes.first.rawValue;
                  if (code == null) return;

                  setState(() {
                     _isLoading = true;
                  });
                  _controller.stop();

                  try {
                    // Call API
                    final response = await _visitorApiService.scanQrCode(code);
                    
                    if (mounted) {
                       setState(() {
                        _isLoading = false;
                      });
                      
                      final responseData = response.data;

                      // Check for specific error in success response (200 OK)
                      if (responseData is Map<String, dynamic> &&
                          responseData['error'] ==
                              "One-time pass already used. Re-entry not allowed." &&
                          responseData['status'] == "Outside") {
                        
                         setState(() {
                           _popupVisible = true;
                         });

                         showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              "Entry Denied",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              responseData['error'].toString(),
                              style: GoogleFonts.poppins(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _popupVisible = false;
                                  });
                                  Navigator.of(ctx).pop();
                                  _controller.start(); // Restart scanner
                                },
                                child: Text(
                                  "OK",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFFB57AFF)),
                                ),
                              ),
                            ],
                          ),
                        );
                        return; // Stop further execution
                      }
                      final visitorData = responseData is Map<String, dynamic> ? responseData : <String, dynamic>{};
                      
                      // Check if 'data' key exists and use that, or use the root
                      final finalData = (visitorData['data'] ?? visitorData) as Map<String, dynamic>;

                      // Navigate to Verify Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisitorVerifyScreen(
                            visitorData: finalData,
                            otp: code, // Passing QR code as OTP/Reference
                          ),
                        ),
                      ).then((_) {
                         // When returning, restart scanner
                         if (mounted) {
                           _controller.start();
                         }
                      });
                    }
                  } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                          _popupVisible = false; 
                        });
                        _controller.start(); 
                        
                        String errorMsg = "Scan failed";
                        if (e is DioException) {
                          final responseData = e.response?.data;
                          if (responseData is Map<String, dynamic> &&
                              responseData['error'] ==
                                  "One-time pass already used. Re-entry not allowed." &&
                              responseData['status'] == "Outside") {
                            // Show Popup for this specific error
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                  "Entry Denied",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  responseData['error'].toString(),
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      _controller.start(); // Restart scanner
                                    },
                                    child: Text(
                                      "OK",
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFFB57AFF)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            return; // Stop further execution (no SnackBar)
                          }

                           errorMsg = _visitorApiService.getErrorMessage(e);
                        } else if (e.toString().contains("Invalid QR format")) {
                           errorMsg = "Invalid QR Format: Please scan a valid GateCheck pass.";
                        } else {
                           errorMsg = e.toString().replaceAll('Exception: ', '');
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              errorMsg, 
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                  }
                }
              },
            ),
          ),

          // --- Heading Text ---
          Positioned(
            top: h * 0.15,
            width: w,
            child: Column(
              children: [
                Text(
                  "Align the QR inside the frame",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: h * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: h * 0.01),
                Text(
                  _isLoading ? "Verifying..." : "Scanning...",
                  style: GoogleFonts.poppins(
                    color: Color(0xFFB57AFF),
                    fontSize: h * 0.02,
                  ),
                ),
                if (_isLoading)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: SizedBox(
                       height: 20,
                       width: 20,
                       child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB57AFF)),
                     ),
                   ),
              ],
            ),
          ),

          // --- Scanning Frame ---
          Center(
            child: SizedBox(
              height: h * 0.35,
              width: w * 0.75,
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(painter: CornerBorderPainter()),
              ),
            ),
          ),

          // --- Bottom Controls ---
          Positioned(
            bottom: h * 0.08,
            left: w * 0.08,
            child: InkWell(
              onTap: () {
                _flashOn = !_flashOn;
                setState(() {});
                _controller.toggleTorch();
              },
              child: Container(
                height: h * 0.065,
                width: h * 0.065,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Icon(
                  _flashOn ? Icons.flash_on : Icons.flash_off,
                  color: Color(0xFFB57AFF),
                  size: h * 0.033,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: h * 0.08,
            right: w * 0.08,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.07,
                  vertical: h * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    fontSize: h * 0.02,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- Corner painter -------------------

class CornerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFB57AFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const corner = 25.0;

    canvas.drawLine(Offset(0, 0), Offset(corner, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, corner), paint);

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - corner, 0),
      paint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, corner), paint);

    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - corner),
      paint,
    );
    canvas.drawLine(Offset(0, size.height), Offset(corner, size.height), paint);

    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - corner, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - corner),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
