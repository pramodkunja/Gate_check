// edit_permissions_dialog.dart - FIXED VERSION

import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Roles_permission_services/role_permissions_service.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPermissionsDialog extends StatefulWidget {
  final RolePermissionModel role;
  final VoidCallback onUpdate;

  const EditPermissionsDialog({
    required this.role,
    required this.onUpdate,
    super.key,
  });

  @override
  State<EditPermissionsDialog> createState() => _EditPermissionsDialogState();
}

class _EditPermissionsDialogState extends State<EditPermissionsDialog> {
  final RolePermissionsApiService _apiService = RolePermissionsApiService();

  // ✅ Store permission NAMES (strings) since backend uses names
  late Set<String> selectedPermissionNames;

  // ✅ Dynamic permissions from backend
  List<Map<String, dynamic>> allPermissions = [];
  List<Map<String, dynamic>> allRoles = []; // ✅ Store all roles to get IDs

  bool _isSubmitting = false;
  bool _isLoadingPermissions = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize with current role permission NAMES (not IDs)
    selectedPermissionNames = Set<String>.from(widget.role.permissions);
    debugPrint('🔍 Initial selected permissions: $selectedPermissionNames');
    _loadAllPermissions();
    _loadAllRoles(); // ✅ Load roles to get proper IDs
  }

  // ✅ Load all roles to get the correct role ID
  Future<void> _loadAllRoles() async {
    try {
      allRoles = await _apiService.getAllRoles();
      debugPrint('✅ Loaded ${allRoles.length} roles');
    } catch (e) {
      debugPrint('⚠️ Could not fetch roles: $e');
      // Continue anyway - we might still have roleId from widget.role
    }
  }

  // ✅ Fetch all available permissions from backend
  Future<void> _loadAllPermissions() async {
    setState(() {
      _isLoadingPermissions = true;
      _errorMessage = null;
    });

    try {
      List<Map<String, dynamic>> permissions = [];

      try {
        permissions = await _apiService.getAllPermissions();
      } catch (e) {
        debugPrint('⚠️ Could not fetch from permissions endpoint: $e');
        
        // Fallback: Extract unique permissions from all roles
        final allRoles = await _apiService.getRolePermissions();
        final uniquePerms = <String>{};
        
        for (var role in allRoles) {
          uniquePerms.addAll(role.permissions);
        }
        
        // Convert to expected format
        permissions = uniquePerms.map((name) => {
          'id': name.hashCode, // Generate a consistent ID from name
          'name': name,
        }).toList();
        
        debugPrint('✅ Extracted ${permissions.length} unique permissions from roles');
      }

      setState(() {
        allPermissions = permissions;
        _isLoadingPermissions = false;
      });

      debugPrint('✅ Loaded ${allPermissions.length} permissions');
      debugPrint('✅ Currently selected: $selectedPermissionNames');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load permissions: $e';
        _isLoadingPermissions = false;
      });
      debugPrint('❌ Error loading permissions: $e');
    }
  }

  void _togglePermission(String permissionName) {
    setState(() {
      if (selectedPermissionNames.contains(permissionName)) {
        selectedPermissionNames.remove(permissionName);
      } else {
        selectedPermissionNames.add(permissionName);
      }
    });
    debugPrint('📝 Selected permissions: $selectedPermissionNames');
  }

  void _toggleSelectAll() {
    setState(() {
      if (isAllSelected) {
        selectedPermissionNames.clear();
      } else {
        selectedPermissionNames.clear();
        selectedPermissionNames.addAll(
          allPermissions.map((p) => p['name'] as String)
        );
      }
    });
  }

  bool get isAllSelected =>
      selectedPermissionNames.length == allPermissions.length;

  Future<void> _savePermissions() async {
    if (selectedPermissionNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one permission'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      debugPrint('💾 Saving permissions: $selectedPermissionNames');
      
      // ✅ Convert permission NAMES to IDs before sending
      final selectedPermissionIds = <int>[];
      for (var name in selectedPermissionNames) {
        final permission = allPermissions.firstWhere(
          (p) => p['name'] == name,
          orElse: () => {'id': 0, 'name': ''},
        );
        if (permission['id'] != 0) {
          selectedPermissionIds.add(permission['id'] as int);
        }
      }
      
      debugPrint('📤 Sending permission IDs: $selectedPermissionIds');
      debugPrint('📤 Sending role ID: ${widget.role.roleId}');
      
      // ✅ Send permission IDs (integers) to backend
      final success = await _apiService.updatePermissions(
        rolePermissionId: widget.role.rolePermissionId,
        roleId: widget.role.roleId,
        permissions: selectedPermissionIds,
        role: widget.role.role,
      );

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permissions updated for ${widget.role.role}'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onUpdate();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update permissions. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 40,
        vertical: isSmallScreen ? 24 : 40,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Permissions',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: _isLoadingPermissions
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAllPermissions,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Section
                          Row(
                            children: [
                              const Icon(
                                Icons.radio_button_checked,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Role',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Role Display (non-editable)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shield,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.role.role,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Permissions Section
                          Row(
                            children: [
                              const Icon(
                                Icons.vpn_key,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Permissions',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : _toggleSelectAll,
                                child: Text(
                                  isAllSelected ? 'Deselect All' : 'Select All',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF7E57C2),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ✅ Dynamic Permissions List with NAMES
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: allPermissions.isEmpty
                                ? Center(
                                    child: Text(
                                      'No permissions available',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: allPermissions.length,
                                    itemBuilder: (context, index) {
                                      final permission = allPermissions[index];
                                      final permName = permission['name'] as String;
                                      
                                      // ✅ Check if permission NAME is selected
                                      final isSelected = selectedPermissionNames.contains(permName);

                                      return CheckboxListTile(
                                        value: isSelected,
                                        onChanged: _isSubmitting
                                            ? null
                                            : (_) => _togglePermission(permName),
                                        title: Text(
                                          permName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                        dense: true,
                                      );
                                    },
                                  ),
                          ),

                          const SizedBox(height: 12),

                          // Selection counter
                          Text(
                            '${selectedPermissionNames.length} of ${allPermissions.length} permissions selected',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const Divider(height: 1),

            // Footer Buttons
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting || _isLoadingPermissions
                        ? null
                        : _savePermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Update Permissions',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
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
}