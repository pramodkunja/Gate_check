import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import your screens
import 'package:gatecheck/Admin_Screens/Categories/Screens/categories_management_screen.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/dashboard_screen.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/organization_screen.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/profile_screen.dart';
import 'package:gatecheck/Admin_Screens/Permission_screens/permissions_management.dart';
import 'package:gatecheck/Admin_Screens/Roles_permissions_screen/role_permission_management.dart';
import 'package:gatecheck/Admin_Screens/Roles_screens/roles_management.dart';
import 'package:gatecheck/Admin_Screens/User_roles-screen/user_role_management.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/visitors_screen.dart';

class Navigation extends StatefulWidget {
  final String currentRoute;

  const Navigation({ Key? key, required this.currentRoute }) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  bool isRolesExpanded = false;
  late String selectedRoute;

  bool _isSuperUser = false;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    selectedRoute = widget.currentRoute;
    isRolesExpanded = _isRolesGroup(selectedRoute);
    _loadUserRoleInfo();
  }

  Future<void> _loadUserRoleInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSuperUser = prefs.getBool('isSuperUser') ?? false;
      _userRole = prefs.getString('userRole')?.toLowerCase() ?? '';
      // If not superuser and role is Admin, we collapse roles section by default
      if (_userRole == 'admin' && !_isSuperUser) {
        isRolesExpanded = false;
      }
    });
  }

  bool _isRolesGroup(String route) {
    return route == 'Roles' ||
        route == 'Permissions' ||
        route == 'Roles & Permissions' ||
        route == 'User Roles';
  }

  @override
  void didUpdateWidget(covariant Navigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      setState(() {
        selectedRoute = widget.currentRoute;
        isRolesExpanded = _isRolesGroup(selectedRoute);
      });
    }
  }

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
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isSelected: selectedRoute == 'Dashboard',
                    onTap: () => _handleNavigation('Dashboard'),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'GateCheck',
                    isSelected: selectedRoute == 'GateCheck',
                    onTap: () => _handleNavigation('GateCheck'),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    isSelected: selectedRoute == 'Profile',
                    onTap: () => _handleNavigation('Profile'),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildMenuItem(
                    icon: Icons.business_outlined,
                    title: 'Organization',
                    isSelected: selectedRoute == 'Organization',
                    onTap: () => _handleNavigation('Organization'),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Roles Section: show differently depending on user
                  if (_isSuperUser) ...[
                    // Super-user: full roles section
                    _buildExpandableMenuItem(
                      icon: Icons.person_outline,
                      title: 'Roles',
                      isExpanded: isRolesExpanded,
                      onTap: () {
                        setState(() {
                          isRolesExpanded = !isRolesExpanded;
                        });
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isRolesExpanded
                          ? Column(
                              children: [
                                _buildSubMenuItem(
                                  icon: Icons.person_outline,
                                  title: 'Roles',
                                  isSelected: selectedRoute == 'Roles',
                                  onTap: () => _handleNavigation('Roles'),
                                ),
                                _buildSubMenuItem(
                                  icon: Icons.shield_outlined,
                                  title: 'Permissions',
                                  isSelected: selectedRoute == 'Permissions',
                                  onTap: () => _handleNavigation('Permissions'),
                                ),
                                _buildSubMenuItem(
                                  icon: Icons.link,
                                  title: 'Roles & Permissions',
                                  isSelected: selectedRoute == 'Roles & Permissions',
                                  onTap: () => _handleNavigation('Roles & Permissions'),
                                ),
                                _buildSubMenuItem(
                                  icon: Icons.person_outline,
                                  title: 'User Roles',
                                  isSelected: selectedRoute == 'User Roles',
                                  onTap: () => _handleNavigation('User Roles'),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                  ] else if (_userRole == 'admin' && !_isSuperUser) ...[
                    // Role == Admin but not superuser: only show User Roles sub-item
                    _buildExpandableMenuItem(
                      icon: Icons.person_outline,
                      title: 'Roles',
                      isExpanded: isRolesExpanded,
                      onTap: () {
                        // we can keep expanded always or toggle, as you like
                        setState(() {
                          isRolesExpanded = !isRolesExpanded;
                        });
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isRolesExpanded
                          ? Column(
                              children: [
                                _buildSubMenuItem(
                                  icon: Icons.person_outline,
                                  title: 'User Roles',
                                  isSelected: selectedRoute == 'User Roles',
                                  onTap: () => _handleNavigation('User Roles'),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                  ],

                  _buildMenuItem(
                    icon: Icons.folder_outlined,
                    title: 'Categories',
                    isSelected: selectedRoute == 'Categories',
                    onTap: () => _handleNavigation('Categories'),
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
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
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

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String title,
    required bool isExpanded,
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white,
                size: screenWidth * 0.055,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
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
          margin: EdgeInsets.only(left: screenWidth * 0.08),
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.03,
            horizontal: screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF334155) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF94A3B8), size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    fontSize: screenWidth * 0.038,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String route) {
    setState(() {
      selectedRoute = route;
      isRolesExpanded = _isRolesGroup(route);
    });

    Navigator.pop(context);

    if (route == 'Dashboard') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
    } else if (route == 'GateCheck') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegularVisitorsScreen()));
    } else if (route == 'Profile') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else if (route == 'Organization') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganizationManagementScreen()));
    } else if (route == 'Roles') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RolesManagementScreen()));
    } else if (route == 'Permissions') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PermissionManagementScreen()));
    } else if (route == 'Roles & Permissions') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RolePermissionsScreen()));
    } else if (route == 'User Roles') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRolesManagementScreen()));
    } else if (route == 'Categories') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesManagementScreen()));
    }
  }
}
