import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewPermissionDialog extends StatefulWidget {
  final Function(String permissionName, bool isActive) onSubmit;
  final String? initialName;
  final bool? initialIsActive;
  final bool isEdit;

  const AddNewPermissionDialog({
    super.key,
    required this.onSubmit,
    this.initialName,
    this.initialIsActive,
    this.isEdit = false,
  });

  @override
  State<AddNewPermissionDialog> createState() => _AddNewPermissionDialogState();
}

class _AddNewPermissionDialogState extends State<AddNewPermissionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _permissionNameController;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _permissionNameController = TextEditingController(
      text: widget.initialName ?? '',
    );
    _isActive = widget.initialIsActive ?? true;
  }

  @override
  void dispose() {
    _permissionNameController.dispose();
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
                  widget.isEdit ? 'Edit Permission' : 'Add New Permission',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: _isSubmitting
                      ? null
                      : () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Icon(
                    Icons.close,
                    color: _isSubmitting ? Colors.grey[300] : Colors.grey,
                  ),
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
                    'Permission Name',
                    style: GoogleFonts.poppins(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _permissionNameController,
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      hintText: 'Enter permission name',
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
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Permission name is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Permission name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _isActive,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
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
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: _isSubmitting ? Colors.grey[300] : Colors.black54,
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isSubmitting ? Colors.grey[300]! : Colors.purple,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple,
                            ),
                          ),
                        )
                      : const Icon(Icons.save_outlined, color: Colors.purple),
                  label: Text(
                    widget.isEdit ? 'Update' : 'Submit',
                    style: GoogleFonts.poppins(
                      color: _isSubmitting ? Colors.grey[300] : Colors.purple,
                      fontWeight: FontWeight.w500,
                      fontSize: buttonFontSize,
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSubmitting = true;
                            });

                            try {
                              await widget.onSubmit(
                                _permissionNameController.text.trim(),
                                _isActive,
                              );
                              // ✅ Safe pop, prevents redirect or unmounted crash
                              if (mounted) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              }
                            } catch (e) {
                              setState(() {
                                _isSubmitting = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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
