// edit_permissions_dialog.dart

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

  // ✅ Changed to store permission IDs instead of names
  late Set<int> selectedPermissionIds;

  // ✅ Dynamic permissions from backend
  List<Map<String, dynamic>> allPermissions = [];

  bool _isSubmitting = false;
  bool _isLoadingPermissions = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize with current role permission IDs
    selectedPermissionIds = Set<int>.from(widget.role.permissionIds);
    _loadAllPermissions();
  }

  // ✅ Fetch all available permissions from backend
  Future<void> _loadAllPermissions() async {
    setState(() {
      _isLoadingPermissions = true;
      _errorMessage = null;
    });

    try {
      List<Map<String, dynamic>> permissions = [];

      // Try to get permissions from dedicated endpoint
      try {
        permissions = await _apiService.getAllPermissions();
      } catch (e) {
        debugPrint('⚠️ Could not fetch from permissions endpoint: $e');
        debugPrint('Trying to extract from role assignments...');

        // Fallback: Extract from existing role permissions
        permissions = await _apiService.getAllPermissions();
      }

      // If still no permissions, use hardcoded list as last resort

      setState(() {
        allPermissions = permissions;
        _isLoadingPermissions = false;
      });

      debugPrint('✅ Loaded ${allPermissions.length} permissions');
      debugPrint('✅ Currently selected permission IDs: $selectedPermissionIds');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load permissions: $e';
        _isLoadingPermissions = false;
      });
      debugPrint('❌ Error loading permissions: $e');
    }
  }

  void _togglePermission(int permissionId) {
    setState(() {
      if (selectedPermissionIds.contains(permissionId)) {
        selectedPermissionIds.remove(permissionId);
      } else {
        selectedPermissionIds.add(permissionId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (isAllSelected) {
        selectedPermissionIds.clear();
      } else {
        selectedPermissionIds.clear();
        selectedPermissionIds.addAll(allPermissions.map((p) => p['id'] as int));
      }
    });
  }

  bool get isAllSelected =>
      selectedPermissionIds.length == allPermissions.length;

  Future<void> _savePermissions() async {
    if (selectedPermissionIds.isEmpty) {
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
      // ✅ Send permission IDs to backend
      final success = await _apiService.updatePermissions(
        rolePermissionId: widget.role.rolePermissionId,
        roleId: widget.role.roleId,
        permissionIds: selectedPermissionIds.toList(),
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

                          // ✅ Dynamic Permissions List
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
                                      final permId = permission['id'] as int;
                                      final permName =
                                          permission['name'] as String;
                                      final isSelected = selectedPermissionIds
                                          .contains(permId);

                                      return CheckboxListTile(
                                        value: isSelected,
                                        onChanged: _isSubmitting
                                            ? null
                                            : (_) => _togglePermission(permId),
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
                            '${selectedPermissionIds.length} of ${allPermissions.length} permissions selected',
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
