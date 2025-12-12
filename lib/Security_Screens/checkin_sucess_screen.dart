import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/security_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CheckInSuccessScreen extends StatefulWidget {
  final String visitorName;
  final String issuedBy;
  final String visitorImage;

  const CheckInSuccessScreen({
    super.key,
    required this.visitorName,
    required this.issuedBy,
    required this.visitorImage,
  });

  @override
  State<CheckInSuccessScreen> createState() => _CheckInSuccessScreenState();
}

class _CheckInSuccessScreenState extends State<CheckInSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late String _checkInTime;

  @override
  void initState() {
    super.initState();

    // Get current time when screen loads
    _checkInTime = DateFormat('hh:mm a').format(DateTime.now());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.03,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Check Icon
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: size.width * 0.45,
                      height: size.width * 0.45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C3AED).withOpacity(0.2),
                            const Color(0xFF7C3AED).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: size.width * 0.35,
                          height: size.width * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8DCFF),
                          ),
                          child: Icon(
                            Icons.check,
                            size: size.width * 0.18,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: size.height * 0.04),

              // Success Text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Check-In Successful!',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 26 : 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.015),
                    Text(
                      'Visitor entry log updated.',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 15 : 16,
                        color: const Color(0xFF8B8B8B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      'Entry time recorded at $_checkInTime.',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 15 : 16,
                        color: const Color(0xFF8B8B8B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // Visitor Details Card
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Visitor Image
                      Container(
                        width: size.width * 0.16,
                        height: size.width * 0.16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE8DCFF),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: widget.visitorImage.isNotEmpty
                              ? Image.network(
                                  widget.visitorImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFF0F0F5),
                                      child: Icon(
                                        Icons.person,
                                        size: size.width * 0.08,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFFF0F0F5),
                                  child: Icon(
                                    Icons.person,
                                    size: size.width * 0.08,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),

                      // Visitor Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VISITOR DETAILS',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7C3AED),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: size.height * 0.005),
                            Text(
                              widget.visitorName,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 17 : 19,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: size.height * 0.005),
                            Row(
                              children: [
                                Icon(
                                  Icons.business_center,
                                  size: isSmallScreen ? 14 : 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: size.width * 0.015),
                                Expanded(
                                  child: Text(
                                    'Meeting with ${widget.issuedBy}',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 13 : 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Active Status Indicator
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF34C759).withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Back to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: size.height * 0.07,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecurityDashboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
