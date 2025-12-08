// user_roles_management.dart
// Responsive, full-featured User Roles Management screen.
// Uses role_id when calling APIs, displays role name in UI.

import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Admin_Screens/User_roles-screen/user_role_model.dart';
import 'package:gatecheck/Services/User_roles_services/user_roles_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/widgets/common_search_bar.dart';

class UserRolesManagementScreen extends StatefulWidget {
  const UserRolesManagementScreen({super.key});

  @override
  State<UserRolesManagementScreen> createState() =>
      _UserRolesManagementScreenState();
}

class _UserRolesManagementScreenState extends State<UserRolesManagementScreen> {
  final Color primary = const Color(0xFF7E57C2);
  final Color secondaryText = const Color(0xFF757575);

  final UserRoleService _userRoleService = UserRoleService();

  List<UserRoleModel> _allUsers = [];
  List<UserRoleModel> _visibleUsers = [];

  /// Available roles as maps: { 'id': int, 'name': String }
  List<Map<String, dynamic>> _availableRoles = [];

  /// Selected role id for filtering. 0 == All Roles
  int _selectedRoleId = 0;

  String _searchQuery = '';
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();

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

  // ------------------ Data Loading ------------------
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userRoles = await _userRoleService.getAllUserRoles();
      final rolesRaw = await _userRoleService.getAvailableRoles();
      // rolesRaw expected to be a List of maps from service like:
      // [{ 'role_id': 1, 'name': 'Admin' }, ...]

      // Normalize roles into List<Map<String, dynamic>> {id, name}
      final normalizedRoles = <Map<String, dynamic>>[];
      try {
        // ignore: unnecessary_type_check
        if (rolesRaw is List) {
          for (var item in rolesRaw) {
            // ignore: unnecessary_type_check
            if (item is Map<String, dynamic>) {
              final id = (item['role_id'] ?? item['id']) is int
                  ? (item['role_id'] ?? item['id'])
                  : int.tryParse((item['role_id'] ?? item['id']).toString());
              final name = (item['name'] ?? item['role_name'] ?? '').toString();
              if (id != null && name.isNotEmpty) {
                normalizedRoles.add({'id': id, 'name': name});
              }
            } else if (item is String) {
              // If service returned names only, try to handle gracefully
              normalizedRoles.add({'id': null, 'name': item});
            }
          }
        }
      } catch (e) {
        // fallback empty
      }

