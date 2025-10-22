// role_permissions_management.dart
// Full-screen, responsive Flutter implementation of the "Role Permissions Management" screen.
// Drop this file into your Flutter project's `lib/` folder and set as home in MaterialApp to preview.

import 'package:flutter/material.dart';
import 'package:gatecheck/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Dashboard_Screens/navigation_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class RolePermissionsScreen extends StatefulWidget {
  const RolePermissionsScreen({Key? key}) : super(key: key);

  @override
  State<RolePermissionsScreen> createState() => _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends State<RolePermissionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterValue = 'All Roles';
  List<RoleModel> _roles = List<RoleModel>.from(_mockRoles);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearchFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearchFilter() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty && (_filterValue == 'All Roles')) {
        _roles = List<RoleModel>.from(_mockRoles);
      } else {
        _roles = _mockRoles.where((r) {
          final matchesQuery = r.name.toLowerCase().contains(q);
          final matchesFilter =
              (_filterValue == 'All Roles') || r.category == _filterValue;
          return matchesQuery && matchesFilter;
        }).toList();
      }
    });
  }

  void _onFilterChanged(String? v) {
    if (v == null) return;
    setState(() => _filterValue = v);
    _applySearchFilter();
  }

  Future<void> _refreshList() async {
    // Placeholder for reloading from API.
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _roles = List<RoleModel>.from(_mockRoles);
      _searchController.clear();
      _filterValue = 'All Roles';
    });
  }

  void _openEdit(RoleModel role) {
    showDialog(
      context: context,
      builder: (_) => EditPermissionsDialog(role: role),
    );
  }

  void _confirmDelete(RoleModel role) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text(
          'Are you sure you want to delete the role "${role.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _mockRoles.remove(role));
              _applySearchFilter();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToAssign() {
    // Placeholder navigation - push a blank page.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AssignPermissionsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final primaryPurple = const Color(0xFF7E57C2);
    final textDark = const Color(0xFF1F1F1F);

    return Scaffold(
      appBar: CustomAppBar(userName: 'Admin', firstLetter: 'A'),
      drawer: Navigation(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final cardCrossAxisCount = maxWidth > 600
                ? 4
                : (maxWidth > 420 ? 2 : 2);

            return SingleChildScrollView(
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
                        countText: '3',
                        bgColor: const Color(0xFFEAF3FF),
                        icon: Icons.link,
                      ),
                      _StatCard(
                        title: 'Roles with Permissions',
                        countText: '3/3',
                        bgColor: const Color(0xFFF1E8FF),
                        icon: Icons.shield,
                      ),
                      _StatCard(
                        title: 'Available Permissions',
                        countText: '59',
                        bgColor: const Color(0xFFE8FBE8),
                        icon: Icons.vpn_key,
                      ),
                      _StatCard(
                        title: 'Avg Permissions/Role',
                        countText: '32.7',
                        bgColor: const Color(0xFFFFF2E2),
                        icon: Icons.people,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Search & filter row
                  Row(
                    children: [
                      // Search bar
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

                      // Dropdown
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
                          items: const [
                            DropdownMenuItem(
                              value: 'All Roles',
                              child: Text('All Roles'),
                            ),
                            DropdownMenuItem(
                              value: 'Admin',
                              child: Text('Admin'),
                            ),
                            DropdownMenuItem(
                              value: 'Editor',
                              child: Text('Editor'),
                            ),
                            DropdownMenuItem(
                              value: 'Viewer',
                              child: Text('Viewer'),
                            ),
                          ],
                          onChanged: _onFilterChanged,
                          underline: const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Refresh
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
                  Column(
                    children: _roles
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
            );
          },
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
    final double w =
        (MediaQuery.of(context).size.width - 56) /
        2; // approximate two-per-row spacing
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
  final RoleModel role;
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
              Row(
                children: [
                  Icon(Icons.shield, color: Colors.grey[700], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    role.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: textDark,
                    ),
                  ),
                ],
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
          // Permission chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                role.permissions
                    .take(6)
                    .map(
                      (p) => Chip(
                        label: Text(
                          p,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                    .toList()
                  ..add(
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
                  ),
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

class AssignPermissionsScreen extends StatelessWidget {
  const AssignPermissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Permissions'),
        backgroundColor: const Color(0xFF7E57C2),
      ),
      body: const Center(child: Text('Permission assignment form goes here')),
    );
  }
}

class EditPermissionsDialog extends StatelessWidget {
  final RoleModel role;
  const EditPermissionsDialog({required this.role, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Permissions',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Modify permissions for ${role.name}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: role.permissions
                  .take(8)
                  .map(
                    (p) => FilterChip(
                      label: Text(p),
                      selected: true,
                      onSelected: (_) {},
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// --- Mock data structures ---
class RoleModel {
  String name;
  String category;
  List<String> permissions;
  RoleModel({
    required this.name,
    required this.category,
    required this.permissions,
  });
}

final List<RoleModel> _mockRoles = [
  RoleModel(
    name: 'Administrator',
    category: 'Admin',
    permissions: [
      'View Users',
      'Edit Settings',
      'Manage Roles',
      'Delete Content',
      'Export Data',
      'Manage Billing',
      'Invite Users',
      'Configure SSO',
      'Audit Logs',
      'Advanced Settings',
    ],
  ),
  RoleModel(
    name: 'Editor',
    category: 'Editor',
    permissions: [
      'View Users',
      'Edit Content',
      'Publish Content',
      'Schedule Posts',
      'Comment Moderation',
      'Edit Settings',
    ],
  ),
  RoleModel(
    name: 'Viewer',
    category: 'Viewer',
    permissions: ['View Users', 'View Reports', 'Download Reports'],
  ),
];
