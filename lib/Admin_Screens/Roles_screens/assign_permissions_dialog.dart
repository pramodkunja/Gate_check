// assign_permissions_dialog.dart
// Place this file in: lib/Widgets/Role_Permissions/

import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Roles_services/role_permissions_service.dart';
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
  String? selectedRole;
  final Set<String> selectedPermissions = {};
  bool _isSubmitting = false;

  final List<String> roles = ['Admin', 'employee', 'security guard'];

  final List<String> allPermissions = [
    'create_user',
    'update_users',
    'delete_users',
    'view_users',
    'create_organization',
    'update_organization',
    'delete_organization',
    'view_organization',
    'create_category',
    'update_category',
    'delete_category',
    'view_category',
    'create_roles',
    'update_roles',
    'delete_roles',
    'view_roles',
    'create_visitor',
    'update_visitor',
    'delete_visitor',
    'view_visitor',
    'create_personal_details',
    'update_personal_details',
    'delete_personal_details',
    'view_personal_details',
    'create_report',
    'update_report',
    'delete_report',
    'view_report',
    'create_approval',
    'view_approval',
    'update_approval',
    'delete_approval',
    'create_reject',
    'view_reject',
    'update_reject',
    'delete_reject',
    'create_reschedule',
    'view_reschedule',
    'update_reschedule',
    'delete_reschedule',
    'create_qr',
    'view_qr',
    'update_qr',
    'delete_qr',
    'create_entry',
    'view_entry',
    'update_entry',
    'delete_entry',
    'create_exit',
    'view_exit',
    'update_exit',
    'delete_exit',
    'create_pdf',
    'view_pdf',
    'view_excel',
    'create_excel',
    'view_visitors',
    'view_profile',
    'create_profile',
  ];

  void _togglePermission(String permission) {
    setState(() {
      if (selectedPermissions.contains(permission)) {
        selectedPermissions.remove(permission);
      } else {
        selectedPermissions.add(permission);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedPermissions.length == allPermissions.length) {
        selectedPermissions.clear();
      } else {
        selectedPermissions.clear();
        selectedPermissions.addAll(allPermissions);
      }
    });
  }

  bool get isAllSelected => selectedPermissions.length == allPermissions.length;

  Future<void> _assignPermissions() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }
    if (selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one permission')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _apiService.assignPermissions(
      role: selectedRole!,
      permissions: selectedPermissions.toList(),
      roleId: roles.indexOf(selectedRole!),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assigned ${selectedPermissions.length} permissions to $selectedRole',
          ),
          backgroundColor: Colors.green,
        ),
      );
      widget.onAssign();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to assign permissions. Please try again.'),
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
          mainAxisSize: MainAxisSize.min,
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
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
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

                    // Role Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF7E57C2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
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
                        items: roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(() => selectedRole = value);
                              },
                        icon: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Permissions Section
                    Row(
                      children: [
                        const Icon(Icons.vpn_key, size: 20, color: Colors.grey),
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
                          onPressed: _isSubmitting ? null : _toggleSelectAll,
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
                        itemCount: allPermissions.length,
                        itemBuilder: (context, index) {
                          final permission = allPermissions[index];
                          final isSelected = selectedPermissions.contains(
                            permission,
                          );

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: _isSubmitting
                                ? null
                                : (_) => _togglePermission(permission),
                            title: Text(
                              permission,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(
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
                      '${selectedPermissions.length} of ${allPermissions.length} permissions selected',
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
                    onPressed: _isSubmitting ? null : _assignPermissions,
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
