import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/visitors_screen.dart';
import 'package:gatecheck/User_Screens/Reports_screens/reports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current logged-in user from UserService
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

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
                                    builder: (context) => const UserReportsScreen(),
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
                    Column(
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.06,
                          backgroundColor: Colors.purple.shade50,
                          child: Icon(
                            Icons.people_alt,
                            color: Colors.purple,
                            size: screenWidth * 0.065,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "56",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Visitors",
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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