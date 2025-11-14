import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Admin_Screens/Permission_screens/permission_add_user_dialog.dart';
import 'package:gatecheck/Services/Permission_services/permission_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class PermissionManagementScreen extends StatefulWidget {
  const PermissionManagementScreen({super.key});

  @override
  State<PermissionManagementScreen> createState() =>
      _PermissionManagementScreenState();
}

class _PermissionManagementScreenState
    extends State<PermissionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PermissionService _permissionService = PermissionService();

  String _selectedFilter = 'All Permissions';
  List<Map<String, dynamic>> _permissions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Custom colors
  final Color purpleColor = const Color(0xFF7C4585);
  final Color greenColor = const Color(0xFF4CAF50);
  final Color redColor = const Color(0xFFFF6B6B);
  final Color greyColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load permissions from API
  Future<void> _loadPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final permissions = await _permissionService.getAllPermissions();
      setState(() {
        _permissions = permissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to load permissions'),
            backgroundColor: redColor,
          ),
        );
      }
    }
  }

  // Create new permission
  Future<void> _createPermission(String name, bool isActive) async {
    try {
      final success = await _permissionService.createPermission(
        name: name,
        isActive: isActive,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permission created successfully'),
              backgroundColor: greenColor,
            ),
          );
        }
        await _loadPermissions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: redColor,
          ),
        );
      }
    }
  }

  // Update permission
  Future<void> _updatePermission(
    int permissionId,
    String name,
    bool isActive,
  ) async {
    try {
      final success = await _permissionService.updatePermission(
        permissionId: permissionId,
        name: name,
        isActive: isActive,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permission updated successfully'),
              backgroundColor: greenColor,
            ),
          );
        }
        await _loadPermissions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: redColor,
          ),
        );
      }
    }
  }

  // Delete permission
  Future<void> _deletePermission(int permissionId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Permission'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _permissionService.deletePermission(permissionId);

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Permission deleted successfully'),
                backgroundColor: greenColor,
              ),
            );
          }
          await _loadPermissions();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: redColor,
            ),
          );
        }
      }
    }
  }

  // Filter permissions
  List<Map<String, dynamic>> _getFilteredPermissions() {
    return _permissions.where((permission) {
      // Filter by status
      if (_selectedFilter == 'Active' && permission['is_active'] != true) {
        return false;
      }
      if (_selectedFilter == 'Inactive' && permission['is_active'] == true) {
        return false;
      }

      // Filter by search text
      if (_searchController.text.isNotEmpty) {
        final searchLower = _searchController.text.toLowerCase();
        final name = permission['name']?.toString().toLowerCase() ?? '';
        return name.contains(searchLower);
      }

      return true;
    }).toList();
  }

  // Get statistics
  int get _totalPermissions => _permissions.length;
  int get _activePermissions =>
      _permissions.where((p) => p['is_active'] == true).length;
  int get _inactivePermissions =>
      _permissions.where((p) => p['is_active'] != true).length;

  // Format date
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return dateStr;
    }
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
      drawer: Navigation(),
      backgroundColor: greyColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: purpleColor))
            : Padding(
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
                              Icons.security_outlined,
                              color: Colors.blue,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Permission\nManagement',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Manage user permissions',
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
                              builder: (_) => AddNewPermissionDialog(
                                onSubmit: (permissionName, isActive) async {
                                  await _createPermission(
                                    permissionName,
                                    isActive,
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Add Permission',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
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
                            'Total Permissions',
                            _totalPermissions.toString(),
                            purpleColor,
                            FontAwesomeIcons.users,
                          ),
                          _buildStatCard(
                            'Active Permissions',
                            _activePermissions.toString(),
                            greenColor,
                            FontAwesomeIcons.checkCircle,
                          ),
                          _buildStatCard(
                            'Inactive Permissions',
                            _inactivePermissions.toString(),
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
                              hintText: 'Search permissions…',
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                items: ['All Permissions', 'Active', 'Inactive']
                                    .map(
                                      (filter) => DropdownMenuItem<String>(
                                        value: filter,
                                        child: Text(
                                          filter,
                                          style: GoogleFonts.poppins(
                                            fontSize: 8,
                                          ),
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
                          onPressed: _loadPermissions,
                          icon: const Icon(Icons.refresh, size: 28),
                          color: purpleColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Permissions List
                    Expanded(
                      child: _permissions.isEmpty
                          ? Center(
                              child: Text(
                                'No permissions found',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _getFilteredPermissions().length,
                              itemBuilder: (context, index) {
                                final permission =
                                    _getFilteredPermissions()[index];
                                return _buildPermissionCard(
                                  permission,
                                  isSmallScreen,
                                );
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
      padding: const EdgeInsets.all(10),
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

  Widget _buildPermissionCard(Map<String, dynamic> permission, bool isSmall) {
    final bool isActive = permission['is_active'] ?? false;
    final Color statusColor = isActive ? greenColor : redColor;
    final int permissionId = permission['permission_id'] ?? 0;
    final String name = permission['name'] ?? 'Unknown';

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
          // Permission name & status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$name (#$permissionId)',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmall ? 16 : 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Created by: ${permission['created_by'] ?? 'N/A'} on ${_formatDate(permission['created_at'])}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            'Modified: ${_formatDate(permission['modified_at'])}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: purpleColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddNewPermissionDialog(
                      onSubmit: (newName, newIsActive) async {
                        await _updatePermission(
                          permissionId,
                          newName,
                          newIsActive,
                        );
                      },
                      initialName: name,
                      initialIsActive: isActive,
                      isEdit: true,
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: redColor),
                onPressed: () => _deletePermission(permissionId, name),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
