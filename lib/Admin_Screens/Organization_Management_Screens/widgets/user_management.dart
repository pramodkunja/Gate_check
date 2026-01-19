// screens/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/add_user_dialog.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/edit_user_dialog.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/user_detail_dialog.dart';
import 'package:gatecheck/Services/Admin_Services/organization_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../widgets/user_card.dart';
import 'package:gatecheck/widgets/common_search_bar.dart';

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
  final OrganizationService _orgService = OrganizationService();

  late Organization _organization;
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _organization = widget.organization;
    _loadUsers();
  }

  // -------------------- Load Users from API --------------------
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _orgService.getUsers(_organization.id);

      debugPrint('📦 Users Response Status: ${response.statusCode}');
      debugPrint('📦 Users Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        List<User> loadedUsers = [];

        // Handle different response formats
        if (data is Map && data.containsKey('data')) {
          final userList = data['data'] as List;
          loadedUsers = userList
              .map((userData) => _parseUser(userData))
              .toList();
        } else if (data is List) {
          loadedUsers = data.map((userData) => _parseUser(userData)).toList();
        }

        debugPrint(
          '✅ Loaded ${loadedUsers.length} users for ${_organization.name}',
        );

        setState(() {
          _organization.users = loadedUsers;
          _filteredUsers = loadedUsers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load users';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      debugPrint('❌ Load users error: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      setState(() {
        _errorMessage = _orgService.getErrorMessage(e);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      setState(() {
        _errorMessage = 'Unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // -------------------- Parse User from API Response --------------------
  User _parseUser(Map<String, dynamic> data) {
    debugPrint('🔍 Parsing user: $data');

    // Parse roles array - take first role if exists, otherwise empty string
    String role = '';
    if (data['roles'] != null &&
        data['roles'] is List &&
        (data['roles'] as List).isNotEmpty) {
      role = (data['roles'] as List).first.toString();
    }

    return User(
      id: data['id']?.toString() ?? '',
      username:
          data['username']?.toString() ??
          data['alias_name']?.toString() ??
          data['name']?.toString() ??
          '',
      email: data['email']?.toString() ?? '',
      mobileNumber: data['mobile_number']?.toString() ?? '',
      companyName: data['company_name']?.toString() ?? _organization.name,
      role: role,
      block: data['block']?.toString() ?? '',
      floor: data['floor']?.toString() ?? '',
      isActive: data['is_active'] ?? data['isActive'] ?? true,
      dateAdded: data['date_added'] != null || data['created_at'] != null
          ? DateTime.tryParse(
                  (data['date_added'] ?? data['created_at']).toString(),
                ) ??
                DateTime.now()
          : DateTime.now(),
    );
  }

  // -------------------- Filter Users --------------------
  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _organization.users;
      } else {
        _filteredUsers = _organization.users
            .where(
              (user) =>
                  user.username.toLowerCase().contains(query.toLowerCase()) ||
                  user.email.toLowerCase().contains(query.toLowerCase()) ||
                  user.mobileNumber.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  // -------------------- Add User --------------------
  Future<void> _addUser(User user, String companyId) async {
    try {
      _showLoadingDialog();

      final userData = {
        'username': user.username,
        'email': user.email,
        'mobile_number': user.mobileNumber,
        'company': companyId, // required field key
        'company_name': _organization.name, // optional but still included
        'alias_name': user.aliasName ?? '',
        'roles': user.role.isNotEmpty ? [user.role] : [],
        'block': user.block ?? '',
        'floor': user.floor ?? '',
      };

      debugPrint('📤 Adding user to API: $userData');

      final response = await _orgService.addUser(userData);

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        String successMessage = 'User added successfully';
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            successMessage = responseData['message'].toString();
          }
          if (responseData.containsKey('user_id')) {
            final userId = responseData['user_id'].toString();
            debugPrint('✅ Created user ID: $userId');
          }
        }
        _showSuccessSnackBar(successMessage);
        await _loadUsers(); // Reload users
        widget.onUpdate(_organization);
      } else {
        _showErrorSnackBar('Failed to add user');
      }
    } on DioException catch (e) {
      Navigator.pop(context);
      debugPrint('❌ Add user error: ${e.response?.data}');
      _showErrorSnackBar(_orgService.getErrorMessage(e));
    } catch (e) {
      Navigator.pop(context);
      debugPrint('❌ Unexpected error: $e');
      _showErrorSnackBar('Unexpected error occurred');
    }
  }

  // -------------------- Update User --------------------
  Future<void> _updateUser(User user) async {
    try {
      _showLoadingDialog();

      final userData = {
        'username': user.username,
        'email': user.email,
        'mobile_number': user.mobileNumber,
        'company_name': _organization.name,
        'company_id': _organization.id,
        'alias_name': user.username,
        'roles': user.role.isNotEmpty ? [user.role] : [],
        'block': user.block ?? '',
        'floor': user.floor ?? '',
        'is_active': user.isActive,
      };

      debugPrint('📤 Updating user ${user.id}: $userData');

      final response = await _orgService.updateUser(user.id, userData);

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        _showSuccessSnackBar('User updated successfully');
        await _loadUsers(); // Reload users
        widget.onUpdate(_organization);
      } else {
        _showErrorSnackBar('Failed to update user');
      }
    } on DioException catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(_orgService.getErrorMessage(e));
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Unexpected error occurred');
    }
  }

  // -------------------- Delete User --------------------
  Future<void> _deleteUser(String userId) async {
    try {
      _showLoadingDialog();

      debugPrint('🗑️ Deleting user: $userId');

      final response = await _orgService.deleteUser(userId);

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessSnackBar('User deleted successfully');
        await _loadUsers(); // Reload users
        widget.onUpdate(_organization);
      } else {
        _showErrorSnackBar('Failed to delete user');
      }
    } on DioException catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(_orgService.getErrorMessage(e));
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Unexpected error occurred');
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Processing...', style: GoogleFonts.poppins(fontSize: 14)),
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
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: GoogleFonts.poppins()),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
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
                      onPressed: _isLoading
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => AddUserDialog(
                                  companyName: _organization.name,
                                  companyId: _organization.id,
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
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.1),
            //         blurRadius: 4,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.all(8),
            //         decoration: BoxDecoration(
            //           color: Colors.purple.withOpacity(0.1),
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: const Icon(Icons.business, color: Colors.purple),
            //       ),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: Text(
            //           _organization.name,
            //           style: GoogleFonts.poppins(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //           ),
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //       ),
            //       const SizedBox(width: 8),
            //       Flexible(
            //         child: Text(
            //           '${_organization.users.length} ${isSmallScreen ? 'Users' : 'Total Users'}',
            //           style: GoogleFonts.poppins(
            //             fontSize: 14,
            //             color: Colors.grey[600],
            //           ),
            //           textAlign: TextAlign.end,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Users',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!_isLoading)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadUsers,
                          tooltip: 'Refresh',
                        ),
                    ],
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
                  CommonSearchBar(
                    controller: _searchController,
                    hintText: 'Search by name or email...',
                    onChanged: _filterUsers,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading users...'),
                        ],
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadUsers,
                            icon: const Icon(Icons.refresh),
                            label: Text('Retry', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredUsers.isEmpty
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
                          if (_organization.users.isEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddUserDialog(
                                    companyName: _organization.name,
                                    companyId: _organization.id,
                                    onAdd: _addUser,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: Text(
                                'Add First User',
                                style: GoogleFonts.poppins(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
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
                              text: user.username,
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
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                child: isVerySmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteUser(user.id);
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
                              Navigator.pop(context);
                              _deleteUser(user.id);
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
