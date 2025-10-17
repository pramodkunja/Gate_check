import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class FilterDropdown extends StatefulWidget {
  final String selectedStatus;
  final String selectedPassType;
  final String selectedCategory;
  final Function(String, String, String) onFilterChanged;

  const FilterDropdown({
    super.key,
    required this.selectedStatus,
    required this.selectedPassType,
    required this.selectedCategory,
    required this.onFilterChanged,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  bool _isOpen = false;

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => _FilterDialog(
        selectedStatus: widget.selectedStatus,
        selectedPassType: widget.selectedPassType,
        selectedCategory: widget.selectedCategory,
        onFilterChanged: widget.onFilterChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Count active filters
    int activeFilters = 0;
    if (widget.selectedStatus != 'All Status') activeFilters++;
    if (widget.selectedPassType != 'All Types') activeFilters++;
    if (widget.selectedCategory != 'All Categories') activeFilters++;

    return OutlinedButton.icon(
      onPressed: _showFilterDialog,
      icon: Icon(Icons.filter_list, size: 18, color: const Color(0xFF6B7280)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          if (activeFilters > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              // child: Text(
              //   'Active',
              //   style: GoogleFonts.inter(
              //     fontSize: 12,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.white,
              //   ),
              // ),
            ),
          ],
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: const Color(0xFF6B7280),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final String selectedStatus;
  final String selectedPassType;
  final String selectedCategory;
  final Function(String, String, String) onFilterChanged;

  const _FilterDialog({
    required this.selectedStatus,
    required this.selectedPassType,
    required this.selectedCategory,
    required this.onFilterChanged,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String _tempStatus;
  late String _tempPassType;
  late String _tempCategory;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.selectedStatus;
    _tempPassType = widget.selectedPassType;
    _tempCategory = widget.selectedCategory;
  }

  void _clearAllFilters() {
    setState(() {
      _tempStatus = 'All Status';
      _tempPassType = 'All Types';
      _tempCategory = 'All Categories';
    });
    widget.onFilterChanged(_tempStatus, _tempPassType, _tempCategory);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 400.0 : screenWidth - 32;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildFilterSection(
                'Status',
                AppConstants.statusList,
                _tempStatus,
                (value) {
                  setState(() {
                    _tempStatus = value;
                  });
                  widget.onFilterChanged(
                    _tempStatus,
                    _tempPassType,
                    _tempCategory,
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildFilterSection(
                'Pass Type',
                AppConstants.passTypes,
                _tempPassType,
                (value) {
                  setState(() {
                    _tempPassType = value;
                  });
                  widget.onFilterChanged(
                    _tempStatus,
                    _tempPassType,
                    _tempCategory,
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildFilterSection(
                'Category',
                AppConstants.categories,
                _tempCategory,
                (value) {
                  setState(() {
                    _tempCategory = value;
                  });
                  widget.onFilterChanged(
                    _tempStatus,
                    _tempPassType,
                    _tempCategory,
                  );
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _clearAllFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFFF3F4FF),
                    ),
                    child: Text(
                      'Clear All Filters',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String label,
    List<String> items,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _showCustomDropdown(
                context,
                label,
                items,
                selectedValue,
                onChanged,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedValue,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF374151),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDropdown(
    BuildContext context,
    String label,
    List<String> items,
    String selectedValue,
    Function(String) onChanged,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              maxWidth: 400,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: const Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Items
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == selectedValue;
                      return InkWell(
                        onTap: () {
                          onChanged(item);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
