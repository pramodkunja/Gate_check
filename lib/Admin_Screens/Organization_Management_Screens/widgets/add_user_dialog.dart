// dialogs/add_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:google_fonts/google_fonts.dart';


class AddUserDialog extends StatefulWidget {
  final String companyName;
  final Function(User) onAdd;

  const AddUserDialog({
    super.key,
    required this.companyName,
    required this.onAdd,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aliasController = TextEditingController();
  final _blockController = TextEditingController();
  final _floorController = TextEditingController();
  String? _selectedRole;

  final List<String> _roles = [
    'Admin',
    'Manager',
    'Developer',
    'Designer',
    'Tester',
    'HR',
    'Sales',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _aliasController.dispose();
    _blockController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        companyName: widget.companyName,
        role: _selectedRole!,
        aliasName: _aliasController.text.trim().isEmpty ? null : _aliasController.text.trim(),
        block: _blockController.text.trim().isEmpty ? null : _blockController.text.trim(),
        floor: _floorController.text.trim().isEmpty ? null : _floorController.text.trim(),
        dateAdded: DateTime.now(),
      );
      widget.onAdd(user);
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
                      'Add New User',
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
                          labelText: 'User Name *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter user name',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter user name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Email Address *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter email address',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mobileController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Mobile Number *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter mobile number',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: widget.companyName,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Company Name *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          prefixIcon: const Icon(Icons.business_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Role *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          prefixIcon: const Icon(Icons.work_outline),
                          border: const OutlineInputBorder(),
                        ),
                        hint: Text(
                          'Select a role',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a role';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _aliasController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Alias Name',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter alias name (optional)',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _blockController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Block/Building',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter block or building (optional)',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.apartment_outlined),
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
                          hintText: 'Enter floor (optional)',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.layers_outlined),
                          border: const OutlineInputBorder(),
                        ),
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
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Create User',
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