      setState(() {
        _allUsers = userRoles;
        _availableRoles = [
          {'id': 0, 'name': 'All Roles'},
          ...normalizedRoles,
        ];
        _applyFilters();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ------------------ Filtering ------------------
  void _applyFilters() {
    String? selectedRoleName;
    if (_selectedRoleId != 0) {
      final roleMap = _availableRoles.firstWhere(
        (r) => r['id'] == _selectedRoleId,
        orElse: () => {},
      );
      selectedRoleName = roleMap['name']?.toString();
    }

    setState(() {
      _visibleUsers = _allUsers.where((u) {
        final matchesRole =
            (_selectedRoleId == 0) ||
            (selectedRoleName != null && u.rolename == selectedRoleName);
        final matchesSearch = u.username.toLowerCase().contains(
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

  void _refresh() {
    _searchController.clear();
    _searchQuery = '';
    _selectedRoleId = 0;
    _loadData();
  }

  // Helper to find role name from id
  String? _getRoleNameById(int id) {
    try {
      final m = _availableRoles.firstWhere(
        (r) => r['id'] == id,
        orElse: () => {},
      );
      return m.isNotEmpty ? m['name']?.toString() : null;
    } catch (_) {
      return null;
    }
  }

  // Helper to find role id by name (returns null if not found)
  int? _getRoleIdByName(String name) {
    try {
      final m = _availableRoles.firstWhere(
        (r) => r['name']?.toString().toLowerCase() == name.toLowerCase(),
      );
      return m['id'] is int ? m['id'] as int : int.tryParse(m['id'].toString());
    } catch (_) {
      return null;
    }
  }

  // ------------------ Edit Role Dialog ------------------
  void _openEditDialog(UserRoleModel user) async {
    // find current role id from user's role name
    int currentRoleId = _getRoleIdByName(user.rolename) ?? 0;
    int tempRoleId = currentRoleId == 0
        ? (_availableRoles.length > 1 ? _availableRoles[1]['id'] ?? 0 : 0)
        : currentRoleId;

    final selected = await showDialog<int?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Edit Role',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: DropdownButtonFormField<int>(
                initialValue: tempRoleId != 0 ? tempRoleId : null,
                items: _availableRoles
                    .where((r) => r['id'] != 0)
                    .map(
                      (r) => DropdownMenuItem<int>(
                        value: r['id'] as int,
                        child: Text(r['name'].toString()),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setDialogState(() {
                    tempRoleId = v ?? tempRoleId;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                isExpanded: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempRoleId),
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

    if (selected != null && selected != currentRoleId) {
      setState(() => _isLoading = true);
      try {
        await _userRoleService.updateUserRole(
          userRoleId: user.userRoleId,
          userId: user.username,
          user: user.username, // existing username
          roleId: selected,
          role: _getRoleNameById(selected) ?? '',
        );

        _showSuccessSnackBar('Role updated successfully');
        await _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to update role: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  // ------------------ Delete Role ------------------
  void _openDeleteDialog(UserRoleModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete User Role',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete the role assignment for ${user.username}?',
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
        await _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to delete role: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  // ------------------ Assign Role Dialog ------------------
  void _openAssignRoleDialog() async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> backendUsers = [];
    try {
      backendUsers = await _userRoleService.getAllUsers();
    } catch (e) {
      _showErrorSnackBar('Failed to load users: $e');
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (backendUsers.isEmpty) {
      _showErrorSnackBar('No users available to assign roles.');
      return;
    }

    // ✅ Filter out users who already have role assignments
    final assignedUserIds = _allUsers.map((u) => u.userId).toSet();

    final availableUsers = backendUsers.where((user) {
      final userId = int.tryParse(user['id']?.toString() ?? '');
      return userId != null && !assignedUserIds.contains(userId);
    }).toList();

    // ✅ Check if there are any available users after filtering
    if (availableUsers.isEmpty) {
      _showErrorSnackBar('All users have already been assigned roles.');
      return;
    }

    int? selectedUserId;
    int selectedRoleId = _availableRoles.length > 1
        ? (_availableRoles[1]['id'] ?? 0) as int
        : 0;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Assign Role',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedUserId,
                      hint: Text('Select User', style: GoogleFonts.poppins()),
                      items: availableUsers.map((u) {
                        // ✅ Use availableUsers instead of backendUsers
                        return DropdownMenuItem<int>(
                          value: int.tryParse(u['id']?.toString() ?? ''),
                          child: Text(
                            u['username']?.toString() ??
                                u['email']?.toString() ??
                                'Unknown User',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedUserId = v),
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedRoleId != 0 ? selectedRoleId : null,
                      hint: Text('Select Role', style: GoogleFonts.poppins()),
                      items: _availableRoles
                          .where((r) => r['id'] != 0)
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: r['id'] as int,
                              child: Text(r['name'].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(
                        () => selectedRoleId = v ?? selectedRoleId,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a user'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (selectedRoleId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a role'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final selectedUser = availableUsers.firstWhere(
                      // ✅ Use availableUsers
                      (u) => int.tryParse(u['id'].toString()) == selectedUserId,
                    );

                    final selectedRole = _availableRoles.firstWhere(
                      (r) => r['id'] == selectedRoleId,
                    );

                    Navigator.pop(context, {
                      'userId': selectedUserId,
                      'userName': selectedUser['username'] ?? '',
                      'roleId': selectedRoleId,
                      'roleName': selectedRole['name'] ?? '',
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
          userId: result['userId'],
          roleId: result['roleId'],
          user: result['userName'],
          role: result['roleName'],
        );

        _showSuccessSnackBar('Role assigned successfully');
        await _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to assign role: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  // ------------------ UI Helpers ------------------
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Map<String, int> _calculateStats() {
    final uniqueUsers = _allUsers.map((u) => u.username).toSet().length;
    final uniqueRoles = _allUsers.map((u) => u.rolename).toSet().length;
    return {
      'users': uniqueUsers,
      'roles': uniqueRoles,
      'assignments': _allUsers.length,
    };
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 720;
    final stats = _calculateStats();

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: Navigation(currentRoute: 'User Roles'),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header
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

                  // stat cards
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

                  // search & filter
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wideRow = constraints.maxWidth > 600;
                      return Column(
                        children: [
                          wideRow
                              ? Row(
                                  children: [
                                    Expanded(child: _buildSearchField()),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 220,
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

                  // header row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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

                  // list
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
                                          backgroundColor: primary.withOpacity(
                                            0.12,
                                          ),
                                          child: Text(
                                            u.username
                                                .split(' ')
                                                .map(
                                                  (e) =>
                                                      e.isNotEmpty ? e[0] : '',
                                                )
                                                .take(2)
                                                .join()
                                                .toUpperCase(),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            u.username,
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
                                      u.rolename,
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

            // loading overlay
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

  // small widgets
  Widget _buildStatCard(
    String title,
    String value,
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
            BoxShadow(color: Colors.black12.withOpacity(0.03), blurRadius: 6),
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
              child: Icon(icon, size: 20, color: primary),
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
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
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
    return CommonSearchBar(
      controller: _searchController,
      onChanged: _onSearchChanged,
      hintText: 'Search users...',
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedRoleId,
      items: _availableRoles.map((r) {
        return DropdownMenuItem<int>(
          value: r['id'] as int,
          child: Text(r['name'].toString()),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedRoleId = value;
          _applyFilters();
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
