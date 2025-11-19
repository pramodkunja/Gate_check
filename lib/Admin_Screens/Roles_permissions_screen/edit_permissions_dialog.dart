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

  late Set<String> selectedPermissionNames;
  late bool isActive; // ✅ Active checkbox state

  List<Map<String, dynamic>> allPermissions = [];
  List<Map<String, dynamic>> allRoles = [];

  bool _isSubmitting = false;
  bool _isLoadingPermissions = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    selectedPermissionNames = Set<String>.from(widget.role.permissions);
    isActive = widget.role.isActive; // ✅ Load active status from model
    _loadAllPermissions();
    _loadAllRoles();
  }

  Future<void> _loadAllRoles() async {
    try {
      allRoles = await _apiService.getAllRoles();
    } catch (_) {}
  }

  Future<void> _loadAllPermissions() async {
    setState(() {
      _isLoadingPermissions = true;
      _errorMessage = null;
    });

    try {
      allPermissions = await _apiService.getAllPermissions();

      setState(() => _isLoadingPermissions = false);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load permissions: $e";
        _isLoadingPermissions = false;
      });
    }
  }

  void _togglePermission(String name) {
    setState(() {
      if (selectedPermissionNames.contains(name)) {
        selectedPermissionNames.remove(name);
      } else {
        selectedPermissionNames.add(name);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (isAllSelected) {
        selectedPermissionNames.clear();
      } else {
        selectedPermissionNames = allPermissions
            .map((p) => p['name'] as String)
            .toSet();
      }
    });
  }

  bool get isAllSelected =>
      selectedPermissionNames.length == allPermissions.length;

  Future<void> _savePermissions() async {
    if (selectedPermissionNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select at least one permission"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedPermissionIds = <int>[];
    for (var name in selectedPermissionNames) {
      final perm = allPermissions.firstWhere(
        (p) => p['name'] == name,
        orElse: () => {'id': 0},
      );

      if (perm['id'] != 0) selectedPermissionIds.add(perm['id']);
    }

    // roleId fix
    int finalRoleId = widget.role.roleId;
    if (finalRoleId == 0 && allRoles.isNotEmpty) {
      final match = allRoles.firstWhere(
        (r) =>
            r['name'].toString().toLowerCase() ==
            widget.role.role.toLowerCase(),
        orElse: () => {},
      );
      if (match.containsKey('id')) finalRoleId = match['id'];
    }

    final success = await _apiService.updatePermissions(
      rolePermissionId: widget.role.rolePermissionId,
      roleId: finalRoleId,
      permissions: selectedPermissionIds,
      role: widget.role.role,
      isActive: isActive, // ✅ include active flag
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
          content: Text('Failed to update permissions'),
          backgroundColor: Colors.red,
        ),
      );
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
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Permissions',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: _isLoadingPermissions
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION: Role
                          Text(
                            "Role",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.shield, color: Colors.grey[700]),
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

                          const SizedBox(height: 16),

                          // ✅ Active checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: isActive,
                                onChanged: (value) {
                                  setState(() => isActive = value ?? false);
                                },
                              ),
                              Text(
                                "Active",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // SECTION: Permissions
                          Row(
                            children: [
                              Text(
                                "Permissions",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _toggleSelectAll,
                                child: Text(
                                  isAllSelected ? "Deselect All" : "Select All",
                                  style: const TextStyle(
                                    color: Color(0xFF7E57C2),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ListView.builder(
                              itemCount: allPermissions.length,
                              itemBuilder: (context, index) {
                                final p = allPermissions[index];
                                final name = p['name'] as String;

                                return CheckboxListTile(
                                  value: selectedPermissionNames.contains(name),
                                  onChanged: (_) => _togglePermission(name),
                                  title: Text(name),
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 12),
                          Text(
                            "${selectedPermissionNames.length} of ${allPermissions.length} selected",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting || _isLoadingPermissions
                        ? null
                        : _savePermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
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
