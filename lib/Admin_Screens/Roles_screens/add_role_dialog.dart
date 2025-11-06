import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewRoleDialog extends StatefulWidget {
  final Function(String roleName, bool isActive) onSubmit;
  final String? initialName;
  final bool? initialIsActive;
  final bool isEdit;

  const AddNewRoleDialog({
    super.key,
    required this.onSubmit,
    this.initialName,
    this.initialIsActive,
    this.isEdit = false,
  });

  @override
  State<AddNewRoleDialog> createState() => _AddNewRoleDialogState();
}

class _AddNewRoleDialogState extends State<AddNewRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roleNameController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _roleNameController = TextEditingController(text: widget.initialName ?? '');
    _isActive = widget.initialIsActive ?? true;
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 400;
    double titleFontSize = screenWidth < 360 ? 18 : 20;
    double labelFontSize = screenWidth < 360 ? 13 : 14;
    double buttonFontSize = screenWidth < 360 ? 13 : 14;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isEdit ? 'Edit Role' : 'Add New Role',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role Name',
                    style: GoogleFonts.poppins(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roleNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter role name',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: labelFontSize,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.purple,
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Role name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value ?? false);
                        },
                        activeColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        'Active',
                        style: GoogleFonts.poppins(
                          fontSize: labelFontSize,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.purple, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.save_outlined, color: Colors.purple),
                  label: Text(
                    widget.isEdit ? 'Update' : 'Submit',
                    style: GoogleFonts.poppins(
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                      fontSize: buttonFontSize,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.onSubmit(
                        _roleNameController.text.trim(),
                        _isActive,
                      );
                      // ✅ Safe pop, prevents redirect or unmounted crash
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
