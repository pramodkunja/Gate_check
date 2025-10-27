// user_roles_management.dart
// Full, responsive Flutter screen for "User Roles Management".
// Requirements implemented: Poppins font, responsive layout, search, filter, refresh,
// edit/delete dialogs, assign role dialog, transparent appbar, stats cards, and table-like list.

import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class UserRole {
  String name;
  String role;
  UserRole({required this.name, required this.role});
}

class UserRolesManagementScreen extends StatefulWidget {
  const UserRolesManagementScreen({super.key});

  @override
  State<UserRolesManagementScreen> createState() =>
      _UserRolesManagementScreenState();
}

class _UserRolesManagementScreenState extends State<UserRolesManagementScreen> {
  final Color primary = const Color(0xFF7E57C2);
  final Color secondaryText = const Color(0xFF757575);

  List<UserRole> _allUsers = [];
  List<UserRole> _visibleUsers = [];
  final List<String> _roles = [
    'All Roles',
    'Employee',
    'Security Guard',
    'Admin',
  ];

  String _selectedRole = 'All Roles';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetData();
  }

  void _resetData() {
    _allUsers = [
      UserRole(name: 'Alice Johnson', role: 'Employee'),
      UserRole(name: 'Bob Martin', role: 'Security Guard'),
      UserRole(name: 'Cathy\nAdams', role: 'Admin'),
      UserRole(name: 'David Lee', role: 'Employee'),
      UserRole(name: 'Emily Davis', role: 'Employee'),
      UserRole(name: 'Frank Wu', role: 'Security Guard'),
    ];
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _visibleUsers = _allUsers.where((u) {
        final matchesRole =
            _selectedRole == 'All Roles' || u.role == _selectedRole;
        final matchesSearch = u.name.toLowerCase().contains(
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
    _resetData();
  }

  void _openEditDialog(UserRole user) async {
    final result = await showDialog<UserRole?>(
      context: context,
      builder: (context) {
        String tempRole = user.role;
        return AlertDialog(
          title: Text(
            'Edit Role',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: DropdownButtonFormField<String>(
            value: tempRole,
            items: _roles
                .where((r) => r != 'All Roles')
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => tempRole = v ?? tempRole,
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
              onPressed: () {
                Navigator.pop(
                  context,
                  UserRole(name: user.name, role: tempRole),
                );
              },
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

    if (result != null) {
      setState(() {
        final idx = _allUsers.indexWhere((u) => u.name == user.name);
        if (idx != -1) _allUsers[idx].role = result.role;
        _applyFilters();
      });
    }
  }

  void _openDeleteDialog(UserRole user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete User',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete ${user.name}?',
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
      setState(() {
        _allUsers.removeWhere((u) => u.name == user.name);
        _applyFilters();
      });
    }
  }

  void _openAssignRoleDialog() async {
    final nameController = TextEditingController();
    String selected = _roles[1];

    final created = await showDialog<UserRole?>(
      context: context,
      builder: (context) => AlertDialog(
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
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selected,
              items: _roles
                  .where((r) => r != 'All Roles')
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => selected = v ?? selected,
              decoration: InputDecoration(border: OutlineInputBorder()),
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
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                UserRole(name: nameController.text.trim(), role: selected),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            child: Text(
              'Assign',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (created != null) {
      setState(() {
        _allUsers.add(created);
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 600;
    final padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return Scaffold(
      appBar: CustomAppBar(userName: 'Admin', firstLetter: 'A'),
      drawer: Navigation(),
      //backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                        // Title and button in same row
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
                              onPressed: _openAssignRoleDialog,
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

              // Statistics cards - responsive
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
                        '15',
                        Icons.person,
                        cardWidth,
                      ),
                      _buildStatCard('Total Roles', '3', Icons.lock, cardWidth),
                      _buildStatCard(
                        'Total User Roles',
                        '6',
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
                                  onPressed: _refresh,
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
                                      onPressed: _refresh,
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
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'ROLE',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'ACTIONS',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _visibleUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                                  u.name
                                      .split(' ')
                                      .map((e) => e.isNotEmpty ? e[0] : '')
                                      .take(2)
                                      .join(),
                                ),
                                backgroundColor: primary.withOpacity(0.12),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  u.name,
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
                            style: GoogleFonts.poppins(color: secondaryText),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => _openEditDialog(u),
                                icon: const Icon(Icons.edit),
                                color: primary,
                              ),
                              IconButton(
                                onPressed: () => _openDeleteDialog(u),
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
      items: _roles
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: _onRoleChanged,
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
