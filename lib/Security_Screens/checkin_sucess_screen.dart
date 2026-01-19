import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/security_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CheckInSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> visitorData;
  final String qrCode;

  const CheckInSuccessScreen({
    super.key,
    required this.visitorData,
    required this.qrCode,
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

  String _visitorName = '';
  String _purpose = '';
  String _visitorImage = '';
  bool _isLoading = true;
  String? _errorMessage;

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

    _extractVisitorData();
    _animationController.forward();
  }

  void _extractVisitorData() {
    try {
      // Extract name and purpose from visitorData
      _visitorName =
          widget.visitorData['visitor_name'] ??
          widget.visitorData['name'] ??
          'Visitor';

      _purpose =
          widget.visitorData['purpose_of_visit'] ??
          widget.visitorData['meeting_with'] ??
          'Meeting';

      // _visitorImage = widget.visitorData['visitor_image'] ??
      //                 widget.visitorData['image'] ?? '';

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load visitor details';
      });
    }
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5FF),
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFF7C3AED)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red[400],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

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
                          child: _visitorImage.isNotEmpty
                              ? Image.network(
                                  _visitorImage,
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
                              _visitorName,
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
                                    'Purpose: $_purpose',
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
