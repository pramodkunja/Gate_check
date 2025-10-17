import 'package:flutter/material.dart';
import 'package:gatecheck/Roles_screens/roles_management.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  bool isRolesExpanded = false;
  String selectedRoute = 'Dashboard';

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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
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

                  // Expandable Roles Section
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

                  // Submenu Items
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
                                isSelected:
                                    selectedRoute == 'Roles & Permissions',
                                onTap: () =>
                                    _handleNavigation('Roles & Permissions'),
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

                  if (!isRolesExpanded) SizedBox(height: screenHeight * 0.01),
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
                style: TextStyle(
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.042,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.042,
                  ),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
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
              Icon(
                icon,
                color: const Color(0xFF94A3B8),
                size: screenWidth * 0.05,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    fontSize: screenWidth * 0.038,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
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
    });
    Navigator.pop(context);

    if (route == 'Roles') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RolesManagementScreen()),
      );
    }
    // Add your navigation logic here
    // Example: Navigator.pushNamed(context, '/$route');
  }
}
