import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Admin_Screens/Roles_screens/add_role_dialog.dart';
import 'package:gatecheck/Services/Roles_services/roles_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RolesManagementScreen extends StatefulWidget {
  const RolesManagementScreen({super.key});

  @override
  State<RolesManagementScreen> createState() => _RolesManagementScreenState();
}

class _RolesManagementScreenState extends State<RolesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RoleService _roleService = RoleService();

  String _selectedFilter = 'All Roles';
  List<Map<String, dynamic>> roles = [];
  bool isLoading = true;
  String? errorMessage;

  // Custom colors
  final Color purpleColor = const Color(0xFF7C4585);
  final Color greenColor = const Color(0xFF4CAF50);
  final Color redColor = const Color(0xFFFF6B6B);
  final Color greyColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -------------------- Fetch Roles --------------------
  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedRoles = await _roleService.getAllRoles();
      setState(() {
        roles = fetchedRoles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load roles: $e');
    }
  }

  // -------------------- Create Role --------------------
  Future<void> createRole(String roleName, bool isActive) async {
    try {
      _showLoadingDialog();
      final userName = UserService().getUserName();

      await _roleService.createRole(
        name: roleName,
        isActive: isActive,
        createdBy: userName,
      );

      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar('Role created successfully!');
      await fetchRoles(); // Refresh the list
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Failed to create role: $e');
    }
  }

  // -------------------- Update Role --------------------
  Future<void> updateRole(int roleId, String roleName, bool isActive) async {
    try {
      _showLoadingDialog();
      final userName = UserService().getUserName();

      await _roleService.updateRole(
        roleId: roleId,
        name: roleName,
        isActive: isActive,
        modifiedBy: userName,
      );

      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar('Role updated successfully!');
      await fetchRoles(); // Refresh the list
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Failed to update role: $e');
    }
  }

  // -------------------- Delete Role --------------------
  Future<void> deleteRole(int roleId) async {
    try {
      _showLoadingDialog();
      await _roleService.deleteRole(roleId);

      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar('Role deleted successfully!');
      await fetchRoles(); // Refresh the list
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Failed to delete role: $e');
    }
  }

  // -------------------- Toggle Role Status --------------------
  Future<void> toggleRoleStatus(Map<String, dynamic> role) async {
    try {
      _showLoadingDialog();
      final userName = UserService().getUserName();

      await _roleService.toggleRoleStatus(
        roleId: role['role_id'],
        name: role['name'],
        currentStatus: role['is_active'],
        modifiedBy: userName,
      );

      Navigator.pop(context); // Close loading dialog
      final newStatus = !role['is_active'] ? 'activated' : 'deactivated';
      _showSuccessSnackBar('Role $newStatus successfully!');
      await fetchRoles(); // Refresh the list
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Failed to toggle role status: $e');
    }
  }

  // -------------------- UI Helper Methods --------------------
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: purpleColor),
                const SizedBox(height: 16),
                Text('Processing...', style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: greenColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: redColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // -------------------- Statistics Getters --------------------
  int get totalRoles => roles.length;
  int get activeRoles => roles.where((r) => r['is_active'] == true).length;
  int get inactiveRoles => roles.where((r) => r['is_active'] == false).length;

  // -------------------- Filter Roles --------------------
  List<Map<String, dynamic>> get filteredRoles {
    List<Map<String, dynamic>> filtered = roles;

    // Apply status filter
    if (_selectedFilter == 'Active') {
      filtered = filtered.where((r) => r['status'] == 'Active').toList();
    } else if (_selectedFilter == 'Inactive') {
      filtered = filtered.where((r) => r['status'] == 'Inactive').toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((r) {
        return r['name'].toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: Navigation(currentRoute: 'Roles',),
      backgroundColor: greyColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Roles Management',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Manage user roles and permissions',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddNewRoleDialog(
                          onSubmit: (roleName, isActive) async {
                            Navigator.pop(context);
                            await createRole(roleName, isActive);
                          },
                          initialName: null,
                          initialIsActive: null,
                          isEdit: false,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Add Role',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Statistic Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total Roles',
                      totalRoles.toString(),
                      purpleColor,
                      FontAwesomeIcons.users,
                    ),
                    _buildStatCard(
                      'Active Roles',
                      activeRoles.toString(),
                      greenColor,
                      FontAwesomeIcons.checkCircle,
                    ),
                    _buildStatCard(
                      'Inactive Roles',
                      inactiveRoles.toString(),
                      redColor,
                      FontAwesomeIcons.timesCircle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search & Filter Section
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search roles…',
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          items: ['All Roles', 'Active', 'Inactive']
                              .map(
                                (filter) => DropdownMenuItem<String>(
                                  value: filter,
                                  child: Text(
                                    filter,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: fetchRoles,
                    icon: const Icon(Icons.refresh, size: 28),
                    color: purpleColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Roles List
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: purpleColor),
                            const SizedBox(height: 16),
                            Text(
                              'Loading roles...',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: redColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: redColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: fetchRoles,
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                'Retry',
                                style: GoogleFonts.poppins(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: purpleColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredRoles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No roles found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRoles.length,
                        itemBuilder: (context, index) {
                          final role = filteredRoles[index];
                          return _buildRoleCard(role, isSmallScreen);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String number,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 160,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
          Text(
            number,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role, bool isSmall) {
    final Color statusColor = role['status'] == 'Active'
        ? greenColor
        : redColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role name & status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${role['name']}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmall ? 16 : 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => toggleRoleStatus(role),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        role['status'],
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                     // Icon(Icons.toggle_on, color: statusColor, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Id : ${role['role_id']}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          Text(
            'Created by: ${role['createdBy']} on ${role['createdDate']}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          Text(
            'Modified: ${role['modifiedDate']}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          if (role['modifiedBy'] != null)
            Text(
              'Modified by: ${role['modifiedBy']}',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: purpleColor),
                tooltip: 'Edit Role',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddNewRoleDialog(
                      initialName: role['name'],
                      initialIsActive: role['is_active'],
                      isEdit: true,
                      onSubmit: (roleName, isActive) async {
                        Navigator.pop(context);
                        await updateRole(role['role_id'], roleName, isActive);
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: greenColor),
                tooltip: 'View Details',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.info_outline, color: purpleColor),
                          const SizedBox(width: 8),
                          Text('Role Details', style: GoogleFonts.poppins()),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('ID', '#${role['role_id']}'),
                            _buildDetailRow('Name', role['name']),
                            _buildDetailRow('Status', role['status']),
                            _buildDetailRow('Created By', role['createdBy']),
                            _buildDetailRow('Created On', role['createdDate']),
                            _buildDetailRow('Modified', role['modifiedDate']),
                            if (role['modifiedBy'] != null)
                              _buildDetailRow(
                                'Modified By',
                                role['modifiedBy'],
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.poppins(color: purpleColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: redColor),
                tooltip: 'Delete Role',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: redColor),
                          const SizedBox(width: 8),
                          Text('Delete Role', style: GoogleFonts.poppins()),
                        ],
                      ),
                      content: Text(
                        'Are you sure you want to delete "${role['name']}"? This action cannot be undone.',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            deleteRole(role['role_id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Delete', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
