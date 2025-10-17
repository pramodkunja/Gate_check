import 'package:flutter/material.dart';
import 'package:gatecheck/Profile_Screen/widgets/change_password.dart';
import 'package:gatecheck/Profile_Screen/widgets/profile_information.dart';
import 'package:gatecheck/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Dashboard_Screens/navigation_drawer.dart';
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
    // Implement logout functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add logout logic here
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleRefresh() {
    // Implement refresh functionality
    setState(() {
      // Reload data
    });
  }

  @override
  Widget build(BuildContext context) {
    String userName = "Veni"; // you’ll replace with API data later
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: CustomAppBar(userName: userName, firstLetter: firstLetter),
      drawer: Navigation(),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.menu, color: Colors.black),
      //     onPressed: () {
      //       Scaffold.of(context).openDrawer();
      //     },
      //   ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: CircleAvatar(
      //         backgroundColor: Colors.grey[200],
      //         child: const Text(
      //           'V',
      //           style: TextStyle(color: Colors.black),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh, color: Colors.purple),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
            const ProfileHeader(
              name: 'Veni',
              companyName: 'Sria Infotech Pvt Ltd',
              initial: 'V',
            ),
            SecuritySection(
              aliasName: 'GedeiaG',
              onChangePassword: _handleChangePassword,
              onLogout: _handleLogout,
            ),
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
