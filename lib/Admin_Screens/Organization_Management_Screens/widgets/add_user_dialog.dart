// dialogs/add_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:gatecheck/Services/Admin_Services/organization_services.dart';
import 'package:gatecheck/Services/Roles_services/roles_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

class AddUserDialog extends StatefulWidget {
  final String companyName;
  final String? companyId; // Add company ID parameter
  final Function(User, String) onAdd;

  const AddUserDialog({
    super.key,
    required this.companyName,
    this.companyId,
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

  // ✅ New: company name controller (so UI updates when API returns)
  final _companyController = TextEditingController();

  final OrganizationService _orgService = OrganizationService();
  final RoleService _roleService = RoleService();

  String? _selectedRole;
  bool _isLoadingCompany = false;

  // ✅ Roles from backend
  List<Map<String, dynamic>> _rolesFromApi = [];
  // ignore: unused_field
  bool _isLoadingRoles = false;
  String? _rolesError;

  @override
  void initState() {
    super.initState();

    // Start showing whatever name we already have
    _companyController.text = widget.companyName;

    if (widget.companyId != null) {
      _loadCompanyDetails();
    }
    _loadRoles();
  }

  // Load company details from API
  Future<void> _loadCompanyDetails() async {
    setState(() {
      _isLoadingCompany = true;
    });

    try {
      final response = await _orgService.getOrganizationById(widget.companyId!);

      debugPrint('📦 Company details response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final nameFromApi = data['company_name']?.toString();
        setState(() {
          if (nameFromApi != null && nameFromApi.isNotEmpty) {
            _companyController.text = nameFromApi;
          } else {
            _companyController.text = widget.companyName;
          }
          _isLoadingCompany = false;
        });
      } else {
        setState(() {
          _companyController.text = widget.companyName;
          _isLoadingCompany = false;
        });
      }
    } on DioException catch (e) {
      debugPrint('❌ Load company error: ${e.message}');
      setState(() {
        _companyController.text = widget.companyName;
        _isLoadingCompany = false;
      });
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      setState(() {
        _companyController.text = widget.companyName;
        _isLoadingCompany = false;
      });
    }
  }

  // ✅ Load roles from backend
  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
      _rolesError = null;
    });

    try {
      final fetchedRoles = await _roleService.getAllRoles();
      setState(() {
        // Keep only active roles (adjust if you want all)
        _rolesFromApi = fetchedRoles
            .where((r) => r['is_active'] == true)
            .toList();
        _isLoadingRoles = false;
      });

      debugPrint('✅ Loaded roles for AddUserDialog: $_rolesFromApi');
    } catch (e) {
      debugPrint('❌ Error loading roles: $e');
      setState(() {
        _rolesError = 'Failed to load roles';
        _isLoadingRoles = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _aliasController.dispose();
    _blockController.dispose();
    _floorController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a role')));
        return;
      }
      if (widget.companyId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Company ID is missing')));
        return;
      }

      final user = User(
        id: '', // Will be assigned by API
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        // ✅ Use current controller text (updated from API)
        companyName: _companyController.text.trim(),
        role: _selectedRole!,
        aliasName: _aliasController.text.trim(),
        block: _blockController.text.trim(),
        floor: _floorController.text.trim(),
        dateAdded: null,
      );
      widget.onAdd(
        user,
        widget.companyId!,
      ); // pass companyId as extra parameter
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        fontSize: isSmallScreen ? 18 : 20,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
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
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
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
                          hintText: 'Enter 10-digit mobile number',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter mobile number';
                          }
                          if (value.trim().length != 10) {
                            return 'Mobile number must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ✅ Company name (read-only, updated by controller)
                      TextFormField(
                        controller: _companyController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Company Name *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          prefixIcon: _isLoadingCompany
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.business_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        enabled: false, // read-only field
                      ),
                      // const SizedBox(height: 16),

                      // ✅ Role dropdown from API
                      // DropdownButtonFormField<String>(
                      //   initialValue: _selectedRole,
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 16,
                      //     color: Colors.black87,
                      //   ),
                      //   decoration: InputDecoration(
                      //     labelText: 'Role *',
                      //     labelStyle: GoogleFonts.poppins(fontSize: 18),
                      //     prefixIcon: const Icon(Icons.work_outline),
                      //     border: const OutlineInputBorder(),
                      //     suffixIcon: _isLoadingRoles
                      //         ? const Padding(
                      //             padding: EdgeInsets.all(12),
                      //             child: SizedBox(
                      //               width: 20,
                      //               height: 20,
                      //               child: CircularProgressIndicator(
                      //                 strokeWidth: 2,
                      //               ),
                      //             ),
                      //           )
                      //         : null,
                      //   ),
                      //   hint: Text(
                      //     _isLoadingRoles
                      //         ? 'Loading roles...'
                      //         : 'Select a role',
                      //     style: GoogleFonts.poppins(fontSize: 16),
                      //   ),
                      //   items: _rolesFromApi.map((roleMap) {
                      //     final roleName =
                      //         roleMap['name']?.toString() ?? 'Unnamed role';
                      //     return DropdownMenuItem<String>(
                      //       value: roleName,
                      //       child: Text(
                      //         roleName,
                      //         style: GoogleFonts.poppins(fontSize: 16),
                      //       ),
                      //     );
                      //   }).toList(),
                      //   onChanged: _isLoadingRoles || _rolesFromApi.isEmpty
                      //       ? null
                      //       : (value) {
                      //           setState(() {
                      //             _selectedRole = value;
                      //           });
                      //         },
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please select a role';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      if (_rolesError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _rolesError!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _aliasController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Alias Name *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter alias name',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter alias name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _blockController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Block/Building *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter block or building',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.apartment_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter block or building';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _floorController,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Floor *',
                          labelStyle: GoogleFonts.poppins(fontSize: 18),
                          hintText: 'Enter floor number',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          prefixIcon: const Icon(Icons.layers_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter floor';
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
                    child: Text('Cancel', style: GoogleFonts.poppins()),
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
