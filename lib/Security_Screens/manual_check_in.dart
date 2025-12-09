import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/qr_scanner.dart';
import 'package:gatecheck/Security_Screens/visitor_live_status.dart';
import 'package:google_fonts/google_fonts.dart';

class ManualCheckInScreen extends StatelessWidget {
  const ManualCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------------------------
              // 1️⃣ CUSTOM HEADER
              // ------------------------------------------------------------------
              SizedBox(height: h * 0.02),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(w * 0.015),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF9D3BFF),
                        width: 1.6,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: w * 0.055,
                      color: const Color(0xFF9D3BFF),
                      
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Manual Check-In",
                        style: GoogleFonts.poppins(
                          fontSize: w * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.10), // balancing the back-icon spacing
                ],
              ),

              SizedBox(height: h * 0.03),

              // ------------------------------------------------------------------
              // 2️⃣ OTP INPUT SECTION
              // ------------------------------------------------------------------
              Container(
                width: w,
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.03,
                  horizontal: w * 0.04,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EDFF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Enter Entry OTP",
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      "Ask the visitor for their Entry OTP",
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: h * 0.025),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: w * 0.11,
                          height: h * 0.06,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF9D3BFF),
                              width: 1.4,
                            ),
                          ),
                          child: TextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: GoogleFonts.poppins(
                              fontSize: w * 0.05,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              // ------------------------------------------------------------------
              // 3️⃣ VISITOR DETAIL CARD
              // ------------------------------------------------------------------
              Container(
                width: w,
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.025,
                  horizontal: w * 0.05,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE9F3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    buildDetailRow("Visitor Name", "Esther Howard", h, w),
                    buildDetailRow("Category", "Interview", h, w),
                    buildDetailRow("Mobile", "+91 12345 67890", h, w),
                    buildDetailRow("Purpose", "Product Designer Role", h, w),
                    buildDetailRow(
                      "Scheduled Time",
                      "10:30 AM",
                      h,
                      w,
                      hasDivider: false,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ------------------------------------------------------------------
              // 4️⃣ BUTTONS SECTION
              // ------------------------------------------------------------------
              // ---------------- VERIFY & CHECK-IN BUTTON ----------------
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitorLiveStatusScreen(),   // ← Replace with your screen
      ),
    );
  },
  child: Container(
    width: w,
    height: h * 0.065,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: const LinearGradient(
        colors: [Color(0xFFB24BFF), Color(0xFF9D3BFF)],
      ),
    ),
    child: Center(
      child: Text(
        "Verify & Check-In",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: w * 0.045,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
),

SizedBox(height: h * 0.015),

// ---------------- SCAN QR INSTEAD BUTTON ----------------
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(),   // ← Replace if needed
      ),
    );
  },
  child: Container(
    width: w,
    height: h * 0.062,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: const Color(0xFF9D3BFF),
        width: 1.6,
      ),
    ),
    child: Center(
      child: Text(
        "Scan QR Instead",
        style: GoogleFonts.poppins(
          color: const Color(0xFF9D3BFF),
          fontWeight: FontWeight.w600,
          fontSize: w * 0.043,
        ),
      ),
    ),
  ),
),


              SizedBox(height: h * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // DETAIL ROW WIDGET
  // ------------------------------------------------------------------
  Widget buildDetailRow(
    String label,
    String value,
    double h,
    double w, {
    bool hasDivider = true,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: w * 0.036,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            SizedBox(width: w * 0.1),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1C1C),
                ),
              ),
            ),
          ],
        ),
        if (hasDivider) ...[
          SizedBox(height: h * 0.015),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          SizedBox(height: h * 0.018),
        ],
      ],
    );
  }
}
