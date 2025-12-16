// Force rebuild
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'package:dio/dio.dart';

class AddVisitorDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddVisitorDialog({super.key, required this.onAdd});

  @override
  State<AddVisitorDialog> createState() => _AddVisitorDialogState();
}

class _AddVisitorDialogState extends State<AddVisitorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _whomToMeetController = TextEditingController();
  final _comingFromController = TextEditingController();
  final _purposeController = TextEditingController();
  final _belongingsController = TextEditingController();
  final _securityNotesController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _allowingHoursController = TextEditingController(text: '8');
  final _recurringDaysController = TextEditingController();
  final _companyDetailsController = TextEditingController();

  String selectedGender = 'Select gender';
  String selectedPassType = 'One Time';

  // categories loaded from backend
  List<Map<String, dynamic>> categories = [];
  Map<String, int> categoryMap = {}; // name -> id
  String selectedCategory = 'Select category';
  int? selectedCategoryId;

  String selectedVehicleType = 'Select vehicle type';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? _validUntilDate;

  bool isSubmitting = false;
  bool isCategoryLoading = false;
  String? _dialogError;

  // default fallback if API returns none (optional)
  final List<Map<String, dynamic>> fallbackCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isCategoryLoading = true;
    });

    try {
      final resp = await VisitorApiService().getCategories();
      // Expecting a list of objects like [{"id":15,"name":"Vendor","is_active":true,...}, ...]
      final data = resp.data;
      
      List<Map<String, dynamic>> fetchedCategories = [];

      if (data is List) {
        fetchedCategories = data
            .map<Map<String, dynamic>>((e) {
              // Normalize to map with keys 'id', 'name', and now 'is_active'
              if (e is Map<String, dynamic>) {
                return {
                  'id': e['id'],
                  'name': e['name']?.toString() ?? '',
                  'is_active': e['is_active'] ?? false, // Default to false if missing
                };
              }
              return {'id': null, 'name': e.toString(), 'is_active': false};
            })
            // Filter to include only categories that are active, have an ID, and a non-empty name
            .where((m) =>
                m['id'] != null &&
                (m['name'] as String).isNotEmpty &&
                m['is_active'] == true) // <-- The updated filtering logic
            .toList();
      }

      // If API returned empty or unexpected, fallback to default categories
      if (fetchedCategories.isEmpty) {
        categories = fallbackCategories;
      } else {
        categories = fetchedCategories;
      }

      // Build lookup map name -> id (use the display name as key)
      categoryMap = {
        for (var c in categories) (c['name'] as String): (c['id'] as int),
      };

      // Ensure the selectedCategory is still valid after filtering (if not, reset)
      if (!categoryMap.containsKey(selectedCategory)) {
        selectedCategory = 'Select category';
        selectedCategoryId = null;
      }


      // Prepare dropdown selected value (keep 'Select category' until user picks)
      if (!mounted) return;
      setState(() {
        isCategoryLoading = false;
      });
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      // On error, fallback and show a friendly message
      setState(() {
        categories = fallbackCategories;
        categoryMap = {
          for (var c in categories) (c['name'] as String): (c['id'] as int),
        };
        isCategoryLoading = false;
        // Reset selected if it was from a previous successful load that is now failing
        selectedCategory = 'Select category';
        selectedCategoryId = null;
      });

      if (mounted) {
        setState(() {
          _dialogError = 'Failed to load categories. Using defaults.';
        });
      }
    } catch (e) {
      // Generic fallback
      setState(() {
        categories = fallbackCategories;
        categoryMap = {
          for (var c in categories) (c['name'] as String): (c['id'] as int),
        };
        isCategoryLoading = false;
        selectedCategory = 'Select category';
        selectedCategoryId = null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _whomToMeetController.dispose();
    _comingFromController.dispose();
    _purposeController.dispose();
    _belongingsController.dispose();
    _securityNotesController.dispose();
    _vehicleNumberController.dispose();
    _allowingHoursController.dispose();
    _recurringDaysController.dispose();
    _companyDetailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext ctx) async {
    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext ctx) async {
    final TimeOfDay? picked = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _selectValidUntil(BuildContext ctx) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: _validUntilDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _validUntilDate = picked;
      });
    }
  }

  String _getPassTypeApiValue(String displayLabel) {
    switch (displayLabel) {
      case 'One Time':
        return 'ONE_TIME';
      case 'Recurring':
        return 'RECURRING';
      case 'Permanent':
        return 'PERMANENT';
      default:
        return 'ONE_TIME';
    }
  }

  void _submitForm() async {
    if (isSubmitting) return;

    // Basic validations
    final bool basicValid = _formKey.currentState!.validate();
    final bool dateTimeSelected = selectedDate != null && selectedTime != null;
    final bool categorySelected =
        selectedCategory != 'Select category' && selectedCategoryId != null;

    if (!basicValid || !dateTimeSelected || !categorySelected) {
      setState(() {
        _dialogError = 'Please fill all required fields';
      });
      return;
    }

    // Recurring-specific validations
    if (selectedPassType == 'Recurring') {
      if (_recurringDaysController.text.trim().isEmpty ||
          _validUntilDate == null) {
        setState(() {
          _dialogError = 'Please provide recurring days and valid until date.';
        });
        return;
      }
      if (int.tryParse(_recurringDaysController.text.trim()) == null) {
        setState(() {
          _dialogError = 'Recurring days must be a valid number.';
        });
        return;
      }
    }

    setState(() {
      isSubmitting = true;
    });

    // Prepare data for API
    final Map<String, dynamic> visitorData = {
      'visitor_name': _nameController.text.trim(),
      'mobile_number': _phoneController.text.trim(),
      'email_id': _emailController.text.trim(),
      'visiting_date':
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
      'visiting_time':
          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00',
      'purpose_of_visit': _purposeController.text.trim(),
      // Use selectedCategoryId that comes from backend
      'category': selectedCategoryId,
      'allowing_hours': int.tryParse(_allowingHoursController.text) ?? 8,
      // Add pass_type based on selected value
      'pass_type': _getPassTypeApiValue(selectedPassType),
    };

    // Add optional fields
    if (selectedGender != 'Select gender') {
      String genderCode = 'O';
      if (selectedGender == 'Male') {
        genderCode = 'M';
      } else if (selectedGender == 'Female') {
        genderCode = 'F';
      }
      visitorData['gender'] = genderCode;
    }

    if (_whomToMeetController.text.trim().isNotEmpty) {
      visitorData['whom_to_meet'] = _whomToMeetController.text.trim();
    }

    if (_comingFromController.text.trim().isNotEmpty) {
      visitorData['coming_from'] = _comingFromController.text.trim();
    }

    if (_companyDetailsController.text.trim().isNotEmpty) {
      visitorData['company_details'] = _companyDetailsController.text.trim();
    }

    if (_belongingsController.text.trim().isNotEmpty) {
      visitorData['belongings_tools'] = _belongingsController.text.trim();
    }

    if (_securityNotesController.text.trim().isNotEmpty) {
      visitorData['security_notes'] = _securityNotesController.text.trim();
    }

    // Recurring pass specific
    if (selectedPassType == 'Recurring') {
      visitorData['recurring_days'] = int.tryParse(
        _recurringDaysController.text.trim(),
      );
    }

    // Vehicle information (if you have vehicle API endpoint)
    if (_vehicleNumberController.text.trim().isNotEmpty &&
        selectedVehicleType != 'Select vehicle type') {
      final vehicleInfo =
          'Vehicle: $selectedVehicleType - ${_vehicleNumberController.text.trim()}';
      if (visitorData['security_notes'] != null) {
        visitorData['security_notes'] += ' | $vehicleInfo';
      } else {
        visitorData['security_notes'] = vehicleInfo;
      }
    }

    try {
      // clear previous dialog error
      if (mounted) setState(() => _dialogError = null);
      await widget.onAdd(visitorData);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
          _dialogError = 'Failed to add visitor. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Keep existing padding for good spacing on small/large screens
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          // Max width for tablet/desktop views
          maxWidth: 600,
          // Max height for responsiveness on all screens
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header (fixed at top)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Add New Visitor',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Inline error banner (shows above the form inside the dialog)
            if (_dialogError != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dialogError!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.close, color: Colors.red.shade700),
                        onPressed: () {
                          setState(() {
                            _dialogError = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Body (scrollable - grows to fill available space)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Visitor Name',
                        hint: 'Enter visitor name',
                        isRequired: true,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        hint: 'Enter 10-digit mobile number',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter email address',
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      _buildDropdown(
                        label: 'Gender',
                        isRequired: true,
                        value: selectedGender,
                        items: AppConstants.genders,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Visit Details'),
                      const SizedBox(height: 18),

                      _buildDropdown(
                        label: 'Pass Type',
                        value: selectedPassType,
                        items: const ['One Time', 'Recurring', 'Permanent'],
                        onChanged: (value) {
                          setState(() {
                            selectedPassType = value!;
                            if (selectedPassType != 'Recurring') {
                              _recurringDaysController.clear();
                              _validUntilDate = null;
                            }
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 18),

                      if (selectedPassType == 'Recurring') ...[
                        _buildTextField(
                          controller: _recurringDaysController,
                          label: 'Recurring Days',
                          hint: 'Number of recurring days (e.g., 30)',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        const SizedBox(height: 18),
                        // _buildDatePicker(
                        //   label: 'Valid Until',
                        //   selectedDate: _validUntilDate,
                        //   onTap: () => _selectValidUntil(context),
                        //   isRequired: true,
                        // ),
                        //const SizedBox(height: 18),
                      ],

                      // Category dropdown is based on backend
                      _buildDropdown(
                        label: 'Category',
                        value: selectedCategory,
                        items: [
                          'Select category',
                          ...categories.map((c) => c['name'].toString()),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                            selectedCategoryId = categoryMap[selectedCategory];
                          });
                        },
                        isRequired: true,
                      ),
                      if (isCategoryLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: const [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Loading categories...'),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),

                      _buildDatePicker(
                        label: 'Visiting Date',
                        selectedDate: selectedDate,
                        onTap: () => _selectDate(context),
                        isRequired: true,
                      ),
                      const SizedBox(height: 18),

                      _buildTimePicker(
                        label: 'Visiting Time',
                        selectedTime: selectedTime,
                        onTap: () => _selectTime(context),
                        isRequired: true,
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _allowingHoursController,
                        label: 'Allowing Hours',
                        hint: '8',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Purpose & Details'),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _whomToMeetController,
                        label: 'Whom to Meet',
                        hint: 'Person/department to meet',
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _comingFromController,
                        label: 'Coming From',
                        hint: 'Company/organization name',
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _companyDetailsController,
                        label: 'Company Details',
                        hint: 'Additional company information',
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _purposeController,
                        label: 'Purpose of Visit',
                        hint: 'Describe the purpose of visit',
                        isRequired: true,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Security & Additional Details'),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _belongingsController,
                        label: 'Belongings/Tools',
                        hint: 'Items being carried',
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _securityNotesController,
                        label: 'Security Notes',
                        hint: 'Any security observations',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Vehicle Information'),
                      const SizedBox(height: 18),

                      _buildDropdown(
                        label: 'Vehicle Type',
                        value: selectedVehicleType,
                        items: AppConstants.vehicleTypes,
                        onChanged: (value) {
                          setState(() {
                            selectedVehicleType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _vehicleNumberController,
                        label: 'Vehicle Number',
                        hint: 'Enter vehicle number',
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Add Visitor',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    // Helper: email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    // Input formatters
    List<TextInputFormatter>? inputFormatters;
    if (keyboardType == TextInputType.phone) {
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
    } else if (keyboardType == TextInputType.number) {
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ];
    } else if (keyboardType == TextInputType.emailAddress) {
      // prevent spaces in email
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ];
    } else if (keyboardType == TextInputType.text && label == 'Visitor Name') {
      // For visitor name: allow only alphabets and spaces
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.rejected,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: !isSubmitting,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.red,
              height: 1.5,
            ),
            errorMaxLines: 3,
          ),

          // Combined validator supporting required, phone and email rules
          validator: (value) {
            final text = value?.trim() ?? '';

            // Required validation
            if (isRequired && text.isEmpty) {
              return 'This field is required';
            }

            // Phone validation
            if (keyboardType == TextInputType.phone) {
              if (text.isEmpty) return 'Mobile number is required';
              if (text.length != 10) return 'Mobile number must be 10 digits';
              if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
                return 'Mobile number must contain only digits';
              }
              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
                return 'Enter a valid Indian mobile number';
              }
            }

            // Email validation
            if (keyboardType == TextInputType.emailAddress) {
              if (text.isEmpty) return 'Email is required';
              if (!emailRegex.hasMatch(text)) {
                return 'Enter a valid email address';
              }
            }

            // Number field basic check (e.g., Allowing Hours, Recurring Days)
            if (keyboardType == TextInputType.number && text.isNotEmpty) {
              if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
                return 'Enter a valid number';
              }
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.rejected,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 13)),
            );
          }).toList(),
          onChanged: isSubmitting ? null : onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.rejected,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isSubmitting ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}'
                        : 'mm/dd/yyyy',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, size: 16, color: AppColors.iconGray),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? selectedTime,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.rejected,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isSubmitting ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime != null
                        ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                        : '--:--',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: selectedTime != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.access_time, size: 16, color: AppColors.iconGray),
              ],
            ),
          ),
        ),
      ],
    );
  }
}