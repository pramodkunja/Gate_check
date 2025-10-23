import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class AddVisitorDialog extends StatefulWidget {
  final Function(Visitor) onAdd;

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

  // New relationship fields requested
  final _relationController = TextEditingController();
  final _departmentController = TextEditingController();

  // Recurring-specific controller
  final _recurringDaysController = TextEditingController();
  DateTime? _validUntilDate;

  String selectedGender = 'Select gender';
  String selectedPassType = 'One Time';
  String selectedCategory = 'Select category';
  String selectedVehicleType = 'Select vehicle type';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
    _relationController.dispose();
    _departmentController.dispose();
    _recurringDaysController.dispose();
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
      initialDate: _validUntilDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _validUntilDate = picked;
      });
    }
  }

  void _submitForm() {
    // Basic required validations:
    final bool basicValid = _formKey.currentState!.validate();
    final bool dateTimeSelected = selectedDate != null && selectedTime != null;
    final bool categorySelected = selectedCategory != 'Select category';

    if (!basicValid || !dateTimeSelected || !categorySelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    // Recurring-specific validations
    if (selectedPassType == 'Recurring') {
      if (_recurringDaysController.text.trim().isEmpty ||
          _validUntilDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please provide recurring days and valid until date.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.rejected,
          ),
        );
        return;
      }
      if (int.tryParse(_recurringDaysController.text.trim()) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recurring days must be a valid number.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.rejected,
          ),
        );
        return;
      }
    }

    // Merge extra info into securityNotes so info isn't lost (adjust if your Visitor model has dedicated fields)
    String extraNotes = _securityNotesController.text.trim();
    final List<String> extras = [];

    if (_relationController.text.trim().isNotEmpty) {
      extras.add('Relation: ${_relationController.text.trim()}');
    }
    if (_departmentController.text.trim().isNotEmpty) {
      extras.add('Department: ${_departmentController.text.trim()}');
    }
    if (selectedPassType == 'Recurring') {
      extras.add('RecurringDays: ${_recurringDaysController.text.trim()}');
      extras.add(
        'ValidUntil: ${_validUntilDate != null ? '${_validUntilDate!.year}-${_validUntilDate!.month.toString().padLeft(2, '0')}-${_validUntilDate!.day.toString().padLeft(2, '0')}' : 'N/A'}',
      );
    }
    if (extras.isNotEmpty) {
      if (extraNotes.isNotEmpty) extraNotes += ' | ';
      extraNotes += extras.join(' ; ');
    }

    final visitor = Visitor(
      id: 'VP${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      category: selectedCategory,
      passType: selectedPassType,
      visitingDate: selectedDate!,
      visitingTime:
          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
      purpose: _purposeController.text.trim(),
      whomToMeet: _whomToMeetController.text.trim(),
      comingFrom: _comingFromController.text.trim(),
      status: VisitorStatus.pending,
      gender: selectedGender != 'Select gender' ? selectedGender : null,
      vehicleType: selectedVehicleType != 'Select vehicle type'
          ? selectedVehicleType
          : null,
      vehicleNumber: _vehicleNumberController.text.trim().isNotEmpty
          ? _vehicleNumberController.text.trim()
          : null,
      belongingsTools: _belongingsController.text.trim().isNotEmpty
          ? _belongingsController.text.trim()
          : null,
      securityNotes: extraNotes.isNotEmpty ? extraNotes : null,
      allowingHours: int.tryParse(_allowingHoursController.text),
    );

    widget.onAdd(visitor);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Single column layout: each field stacked vertically to avoid overflow on small screens.
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Body (scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 12),

                      // Visitor Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Visitor Name',
                        hint: 'Enter visitor name',
                        isRequired: true,
                      ),
                      const SizedBox(height: 12),

                      // Mobile Number
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        hint: 'Enter 10-digit mobile number',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter email address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // Gender
                      _buildDropdown(
                        label: 'Gender',
                        value: selectedGender,
                        items: AppConstants.genders,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      // Visit Details
                      _buildSectionTitle('Visit Details'),
                      const SizedBox(height: 12),

                      // Pass Type (when Recurring -> show extra fields)
                      _buildDropdown(
                        label: 'Pass Type',
                        value: selectedPassType,
                        items: const ['One Time', 'Recurring', 'Permanent'],
                        onChanged: (value) {
                          setState(() {
                            selectedPassType = value!;
                            // Clear recurring fields when pass type changes away from Recurring
                            if (selectedPassType != 'Recurring') {
                              _recurringDaysController.clear();
                              _validUntilDate = null;
                            }
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 12),

                      // If Recurring: show Recurring Days & Valid Until
                      if (selectedPassType == 'Recurring') ...[
                        _buildTextField(
                          controller: _recurringDaysController,
                          label: 'Recurring Days',
                          hint: 'Number of recurring days (e.g., 30)',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _buildDatePicker(
                          label: 'Valid Until',
                          selectedDate: _validUntilDate,
                          onTap: () => _selectValidUntil(context),
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Category
                      _buildDropdown(
                        label: 'Category',
                        value: selectedCategory,
                        items: const [
                          'Select category',
                          'Vendor',
                          'Walk-In',
                          'Contractor',
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 12),

                      // Visiting Date
                      _buildDatePicker(
                        label: 'Visiting Date',
                        selectedDate: selectedDate,
                        onTap: () => _selectDate(context),
                        isRequired: true,
                      ),
                      const SizedBox(height: 12),

                      // Visiting Time
                      _buildTimePicker(
                        label: 'Visiting Time',
                        selectedTime: selectedTime,
                        onTap: () => _selectTime(context),
                        isRequired: true,
                      ),
                      const SizedBox(height: 12),

                      // Allowing Hours
                      _buildTextField(
                        controller: _allowingHoursController,
                        label: 'Allowing Hours',
                        hint: '8',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      // Relationship & Purpose (with two new textfields)
                      _buildSectionTitle('Relationship & Purpose'),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _whomToMeetController,
                        label: 'Whom to Meet',
                        hint: 'Person/department to meet',
                      ),
                      const SizedBox(height: 12),

                      // New: Relation
                      _buildTextField(
                        controller: _relationController,
                        label: 'Relation',
                        hint: 'e.g., Client, Supplier, Employee',
                      ),
                      const SizedBox(height: 12),

                      // New: Department
                      _buildTextField(
                        controller: _departmentController,
                        label: 'Department',
                        hint: 'Department or team name',
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _comingFromController,
                        label: 'Coming From',
                        hint: 'Company/organization name',
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _purposeController,
                        label: 'Purpose of Visit',
                        hint: 'Describe the purpose of visit',
                        isRequired: true,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Security & Additional Details
                      _buildSectionTitle('Security & Additional Details'),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _belongingsController,
                        label: 'Belongings/Tools',
                        hint: 'Items being carried',
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _securityNotesController,
                        label: 'Security Notes',
                        hint: 'Any security observations',
                      ),
                      const SizedBox(height: 20),

                      // Vehicle Information
                      _buildSectionTitle('Vehicle Information'),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _vehicleNumberController,
                        label: 'Vehicle Number',
                        hint: 'Enter vehicle number',
                      ),
                      const SizedBox(height: 8),
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
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

  // ---------- Helper widgets (same style as your original) ----------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
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
          value: value,
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
          onChanged: (v) => onChanged(v),
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
          onTap: onTap,
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
          onTap: onTap,
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
