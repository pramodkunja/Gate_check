import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:gatecheck/Services/Permission_services/permission_service.dart';
import 'package:gatecheck/Services/Roles_permission_services/role_permissions_service.dart';
import 'package:gatecheck/Services/User_roles_services/user_roles_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignPermissionsDialog extends StatefulWidget {
  final VoidCallback onAssign;

  const AssignPermissionsDialog({required this.onAssign, super.key});

  @override
  State<AssignPermissionsDialog> createState() =>
      _AssignPermissionsDialogState();
}

class _AssignPermissionsDialogState extends State<AssignPermissionsDialog> {
  final RolePermissionsApiService _apiService = RolePermissionsApiService();
  final UserRoleService _apiRoleService = UserRoleService();
  final PermissionService _permissionService = PermissionService();

  int? selectedRoleId;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> roles = []; // {id, name}
  List<Map<String, dynamic>> permissionList = []; // {permission_id, name}

  final Set<int> selectedPermissionIds = {}; // Store INT IDs

  bool _loadingRoles = true;
  bool _loadingPermissions = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _loadPermissions();
  }

  Future<void> _loadRoles() async {
    final result = await _apiRoleService.getAvailableRoles();
    setState(() {
      roles = result; // [{id: 1, name: "Admin"}]
      _loadingRoles = false;
    });
  }

  Future<void> _loadPermissions() async {
    final result = await _permissionService.getAllPermissions();
    setState(() {
      permissionList = result; // full permission list
      _loadingPermissions = false;
    });
  }

  bool get isAllSelected =>
      selectedPermissionIds.length == permissionList.length;

  void _toggleSelectAll() {
    setState(() {
      if (isAllSelected) {
        selectedPermissionIds.clear();
      } else {
        selectedPermissionIds.clear();
        selectedPermissionIds.addAll(
          permissionList.map((p) => p["permission_id"] as int),
        );
      }
    });
  }

  Future<void> _assignPermissions() async {
    if (selectedRoleId == null) {
      _showMsg("Please select a role");
      return;
    }
    if (selectedPermissionIds.isEmpty) {
      _showMsg("Select at least one permission");
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _apiService.assignPermissions(
      roleId: selectedRoleId!,
      permissionIds: selectedPermissionIds.toList(),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      _showMsg("Permissions assigned successfully!", success: true);
      widget.onAssign();
    } else {
      _showMsg("Failed to assign permissions");
    }
  }

  void _showMsg(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
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
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Assign Permissions to Role',
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
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: _loadingRoles || _loadingPermissions
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Title
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

                          // Role Dropdown
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF7E57C2),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<int>(
                              value: selectedRoleId,
                              decoration: InputDecoration(
                                hintText: 'Select a role',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: roles.map<DropdownMenuItem<int>>((map) {
                                return DropdownMenuItem<int>(
                                  value: map['id'] as int, // cast to int
                                  child: Text(
                                    map['name'].toString(),
                                    style: GoogleFonts.poppins(),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedRoleId = value;
                                      });
                                    },
                              icon: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Permissions
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

                          // Permissions List
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: permissionList.length,
                              itemBuilder: (context, index) {
                                final p = permissionList[index];
                                final int id = p["permission_id"];
                                final String name = p["name"];

                                return CheckboxListTile(
                                  value: selectedPermissionIds.contains(id),
                                  onChanged: _isSubmitting
                                      ? null
                                      : (_) {
                                          setState(() {
                                            selectedPermissionIds.contains(id)
                                                ? selectedPermissionIds.remove(
                                                    id,
                                                  )
                                                : selectedPermissionIds.add(id);
                                          });
                                        },
                                  title: Text(
                                    name,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            '${selectedPermissionIds.length} of ${permissionList.length} permissions selected',
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

            // Footer
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
                    onPressed: _isSubmitting ? null : _assignPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Assign Permissions',
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
