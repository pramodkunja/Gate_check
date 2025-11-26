import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';
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
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Profile data variables
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
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getUserProfile();

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};

        debugPrint('📦 Profile Data: $data');

        setState(() {
          _profileData = data;

          // Extract basic user information
          _name = data['username']?.toString() ?? '';
          _aliasName = data['alias_name']?.toString() ?? '';
          _role = data['roles']?.toString() ?? 'No data found for role';
          _userId = data['user_id']?.toString() ?? 'No data found for user ID';
          _email = data['email']?.toString() ?? '';
          _mobileNumber = data['mobile_number']?.toString() ?? '';
          _blockBuilding = data['block']?.toString() ?? '';
          _floor = data['floor']?.toString() ?? '';

          // Extract nested company information
          if (data['company'] != null &&
              data['company'] is Map<String, dynamic>) {
            final company = data['company'] as Map<String, dynamic>;
            _companyName = company['company_name']?.toString() ?? '';
            _address = company['address']?.toString() ?? '';
            _location = company['location']?.toString() ?? '';
            _pinCode = company['pin_code']?.toString() ?? '';
          } else {
            _companyName = '';
            _address = '';
            _location = '';
            _pinCode = '';
          }

          debugPrint('✅ Mapped Data:');
          debugPrint('   Name: $_name');
          debugPrint('   Company: $_companyName');
          debugPrint('   Alias: $_aliasName');
          debugPrint('   Role: $_role');
          debugPrint('   Email: $_email');
          debugPrint('   Mobile: $_mobileNumber');
          debugPrint('   Address: $_address');
          debugPrint('   Location: $_location');
          debugPrint('   Pin Code: $_pinCode');
        });
      } else {
        _showErrorSnackBar('Failed to load profile data');
      }
    } catch (e) {
      debugPrint('❌ Error fetching profile: $e');
      _showErrorSnackBar('Error loading profile data');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
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

  Future<void> _performLogout() async {
    try {
      await _apiService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      _showErrorSnackBar('Logout failed. Please try again.');
    }
  }

  void _handleRefresh() {
    _fetchProfileData();
    _showSuccessSnackBar('Refreshing profile...');
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    // Use fetched data if available, otherwise use UserService
    final displayName = _name.isNotEmpty ? _name : userName;
    final displayEmail = _email.isNotEmpty ? _email : email;
    final displayInitial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';

    // decide role
    final String? role = UserService()
        .getUserRole(); // assume you add this service method
    final bool isAdmin = (role == null || role == 'admin');

    return Scaffold(
      drawer: isAdmin
          ? const Navigation(currentRoute: 'Profile') // assume admin drawer
          : const UserNavigation(currentRoute: 'Profile',), // you should have a user drawer
      appBar: isAdmin
          ? CustomAppBar(
              userName: userName,
              firstLetter: firstLetter,
              email: email,
            )
          : UserCustomAppBar(
              userName: userName,
              firstLetter: firstLetter,
              email: email,
            ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
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
                            const Icon(
                              Icons.person_outline,
                              color: Colors.black,
                            ),
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
                  ProfileHeader(
                    name: displayName,
                    companyName: _companyName,
                    initial: displayInitial,
                  ),

                  // Security Section
                  SecuritySection(
                    aliasName: _aliasName,
                    onChangePassword: _handleChangePassword,
                    onLogout: _handleLogout,
                  ),

                  // Profile Information Section
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
