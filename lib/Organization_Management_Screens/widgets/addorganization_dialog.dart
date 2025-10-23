// dialogs/add_organization_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Organization_Management_Screens/models/models.dart';

class AddOrganizationDialog extends StatefulWidget {
  final Organization? organization;
  final Function(Organization) onAdd;

  const AddOrganizationDialog({
    super.key,
    this.organization,
    required this.onAdd,
  });

  @override
  State<AddOrganizationDialog> createState() => _AddOrganizationDialogState();
}

class _AddOrganizationDialogState extends State<AddOrganizationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _pinCodeController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.organization?.name ?? '');
    _locationController = TextEditingController(text: widget.organization?.location ?? '');
    _pinCodeController = TextEditingController(text: widget.organization?.pinCode ?? '');
    _addressController = TextEditingController(text: widget.organization?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _pinCodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final org = Organization(
        id: widget.organization?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        address: _addressController.text.trim(),
        users: widget.organization?.users ?? [],
      );
      widget.onAdd(org);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.organization != null;
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
                      isEdit ? 'Edit Organization' : 'Add New Organization',
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
                          labelText: 'Organization Name *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter organization name',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter organization name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Location *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter location',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pinCodeController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'PIN Code *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter 6-digit PIN code',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter PIN code';
                          }
                          if (value.length != 6) {
                            return 'PIN code must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Address *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter complete address',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
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
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(isEdit ? Icons.check : Icons.add),
                      label: Text(
                        isEdit ? 'Update' : 'Add',
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