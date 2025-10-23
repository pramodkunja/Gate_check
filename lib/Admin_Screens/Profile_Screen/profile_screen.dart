import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/widgets/change_password.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/widgets/profile_information.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'widgets/profile_header.dart';
import 'widgets/security_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _handleChangePassword() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRefresh() {
    setState(() {
      // Reload data
    });
  }

  @override
  Widget build(BuildContext context) {
    String userName = "Veni"; // Replace with API data later
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";

    return Scaffold(
      appBar: CustomAppBar(userName: userName, firstLetter: firstLetter),
      drawer: Navigation(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh, color: Colors.purple),
                    label: Text(
                      'Refresh',
                      style: GoogleFonts.poppins(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Header
            const ProfileHeader(
              name: 'Veni',
              companyName: 'Sria Infotech Pvt Ltd',
              initial: 'V',
            ),

            // Security Section
            SecuritySection(
              aliasName: 'GedeiaG',
              onChangePassword: _handleChangePassword,
              onLogout: _handleLogout,
            ),

            // Profile Information Section
            const ProfileInformationSection(
              role: 'No data found for role',
              companyName: 'Sria Infotech Pvt Ltd',
              userName: 'Veni',
              userId: 'No data found for user ID',
              aliasName: 'GedeiaG',
              email: 'teerdavenig@gmail.com',
              mobileNumber: '9949876906',
              blockBuilding: '2121',
              floor: '43',
              address:
                  '1ST Floor, 1-121/63, Survey NO 63 Part, Behind Hotel Sitara Grand',
              location: 'Hyderabad',
              pinCode: '500081',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
