// dialogs/add_organization_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEdit ? 'Edit Organization' : 'Add New Organization',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Organization Name *',
                      hintText: 'Enter organization name',
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
                    decoration: const InputDecoration(
                      labelText: 'Location *',
                      hintText: 'Enter location',
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
                    decoration: const InputDecoration(
                      labelText: 'PIN Code *',
                      hintText: 'Enter 6-digit PIN code',
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
                    decoration: const InputDecoration(
                      labelText: 'Address *',
                      hintText: 'Enter complete address',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(isEdit ? Icons.check : Icons.add),
                        label: Text(isEdit ? 'Update Organization' : 'Add Organization'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}