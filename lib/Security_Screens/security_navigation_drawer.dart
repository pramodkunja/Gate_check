import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/profile_screen.dart';
import 'package:gatecheck/Security_Screens/manual_check_in.dart';
import 'package:gatecheck/Security_Screens/qr_scanner.dart';
import 'package:gatecheck/Security_Screens/security_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';


class SecurityNavigation extends StatelessWidget {
  final String currentRoute;

  const SecurityNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      backgroundColor: const Color(0xFF1A2332),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.025,
                horizontal: screenWidth * 0.05,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF2D3748), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GATE CHECK',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8),
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isSelected: currentRoute == 'Dashboard',
                    onTap: () => _navigate(context, SecurityDashboardScreen()),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.shield_outlined,
                    title: 'Scan QR Code',
                    isSelected: currentRoute == 'Scan QR Code',
                    onTap: () => _navigate(context, QrScannerScreen()),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Manual Check-In',
                    isSelected: currentRoute == 'Manual Check-In',
                    onTap: () => _navigate(context, ManualCheckInScreen()),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Manual Check-Out',
                    isSelected: currentRoute == 'Manual Check-Out',
                    onTap: () => _navigate(context, ManualCheckInScreen()),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    isSelected: currentRoute == 'Profile',
                    onTap: () => _navigate(context, ProfileScreen()),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF2D3748), width: 1),
                ),
              ),
              child: Text(
                '© 2025 Gate Check',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontSize: screenWidth * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.035,
            horizontal: screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: const Color(0xFF818CF8), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: screenWidth * 0.042,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
