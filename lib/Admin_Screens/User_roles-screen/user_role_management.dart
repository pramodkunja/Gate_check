// user_roles_management.dart
// Full, responsive Flutter screen for "User Roles Management" with backend integration.

import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Services/Roles_services/user_roles_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

class UserRolesManagementScreen extends StatefulWidget {
  const UserRolesManagementScreen({super.key});

  @override
  State<UserRolesManagementScreen> createState() =>
      _UserRolesManagementScreenState();
}

class _UserRolesManagementScreenState extends State<UserRolesManagementScreen> {
  final Color primary = const Color(0xFF7E57C2);
  final Color secondaryText = const Color(0xFF757575);

  List<UserRoleModel> _allUsers = [];
  List<UserRoleModel> _visibleUsers = [];
  List<String> _availableRoles = [];

  String _selectedRole = 'All Roles';
  String _searchQuery = '';
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  final UserRoleService _userRoleService = UserRoleService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load user roles and available roles
      final userRoles = await _userRoleService.getAllUserRoles();
      final roles = await _userRoleService.getAvailableRoles();

      setState(() {
        _allUsers = userRoles;
        _availableRoles = ['All Roles', ...roles];
        _applyFilters();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _visibleUsers = _allUsers.where((u) {
        final matchesRole =
            _selectedRole == 'All Roles' || u.role == _selectedRole;
        final matchesSearch = u.user.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        return matchesRole && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String v) {
    _searchQuery = v;
    _applyFilters();
  }

  void _onRoleChanged(String? newRole) {
    if (newRole == null) return;
    _selectedRole = newRole;
    _applyFilters();
  }

  void _refresh() {
    _searchController.clear();
    _searchQuery = '';
    _selectedRole = 'All Roles';
    _loadData();
  }

  void _openEditDialog(UserRoleModel user) async {
    String tempRole = user.role;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Edit Role',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: DropdownButtonFormField<String>(
                value: tempRole,
                items: _availableRoles
                    .where((r) => r != 'All Roles')
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  setDialogState(() {
                    tempRole = v ?? tempRole;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempRole),
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result != user.role) {
      setState(() => _isLoading = true);

      try {
        await _userRoleService.updateUserRole(
          userRoleId: user.userRoleId,
          role: result,
        );

        _showSuccessSnackBar('Role updated successfully');
        _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to update role: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _openDeleteDialog(UserRoleModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete User Role',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete the role assignment for ${user.user}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await _userRoleService.deleteUserRole(user.userRoleId);
        _showSuccessSnackBar('User role deleted successfully');
        _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to delete role: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _openAssignRoleDialog() async {
    final nameController = TextEditingController();
    String selectedRole = _availableRoles.length > 1
        ? _availableRoles[1]
        : 'employee';

    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Assign Role',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: _availableRoles
                        .where((r) => r != 'All Roles')
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        selectedRole = v ?? selectedRole;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a user name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, {
                      'user': nameController.text.trim(),
                      'role': selectedRole,
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  child: Text(
                    'Assign',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _isLoading = true);

      try {
        await _userRoleService.createUserRole(
          user: result['user']!,
          role: result['role']!,
        );

        _showSuccessSnackBar('Role assigned successfully');
        _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to assign role: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Map<String, int> _calculateStats() {
    final uniqueUsers = _allUsers.map((u) => u.user).toSet().length;
    final uniqueRoles = _allUsers.map((u) => u.role).toSet().length;
    final totalAssignments = _allUsers.length;

    return {
      'users': uniqueUsers,
      'roles': uniqueRoles,
      'assignments': totalAssignments,
    };
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 600;
    final stats = _calculateStats();

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: Navigation(),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'User Roles Management',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _openAssignRoleDialog,
                                  icon: const Icon(
                                    Icons.add,
                                    color: Color(0xFF7E57C2),
                                  ),
                                  label: Text(
                                    'Assign Role',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF7E57C2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: const BorderSide(
                                        color: Color(0xFF7E57C2),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Assign roles to users',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Statistics cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = isWide
                          ? (constraints.maxWidth - 32) / 3
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatCard(
                            'Total Users',
                            '${stats['users']}',
                            Icons.person,
                            cardWidth,
                          ),
                          _buildStatCard(
                            'Total Roles',
                            '${stats['roles']}',
                            Icons.lock,
                            cardWidth,
                          ),
                          _buildStatCard(
                            'Total Assignments',
                            '${stats['assignments']}',
                            Icons.badge,
                            cardWidth,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Search & Filter row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 600;
                      return Column(
                        children: [
                          wide
                              ? Row(
                                  children: [
                                    Expanded(child: _buildSearchField()),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 180,
                                      child: _buildRoleDropdown(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: _isLoading ? null : _refresh,
                                      icon: const Icon(Icons.refresh),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildSearchField(),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(child: _buildRoleDropdown()),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _refresh,
                                          icon: const Icon(Icons.refresh),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'USER',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'ROLE',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'ACTIONS',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // List
                  _visibleUsers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No users found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _visibleUsers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final u = _visibleUsers[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          child: Text(
                                            u.user
                                                .split(' ')
                                                .map(
                                                  (e) =>
                                                      e.isNotEmpty ? e[0] : '',
                                                )
                                                .take(2)
                                                .join()
                                                .toUpperCase(),
                                          ),
                                          backgroundColor: primary.withOpacity(
                                            0.12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            u.user,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      u.role,
                                      style: GoogleFonts.poppins(
                                        color: secondaryText,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Wrap(
                                      alignment: WrapAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => _openEditDialog(u),
                                          icon: const Icon(Icons.edit),
                                          color: primary,
                                        ),
                                        IconButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => _openDeleteDialog(u),
                                          icon: const Icon(Icons.delete),
                                          color: Colors.redAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDFF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF7E57C2)),
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
                      color: const Color(0xFF7E57C2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count,
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
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: 'Search users...',
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: _availableRoles
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: _isLoading ? null : _onRoleChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
