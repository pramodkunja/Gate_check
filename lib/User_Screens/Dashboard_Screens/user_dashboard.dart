import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/visitors_screen.dart';
import 'package:gatecheck/User_Screens/Reports_screens/reports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:dio/dio.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _visitorCount = 0;
  bool _isLoadingVisitors = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchVisitorCount();
  }

  Future<void> _fetchVisitorCount() async {
    setState(() {
      _isLoadingVisitors = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService().dio.get(
        '/visitors/company/1/visitors/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> visitors = response.data;
        setState(() {
          _visitorCount = visitors.length;
          _isLoadingVisitors = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load visitors';
          _isLoadingVisitors = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = ApiService().getErrorMessage(e);
        _isLoadingVisitors = false;
      });
      debugPrint('❌ Error fetching visitors: $_errorMessage');
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error occurred';
        _isLoadingVisitors = false;
      });
      debugPrint('❌ Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current logged-in user from UserService
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isSmall = screenWidth < 360;
    final isMedium = screenWidth >= 360 && screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: UserCustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: const UserNavigation(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome message
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.purple, width: 1.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back, $userName!",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.008),
                          Text(
                            "Here's what's happening with your security system today.",
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Quick Actions
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.012),
                            Text(
                              "Quick Actions",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.012),

                            // Action Cards
                            _buildActionCard(
                              context: context,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              color: Colors.purple.shade50,
                              icon: Icons.person_add_alt,
                              label: "Add New Visitor",
                              iconColor: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegularVisitorsScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.012),
                            _buildActionCard(
                              context: context,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              color: Colors.blue.shade50,
                              icon: Icons.description_outlined,
                              label: "Generate Report",
                              iconColor: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UserReportsScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.012),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Visitors section
                    _buildVisitorCountCard(isSmall, isMedium),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisitorCountCard(bool isSmall, bool isMedium) {
    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 20 : 24,
          horizontal: 16,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: isSmall ? 28 : (isMedium ? 32 : 36),
              backgroundColor: Colors.purple.shade50,
              child: _isLoadingVisitors
                  ? SizedBox(
                      width: isSmall ? 20 : 24,
                      height: isSmall ? 20 : 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.purple,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.people_alt,
                      color: Colors.purple,
                      size: isSmall ? 26 : (isMedium ? 30 : 34),
                    ),
            ),
            SizedBox(height: isSmall ? 10 : 12),
            if (_isLoadingVisitors)
              Text(
                "Loading...",
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: isSmall ? 20 : 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 12 : 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _fetchVisitorCount,
                    icon: Icon(Icons.refresh, size: isSmall ? 16 : 18),
                    label: Text(
                      "Retry",
                      style: GoogleFonts.poppins(fontSize: isSmall ? 12 : 14),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    "\u0000$_visitorCount",
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 32 : (isMedium ? 36 : 40),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Total Visitors",
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: isSmall ? 13 : (isMedium ? 14 : 15),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
    required Color color,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.022),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.02),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
