import 'package:flutter/material.dart';
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
  bool isActive = true; // ✅ Active flag to send with assignment

  List<Map<String, dynamic>> roles = [];        // {id, name}
  List<Map<String, dynamic>> permissionList = []; // {id/permission_id, name}

  // ✅ Track already-assigned roles by both ID and name
  final Set<int> _assignedRoleIds = {};
  final Set<String> _assignedRoleNamesLower = {};

  final Set<int> selectedPermissionIds = {}; // Store INT IDs

  bool _loadingRoles = true;
  bool _loadingPermissions = true;
  bool _loadingAssignedRoles = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// Load existing role-permissions first, then roles + permissions
  Future<void> _initData() async {
    await _loadAssignedRoles(); // fills _assignedRoleIds & _assignedRoleNamesLower
    await Future.wait([
      _loadRoles(),      // uses the sets above to filter
      _loadPermissions(),
    ]);
  }

  /// ✅ Read `/roles/assign-permissions/` and figure out which roles are already mapped
  Future<void> _loadAssignedRoles() async {
    try {
      final List<RolePermissionModel> mappings =
          await _apiService.getRolePermissions();

      setState(() {
        _assignedRoleIds
          ..clear()
          ..addAll(
            mappings
                .where((m) => m.isActive && m.roleId != 0)
                .map((m) => m.roleId),
          );

        _assignedRoleNamesLower
          ..clear()
          ..addAll(
            mappings
                .where(
                  (m) =>
                      m.isActive &&
                      m.role.trim().isNotEmpty,
                )
                .map((m) => m.role.trim().toLowerCase()),
          );

        _loadingAssignedRoles = false;
      });

      debugPrint('✅ Assigned Role IDs: $_assignedRoleIds');
      debugPrint('✅ Assigned Role Names: $_assignedRoleNamesLower');
    } catch (e) {
      setState(() {
        _loadingAssignedRoles = false;
      });
      _showMsg('Failed to load existing role permissions');
    }
  }

  /// ✅ Load roles from your UserRoleService and filter out assigned roles
  Future<void> _loadRoles() async {
    try {
      final result = await _apiRoleService.getAvailableRoles();
      // expected like: [{ "id": 1, "name": "Admin" }, ...]

      setState(() {
        roles = result
            .where((r) {
              // Normalize ID
              final dynamic rawId = r['id'] ?? r['role_id'] ?? 0;
              final int id = rawId is int
                  ? rawId
                  : int.tryParse(rawId.toString()) ?? 0;

              // Normalize name
              final rawName =
                  (r['name'] ?? r['role'] ?? r['role_name'] ?? '').toString();
              final lowerName = rawName.toLowerCase();

              final isAssignedById =
                  id != 0 && _assignedRoleIds.contains(id);
              final isAssignedByName = lowerName.isNotEmpty &&
                  _assignedRoleNamesLower.contains(lowerName);

              // ❌ Exclude if assigned by ID or by name
              return !(isAssignedById || isAssignedByName);
            })
            .map<Map<String, dynamic>>((r) {
              final dynamic rawId = r['id'] ?? r['role_id'] ?? 0;
              final int id = rawId is int
                  ? rawId
                  : int.tryParse(rawId.toString()) ?? 0;

              final name =
                  (r['name'] ?? r['role'] ?? r['role_name'] ?? '').toString();

              return {'id': id, 'name': name};
            })
            .toList();

        _loadingRoles = false;
      });

      debugPrint('✅ Roles available for assignment: $roles');
    } catch (e) {
      setState(() {
        _loadingRoles = false;
      });
      _showMsg('Failed to load roles');
    }
  }

  Future<void> _loadPermissions() async {
    try {
      final result = await _permissionService.getAllPermissions();
      setState(() {
        permissionList = result; // full permission list (id + name)
        _loadingPermissions = false;
      });
    } catch (e) {
      setState(() {
        _loadingPermissions = false;
      });
      _showMsg('Failed to load permissions');
    }
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
          permissionList.map(
            (p) => (p['permission_id'] ?? p['id']) as int,
          ),
        );
      }
    });
  }

  Future<void> _assignPermissions() async {
    if (roles.isEmpty) {
      _showMsg("No roles available to assign");
      return;
    }

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
      permissions: selectedPermissionIds.toList(),
      isActive: isActive,
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

    final isLoading =
        _loadingRoles || _loadingPermissions || _loadingAssignedRoles;

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
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : roles.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'All roles already have permissions assigned.\nNo roles available to assign.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        )
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
                                  initialValue: selectedRoleId,
                                  decoration: InputDecoration(
                                    hintText: 'Select a role',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items:
                                      roles.map<DropdownMenuItem<int>>((map) {
                                    return DropdownMenuItem<int>(
                                      value: map['id'] as int,
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

                              // Active checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: isActive,
                                    onChanged: _isSubmitting
                                        ? null
                                        : (val) => setState(
                                              () => isActive = val ?? false,
                                            ),
                                  ),
                                  Text(
                                    'Active',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

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
                                      isAllSelected
                                          ? 'Deselect All'
                                          : 'Select All',
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
                                  border:
                                      Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: permissionList.length,
                                  itemBuilder: (context, index) {
                                    final p = permissionList[index];
                                    final int id =
                                        (p['permission_id'] ?? p['id']) as int;
                                    final String name =
                                        p['name']?.toString() ?? '';

                                    return CheckboxListTile(
                                      value:
                                          selectedPermissionIds.contains(id),
                                      onChanged: _isSubmitting
                                          ? null
                                          : (_) {
                                              setState(() {
                                                selectedPermissionIds
                                                        .contains(id)
                                                    ? selectedPermissionIds
                                                        .remove(id)
                                                    : selectedPermissionIds
                                                        .add(id);
                                              });
                                            },
                                      title: Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14),
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
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
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
                    onPressed: _isSubmitting || roles.isEmpty
                        ? null
                        : _assignPermissions,
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
