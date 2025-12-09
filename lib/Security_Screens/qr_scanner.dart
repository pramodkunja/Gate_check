import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/visitor_live_status.dart';
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
  bool _flashOn = false;
  bool _popupVisible = false;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // --- Blur Background ---
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/bg.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // --- QR Scanner ---
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: (barcode) {
                if (!_popupVisible) {
                  setState(() => _popupVisible = true);
                  _controller.stop();

                  Future.delayed(const Duration(milliseconds: 300), () {
                    showVisitorDetailsPopup(context);
                  });
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
                  "Scanning...",
                  style: GoogleFonts.poppins(
                    color: Color(0xFFB57AFF),
                    fontSize: h * 0.02,
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

  // ---------------- POPUP -----------------

  void showVisitorDetailsPopup(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final h = MediaQuery.of(context).size.height;
        final w = MediaQuery.of(context).size.width;

        return Container(
          height: h * 0.55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              SizedBox(height: h * 0.015),

              Container(
                height: 5,
                width: 55,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              SizedBox(height: h * 0.025),

              Container(
                height: h * 0.10,
                width: h * 0.10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE7D5FF),
                ),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF9B47FF),
                  size: h * 0.055,
                ),
              ),

              SizedBox(height: h * 0.015),
              Text(
                "Rohit Sharma",
                style: GoogleFonts.poppins(
                  fontSize: h * 0.028,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * 0.02),

              buildDetailRow("Category", "Contractor", h),
              buildDetailRow("Purpose of Visit", "Software Installation", h),
              buildDetailRow("Check-in Time", "10:45 AM", h),

              Spacer(),

              // -------------------- UPDATED BUTTON --------------------
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisitorLiveStatusScreen(), // ← change this
                    ),
                  );
                },
                child: Container(
                  width: w * 0.88,
                  height: h * 0.065,
                  margin: EdgeInsets.only(bottom: h * 0.03),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Color(0xFF9B47FF), Color(0xFFB57AFF)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Check-In",
                      style: GoogleFonts.poppins(
                        fontSize: h * 0.022,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDetailRow(String label, String value, double h) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: h * 0.008),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: h * 0.02,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: h * 0.021,
              fontWeight: FontWeight.w600,
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
