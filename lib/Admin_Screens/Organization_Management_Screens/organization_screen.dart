// screens/organization_management_screen.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/add_user_dialog.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/addorganization_dialog.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/organization_card.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/widgets/user_management.dart';
import 'package:gatecheck/Services/Admin_Services/organization_services.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

class OrganizationManagementScreen extends StatefulWidget {
  const OrganizationManagementScreen({super.key});

  @override
  State<OrganizationManagementScreen> createState() =>
      _OrganizationManagementScreenState();
}

class _OrganizationManagementScreenState
    extends State<OrganizationManagementScreen> {
  final OrganizationService _orgService = OrganizationService();
  List<Organization> _organizations = [];
  List<Organization> _filteredOrganizations = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Store user counts for each organization
  Map<String, int> _userCounts = {};
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  // -------------------- Load Organizations from API --------------------
  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _orgService.getAllOrganizations();

      debugPrint('📦 Response Status: ${response.statusCode}');
      debugPrint('📦 Response Data Type: ${response.data.runtimeType}');
      debugPrint('📦 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Parse the response based on your API structure
        List<Organization> loadedOrgs = [];
        
        if (data is Map && data.containsKey('data')) {
          final orgList = data['data'] as List;
          loadedOrgs = orgList.map((orgData) => _parseOrganization(orgData)).toList();
        } else if (data is List) {
          loadedOrgs = data.map((orgData) => _parseOrganization(orgData)).toList();
        }

        debugPrint('✅ Loaded ${loadedOrgs.length} organizations');

        setState(() {
          _organizations = loadedOrgs;
          _filteredOrganizations = loadedOrgs;
          _isLoading = false;
        });

        // Load user counts for all organizations
        await _loadUserCounts();
      } else {
        setState(() {
          _errorMessage = 'Failed to load organizations';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      setState(() {
        _errorMessage = _orgService.getErrorMessage(e);
        _isLoading = false;
      });
      _showErrorSnackBar(_errorMessage!);
    } catch (e) {
      debugPrint('❌ Exception: $e');
      setState(() {
        _errorMessage = 'Unexpected error occurred: $e';
        _isLoading = false;
      });
      _showErrorSnackBar(_errorMessage!);
    }
  }

  // -------------------- Load User Counts for All Organizations --------------------
  Future<void> _loadUserCounts() async {
    Map<String, int> counts = {};
    
    for (var org in _organizations) {
      try {
        final response = await _orgService.getUsers(org.id);
        
        if (response.statusCode == 200) {
          final data = response.data;
          int userCount = 0;
          
          if (data is List) {
            userCount = data.length;
          } else if (data is Map && data.containsKey('data')) {
            final userList = data['data'] as List;
            userCount = userList.length;
          }
          
          counts[org.id] = userCount;
          debugPrint('✅ Organization ${org.name} (${org.id}): $userCount users');
        }
      } catch (e) {
        debugPrint('❌ Error loading user count for org ${org.id}: $e');
        counts[org.id] = 0;
      }
    }
    
    setState(() {
      _userCounts = counts;
    });
  }

  // -------------------- Parse Organization from API Response --------------------
  Organization _parseOrganization(Map<String, dynamic> data) {
    debugPrint('🔍 Parsing organization: $data');
    
    final org = Organization(
      id: data['id']?.toString() ?? '',
      name: data['company_name']?.toString() ?? data['name']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      pinCode: data['pin_code']?.toString() ?? data['pincode']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      users: _parseUsers(data['users'] ?? []),
    );
    
    debugPrint('✅ Parsed: ${org.name} (${org.id})');
    return org;
  }

  // -------------------- Parse Users from API Response --------------------
  List<User> _parseUsers(dynamic usersData) {
    if (usersData is! List) return [];
    
    return usersData.map((userData) {
      return User(
        id: userData['id']?.toString() ?? '',
        name: userData['name']?.toString() ?? userData['username']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        mobileNumber: userData['mobile_number']?.toString() ?? userData['phone']?.toString() ?? '',
        companyName: userData['company_name']?.toString() ?? '',
        role: userData['role']?.toString() ?? '',
        block: userData['block']?.toString(),
        floor: userData['floor']?.toString(),
        dateAdded: userData['date_added'] != null 
            ? DateTime.tryParse(userData['date_added'].toString()) 
            : DateTime.now(),
      );
    }).toList();
  }

  // -------------------- Filter Organizations --------------------
  void _filterOrganizations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrganizations = _organizations;
      } else {
        _filteredOrganizations = _organizations
            .where(
              (org) =>
                  org.name.toLowerCase().contains(query.toLowerCase()) ||
                  org.location.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  // -------------------- Add Organization --------------------
  Future<void> _addOrganization(Organization org) async {
    try {
      _showLoadingDialog();

      final organizationData = {
        'company_name': org.name,
        'location': org.location,
        'pin_code': org.pinCode,
        'address': org.address,
      };

      final response = await _orgService.createOrganization(organizationData);

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar('Organization added successfully');
        await _loadOrganizations(); // Reload the list
      } else {
        _showErrorSnackBar('Failed to add organization');
      }
    } on DioException catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar(_orgService.getErrorMessage(e));
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Unexpected error occurred');
    }
  }

  // -------------------- Update Organization --------------------
  Future<void> _updateOrganization(Organization org) async {
    try {
      _showLoadingDialog();

      final organizationData = {
        'company_name': org.name,
        'location': org.location,
        'pin_code': org.pinCode,
        'address': org.address,
      };

      final response = await _orgService.updateOrganization(org.id, organizationData);

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Organization updated successfully');
        await _loadOrganizations(); // Reload the list
      } else {
        _showErrorSnackBar('Failed to update organization');
      }
    } on DioException catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar(_orgService.getErrorMessage(e));
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Unexpected error occurred');
    }
  }

  // -------------------- Delete Organization --------------------
  Future<void> _deleteOrganization(String id) async {
    try {
      _showLoadingDialog();

      final response = await _orgService.deleteOrganization(id);

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessSnackBar('Organization deleted successfully');
        await _loadOrganizations(); // Reload the list
      } else {
        _showErrorSnackBar('Failed to delete organization');
      }
    } on DioException catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar(_orgService.getErrorMessage(e));
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Unexpected error occurred');
    }
  }

  // -------------------- Add User to Organization --------------------
  Future<void> _addUserToOrganization(Organization org, User newUser, String companyId) async {
    try {
      _showLoadingDialog();

      final userData = {
        'name': newUser.name,
        'email': newUser.email,
        'mobile_number': newUser.mobileNumber,
        'company_name': org.name,
        'company_id': org.id,
        'company': companyId,
        'role': newUser.role,
        'block': newUser.block,
        'floor': newUser.floor,
      };

      final response = await _orgService.addUser(userData);

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar('User added successfully');
        await _loadOrganizations(); // Reload to get updated user list
      } else {
        _showErrorSnackBar('Failed to add user');
      }
    } on DioException catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar(_orgService.getErrorMessage(e));
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
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
                Text(
                  'Processing...',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
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
            Expanded(
              child: Text(message, style: GoogleFonts.poppins()),
            ),
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
            Expanded(
              child: Text(message, style: GoogleFonts.poppins()),
            ),
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
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: const Navigation(currentRoute: 'Organization',),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isSmallScreen
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Organization Management',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Manage organizations and members',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddOrganizationDialog(
                                      onAdd: _addOrganization,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 20),
                                label: Text(
                                  'Add Organization',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.purple,
                                  side: const BorderSide(color: Colors.purple),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.business,
                                color: Colors.white,
                                size: isMediumScreen ? 20 : 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Organization Management',
                                    style: GoogleFonts.poppins(
                                      fontSize: isMediumScreen ? 18 : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Manage your organizations and their members',
                                    style: GoogleFonts.poppins(
                                      fontSize: isMediumScreen ? 12 : 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddOrganizationDialog(
                                    onAdd: _addOrganization,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                'Add\nOrganization',
                                style: GoogleFonts.poppins(
                                  fontSize: isMediumScreen ? 11 : 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.purple,
                                side: const BorderSide(color: Colors.purple),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMediumScreen ? 12 : 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterOrganizations,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Search Organizations...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterOrganizations('');
                              },
                            )
                          : null,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: isSmallScreen ? 48 : 64,
                                  color: Colors.red[300],
                                ),
                                SizedBox(height: isSmallScreen ? 12 : 16),
                                Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isSmallScreen ? 12 : 16),
                                ElevatedButton.icon(
                                  onPressed: _loadOrganizations,
                                  icon: Icon(
                                    Icons.refresh,
                                    size: isSmallScreen ? 18 : 20,
                                  ),
                                  label: Text(
                                    'Retry',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 16 : 24,
                                      vertical: isSmallScreen ? 10 : 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _filteredOrganizations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    size: isSmallScreen ? 48 : 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: isSmallScreen ? 12 : 16),
                                  Text(
                                    'No organizations found',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadOrganizations,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 12 : 16,
                                ),
                                itemCount: _filteredOrganizations.length,
                                itemBuilder: (context, index) {
                                  final org = _filteredOrganizations[index];
                                  final userCount = _userCounts[org.id] ?? 0;
                                  
                                  return OrganizationCard(
                                    organization: org,
                                    userCount: userCount, // Pass the user count
                                    onEdit: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AddOrganizationDialog(
                                          organization: org,
                                          onAdd: _updateOrganization,
                                        ),
                                      );
                                    },
                                    onDelete: () => _showDeleteDialog(org),
                                    onAddUser: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AddUserDialog(
                                          companyName: org.name,
                                          companyId: org.id,
                                          onAdd: (newUser, companyId) {
                                            _addUserToOrganization(org, newUser, companyId);
                                          },
                                        ),
                                      );
                                    },
                                    onViewUsers: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserManagementScreen(
                                            organization: org,
                                            onUpdate: (updatedOrg) {
                                              _loadOrganizations();
                                            },
                                          ),
                                        ),
                                      );
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

  void _showDeleteDialog(Organization org) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: isSmallScreen ? 36 : 48,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              Text(
                'Delete Organization',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Are you sure you want to delete "${org.name}"? This action cannot be undone and will remove all associated data.',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
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
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteOrganization(org.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(
                        Icons.delete_outline,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}