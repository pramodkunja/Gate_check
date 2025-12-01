// dialogs/edit_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:google_fonts/google_fonts.dart';

class EditUserDialog extends StatefulWidget {
  final User user;
  final Function(User) onUpdate;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onUpdate,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _blockController;
  late TextEditingController _floorController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _blockController = TextEditingController(text: widget.user.block ?? '');
    _floorController = TextEditingController(text: widget.user.floor ?? '');
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _blockController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = User(
        id: widget.user.id,
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobileNumber: widget.user.mobileNumber,
        companyName: widget.user.companyName,
        role: widget.user.role,
        aliasName: widget.user.aliasName,
        block: _blockController.text.trim().isEmpty ? null : _blockController.text.trim(),
        floor: _floorController.text.trim().isEmpty ? null : _floorController.text.trim(),
        isActive: _isActive,
        dateAdded: widget.user.dateAdded,
      );
      widget.onUpdate(updatedUser);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 40 : 16,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: screenHeight * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit User',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _blockController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Block/Building',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _floorController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Floor',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<bool>(
                        initialValue: _isActive,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Active', style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Inactive', style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isActive = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: Text(
                        'Save',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(),
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