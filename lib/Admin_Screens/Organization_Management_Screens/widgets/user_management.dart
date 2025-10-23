// screens/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/add_user_dialog.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/edit_user_dialog.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/user_detail_dialog.dart';

import 'package:google_fonts/google_fonts.dart';
import '../widgets/user_card.dart';

class UserManagementScreen extends StatefulWidget {
  final Organization organization;
  final Function(Organization) onUpdate;

  const UserManagementScreen({
    super.key,
    required this.organization,
    required this.onUpdate,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Organization _organization;
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _organization = widget.organization;
    _filteredUsers = _organization.users;
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _organization.users;
      } else {
        _filteredUsers = _organization.users
            .where(
              (user) =>
                  user.name.toLowerCase().contains(query.toLowerCase()) ||
                  user.email.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _addUser(User user) {
    setState(() {
      _organization.users.add(user);
      _filteredUsers = _organization.users;
    });
    widget.onUpdate(_organization);
  }

  void _updateUser(User user) {
    setState(() {
      final index = _organization.users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _organization.users[index] = user;
        _filteredUsers = _organization.users;
      }
    });
    widget.onUpdate(_organization);
  }

  void _deleteUser(String userId) {
    setState(() {
      _organization.users.removeWhere((u) => u.id == userId);
      _filteredUsers = _organization.users;
    });
    widget.onUpdate(_organization);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Back to Organizations', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Management',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_organization.name} - ${_organization.users.length} users',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddUserDialog(
                            companyName: _organization.name,
                            onAdd: _addUser,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text('Add User', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _organization.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${_organization.users.length} ${isSmallScreen ? 'Users' : 'Total Users'}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and view all users in this organization (${_organization.users.length} total)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterUsers,
                    style: GoogleFonts.poppins(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: GoogleFonts.poppins(fontSize: 16),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterUsers('');
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _organization.users.isEmpty
                                ? 'No users added yet'
                                : 'No users found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                      ),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return UserCard(
                          user: user,
                          onView: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  UserDetailsDialog(user: user),
                            );
                          },
                          onEdit: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditUserDialog(
                                user: user,
                                onUpdate: _updateUser,
                              ),
                            );
                          },
                          onDelete: () {
                            _showDeleteConfirmationDialog(context, user);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, User user) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 40,
          vertical: 24,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? double.infinity : 500,
            maxHeight: screenSize.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Confirm Delete',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              isVerySmallScreen ? 10 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                              size: isVerySmallScreen ? 20 : 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delete User',
                                  style: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'This action cannot be undone',
                                  style: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 12 : 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: isVerySmallScreen ? 13 : 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Are you sure you want to delete ',
                            ),
                            TextSpan(
                              text: user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '? This will permanently remove the user from the organization and cannot be undone.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.red,
                                  size: isVerySmallScreen ? 18 : 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Warning',
                                  style: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 13 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isVerySmallScreen ? 8 : 12),
                            Text(
                              'This action will:',
                              style: GoogleFonts.poppins(
                                fontSize: isVerySmallScreen ? 12 : 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[900],
                              ),
                            ),
                            SizedBox(height: isVerySmallScreen ? 6 : 8),
                            _buildWarningItem(
                              'Remove the user from this organization',
                              isVerySmallScreen,
                            ),
                            _buildWarningItem(
                              'Delete all associated user data',
                              isVerySmallScreen,
                            ),
                            _buildWarningItem(
                              'Cannot be reversed',
                              isVerySmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                child: isVerySmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _deleteUser(user.id);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: Colors.red,
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            label: Text(
                              'Delete User',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              _deleteUser(user.id);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            label: Text(
                              'Delete User',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text, bool isVerySmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: isVerySmallScreen ? 12 : 13,
              color: Colors.red[900],
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: isVerySmallScreen ? 12 : 13,
                color: Colors.red[900],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
