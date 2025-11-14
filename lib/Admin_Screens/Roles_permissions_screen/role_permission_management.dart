// role_permissions_management.dart
// Place this file in: lib/Admin_Screens/Dashboard_Screens/

import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Admin_Screens/Roles_permissions_screen/assign_permissions_dialog.dart';
import 'package:gatecheck/Admin_Screens/Roles_permissions_screen/edit_permissions_dialog.dart';
import 'package:gatecheck/Services/Roles_permission_services/role_permissions_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RolePermissionsScreen extends StatefulWidget {
  const RolePermissionsScreen({Key? key}) : super(key: key);

  @override
  State<RolePermissionsScreen> createState() => _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends State<RolePermissionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RolePermissionsApiService _apiService = RolePermissionsApiService();

  String _filterValue = 'All Roles';
  List<RolePermissionModel> _allRoles = [];
  List<RolePermissionModel> _filteredRoles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearchFilter);
    _loadRolePermissions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRolePermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roles = await _apiService.getRolePermissions();
      setState(() {
        _allRoles = roles;
        _filteredRoles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load role permissions: $e';
        _isLoading = false;
      });
    }
  }

  void _applySearchFilter() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredRoles = _allRoles.where((r) {
        final matchesQuery = r.role.toLowerCase().contains(q);
        final matchesFilter =
            (_filterValue == 'All Roles') || r.role == _filterValue;
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  void _onFilterChanged(String? v) {
    if (v == null) return;
    setState(() => _filterValue = v);
    _applySearchFilter();
  }

  Future<void> _refreshList() async {
    await _loadRolePermissions();
    _searchController.clear();
    _filterValue = 'All Roles';
  }

  void _openEdit(RolePermissionModel role) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          EditPermissionsDialog(role: role, onUpdate: _loadRolePermissions),
    );
  }

  void _confirmDelete(RolePermissionModel role) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text(
          'Are you sure you want to delete the role "${role.role}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _apiService.deleteRolePermissions(
                role.rolePermissionId,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role deleted successfully')),
                );
                _loadRolePermissions();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete role')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToAssign() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AssignPermissionsDialog(onAssign: _loadRolePermissions),
    );
  }

  int _getTotalPermissions() {
    final allPerms = <String>{};
    for (var role in _allRoles) {
      allPerms.addAll(role.permissions);
    }
    return allPerms.length;
  }

  double _getAvgPermissionsPerRole() {
    if (_allRoles.isEmpty) return 0;
    final total = _allRoles.fold<int>(
      0,
      (sum, role) => sum + role.permissions.length,
    );
    return total / _allRoles.length;
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();
    final textDark = const Color(0xFF1F1F1F);

    // Get unique roles for filter dropdown
    final uniqueRoles = _allRoles.map((r) => r.role).toSet().toList();

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: Navigation(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRolePermissions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.link, color: Colors.blue, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Role Permissions\nManagement',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _navigateToAssign,
                          icon: const Icon(Icons.add, color: Color(0xFF7E57C2)),
                          label: Text(
                            'Assign\nPermissions',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF7E57C2),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Color(0xFF7E57C2)),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 13,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Assign permissions to roles',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistics cards
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatCard(
                          title: 'Total Assignments',
                          countText: '${_allRoles.length}',
                          bgColor: const Color(0xFFEAF3FF),
                          icon: Icons.link,
                        ),
                        _StatCard(
                          title: 'Roles with Permissions',
                          countText: '${_allRoles.length}/${_allRoles.length}',
                          bgColor: const Color(0xFFF1E8FF),
                          icon: Icons.shield,
                        ),
                        _StatCard(
                          title: 'Available Permissions',
                          countText: '${_getTotalPermissions()}',
                          bgColor: const Color(0xFFE8FBE8),
                          icon: Icons.vpn_key,
                        ),
                        _StatCard(
                          title: 'Avg Permissions/Role',
                          countText: _getAvgPermissionsPerRole()
                              .toStringAsFixed(1),
                          bgColor: const Color(0xFFFFF2E2),
                          icon: Icons.people,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Search & filter row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search roles...',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: _filterValue,
                            items: [
                              const DropdownMenuItem(
                                value: 'All Roles',
                                child: Text('All Roles'),
                              ),
                              ...uniqueRoles.map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              ),
                            ],
                            onChanged: _onFilterChanged,
                            underline: const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: IconButton(
                            splashRadius: 20,
                            onPressed: _refreshList,
                            icon: const Icon(Icons.refresh_outlined),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Roles list
                    _filteredRoles.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No roles found',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: _filteredRoles
                                .map(
                                  (r) => _RoleCard(
                                    role: r,
                                    onEdit: () => _openEdit(r),
                                    onDelete: () => _confirmDelete(r),
                                  ),
                                )
                                .toList(),
                          ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String countText;
  final Color bgColor;
  final IconData icon;
  const _StatCard({
    required this.title,
    required this.countText,
    required this.bgColor,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double w = (MediaQuery.of(context).size.width - 56) / 2;
    return Container(
      width: w < 160 ? (MediaQuery.of(context).size.width - 48) : w,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  countText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final RolePermissionModel role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RoleCard({
    required this.role,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textDark = const Color(0xFF1F1F1F);
    final displayPermissions = role.permissions.take(6).toList();
    final hasMore = role.permissions.length > 6;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.grey[700], size: 18),
              const SizedBox(width: 8),
              Text(
                role.role,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: const Color(0xFF7E57C2),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...displayPermissions.map(
                (p) => Chip(
                  label: Text(p, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              if (hasMore)
                Chip(
                  label: Text(
                    '+${role.permissions.length - 6} more',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${role.permissions.length} permissions',
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
