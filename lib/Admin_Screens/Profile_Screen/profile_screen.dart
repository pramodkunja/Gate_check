import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';

// USER UI
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';

// ADMIN UI
import 'package:gatecheck/Admin_Screens/Profile_Screen/widgets/change_password.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/widgets/profile_information.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';

// SECURITY UI (NEW IMPORTS)
import 'package:gatecheck/Security_Screens/security_custom_appbar.dart';
import 'package:gatecheck/Security_Screens/security_navigation_drawer.dart';

import 'widgets/profile_header.dart';
import 'widgets/security_section.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // ignore: unused_field
  Map<String, dynamic>? _profileData;

  String _name = '';
  String _companyName = '';
  String _aliasName = '';
  String _role = 'No data found for role';
  String _userId = 'No data found for user ID';
  String _email = '';
  String _mobileNumber = '';
  String _blockBuilding = '';
  String _floor = '';
  String _address = '';
  String _location = '';
  String _pinCode = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getUserProfile();

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        setState(() {
          _profileData = data;

          _name = data['username']?.toString() ?? '';
          _aliasName = data['alias_name']?.toString() ?? '';
          _role = data['roles']?.toString() ?? 'No data found for role';
          _userId = data['user_id']?.toString() ?? 'No data found for user ID';
          _email = data['email']?.toString() ?? '';
          _mobileNumber = data['mobile_number']?.toString() ?? '';
          _blockBuilding = data['block']?.toString() ?? '';
          _floor = data['floor']?.toString() ?? '';

          if (data['company'] is Map<String, dynamic>) {
            final company = data['company'];
            _companyName = company['company_name']?.toString() ?? '';
            _address = company['address']?.toString() ?? '';
            _location = company['location']?.toString() ?? '';
            _pinCode = company['pin_code']?.toString() ?? '';
          }
        });
      } else {
        _showError("Failed to load profile data");
      }
    } catch (e) {
      _showError("Error loading profile data");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void _handleChangePassword() {
    showDialog(context: context, builder: (context) => const ChangePasswordDialog());
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to logout?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _apiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();
    String role = (UserService().getUserRole()).trim().toLowerCase();

    // Role Logic
    final bool isAdmin = role.isEmpty || role == "admin" || role == "null";
    final bool isSecurity = role == "security";
    // ignore: unused_local_variable
    final bool isUser = !isAdmin && !isSecurity;

    // Override with backend fetched data if available
    final String displayName = _name.isNotEmpty ? _name : userName;
    final String displayInitial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";
    final String displayEmail = _email.isNotEmpty ? _email : email;

    return Scaffold(
      drawer: isAdmin
          ? const Navigation(currentRoute: "Profile")
          : isSecurity
              ? const SecurityNavigation(currentRoute: "Profile")
              : const UserNavigation(currentRoute: "Profile"),

      appBar: isAdmin
          ? CustomAppBar(userName: userName, firstLetter: initial, email: email)
          : isSecurity
              ? SecurityCustomAppBar(userName: userName, firstLetter: initial, email: email)
              : UserCustomAppBar(userName: userName, firstLetter: initial, email: email),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
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
                              "Profile",
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            _fetchProfileData();
                            _showSuccess("Refreshing profile...");
                          },
                          icon: const Icon(Icons.refresh, color: Colors.purple),
                          label: Text("Refresh", style: GoogleFonts.poppins(color: Colors.purple)),
                        ),
                      ],
                    ),
                  ),

                  // Profile Header
                  ProfileHeader(
                    name: displayName,
                    companyName: _companyName,
                    initial: displayInitial,
                  ),

                  // Security Actions
                  SecuritySection(
                    aliasName: _aliasName,
                    onChangePassword: _handleChangePassword,
                    onLogout: _handleLogout,
                  ),

                  // Profile Information
                  ProfileInformationSection(
                    role: _role,
                    companyName: _companyName,
                    userName: displayName,
                    userId: _userId,
                    aliasName: _aliasName,
                    email: displayEmail,
                    mobileNumber: _mobileNumber,
                    blockBuilding: _blockBuilding,
                    floor: _floor,
                    address: _address,
                    location: _location,
                    pinCode: _pinCode,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
