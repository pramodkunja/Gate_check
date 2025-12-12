import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/entry_otp_screen.dart';
import 'package:gatecheck/Security_Screens/manual_check_in.dart';
import 'package:gatecheck/Security_Screens/qr_scanner.dart';
import 'package:gatecheck/Security_Screens/security_custom_appbar.dart';
import 'package:gatecheck/Security_Screens/security_navigation_drawer.dart';
import 'package:gatecheck/Security_Screens/visitor_verify.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityDashboardScreen extends StatelessWidget {
  const SecurityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: SecurityCustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: SecurityNavigation(currentRoute: 'Dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.025),

                /// Title
                Text(
                  "Welcome back, $userName!",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8A03FF),
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  "Here’s today’s visitor activity.",
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: w * 0.035,
                  ),
                ),

                SizedBox(height: h * 0.025),

                /// Visitor Cards
                _visitorCard(
                  context,
                  title: "Checked-In Visitors",
                  count: "142",
                  bgColor: const Color(0xFFEDEAFF),
                  icon: Icons.login,
                ),
                SizedBox(height: h * 0.015),

                _visitorCard(
                  context,
                  title: "Checked-Out Visitors",
                  count: "89",
                  bgColor: const Color(0xFFD6EAFB),
                  icon: Icons.logout,
                ),
                SizedBox(height: h * 0.015),

                _visitorCard(
                  context,
                  title: "Inside Premises",
                  count: "53",
                  bgColor: const Color(0xFFE4FFD9),
                  icon: Icons.people,
                ),

                SizedBox(height: h * 0.03),

                /// Quick Actions
                Text(
                  "Quick Actions",
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h * 0.015),

                _actionButton(
                  context,
                  title: "Scan QR",
                  bg: const Color(0xFFEDEAFF),
                  icon: Icons.qr_code_scanner,
                  action: 'scan_qr',
                ),
                SizedBox(height: h * 0.015),

                _actionButton(
                  context,
                  title: "Manual Check-In",
                  bg: const Color(0xFFFFE0E3),
                  icon: Icons.edit,
                  action: 'manual_checkin',
                ),
                SizedBox(height: h * 0.015),

                _actionButton(
                  context,
                  title: "Manual Check-Out",
                  bg: const Color(0xFFCCE7F6),
                  icon: Icons.exit_to_app,
                  action: 'manual_checkout',
                ),

                SizedBox(height: h * 0.025),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Visitor Card
  Widget _visitorCard(
    BuildContext context, {
    required String title,
    required String count,
    required Color bgColor,
    required IconData icon,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(w * 0.035),
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.10,
            height: w * 0.10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: w * 0.055, color: Colors.black87),
          ),
          SizedBox(width: w * 0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  count,
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Action Button
  Widget _actionButton(
    BuildContext context, {
    required String title,
    required Color bg,
    required IconData icon,
    required String action,
  }) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () => _onActionTap(context, action),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04),
        height: h * 0.10,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(w * 0.035),
        ),
        child: Row(
          children: [
            Icon(icon, size: w * 0.085, color: Colors.black87),
            SizedBox(width: w * 0.045),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation
  void _onActionTap(BuildContext context, String action) {
    if (action == 'scan_qr') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
    } else if (action == 'manual_checkin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EntryOtpScreen()),
      );
    } else if (action == 'manual_checkout') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VisitorVerifyScreen()),
      );
    }
  }
}
