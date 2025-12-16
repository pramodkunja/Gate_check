// Force rebuild
import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
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
  List<String> _categories = [];
  bool _isCategoryLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isCategoryLoading = true;
    });

    try {
      final resp = await VisitorApiService().getCategories();
      final data = resp.data;

      if (data is List && data.isNotEmpty) {
        // Map API items to string names and ensure they are unique
        final fetched = data
            .whereType<Map>()
            .map((e) => (e['name'] ?? '').toString())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();

        // Always include "All Categories" at the top
        _categories = ['All Categories', ...fetched];
      } else {
        // Fallback to local constant list
        _categories = AppConstants.categories;
      }
    } on DioException catch (e) {
      debugPrint('Failed to fetch categories: ${e.message}');
      _categories = AppConstants.categories;
      // Optional: show snack if desired
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories, using defaults.'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    } catch (e) {
      debugPrint('Unexpected error loading categories: $e');
      _categories = AppConstants.categories;
    } finally {
      if (mounted) {
        setState(() {
          _isCategoryLoading = false;
        });
      }
    }
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
        categories: _categories,
        isCategoryLoading: _isCategoryLoading,
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
  final List<String> categories;
  final bool isCategoryLoading;

  const _FilterDialog({
    required this.selectedStatus,
    required this.selectedPassType,
    required this.selectedCategory,
    required this.onFilterChanged,
    required this.categories,
    required this.isCategoryLoading,
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

  void _applyFilters() {
    widget.onFilterChanged(_tempStatus, _tempPassType, _tempCategory);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
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
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFilterSection(
                      'Category',
                      // If categories from backend are empty, fallback to constants
                      widget.categories.isNotEmpty
                          ? widget.categories
                          : AppConstants.categories,
                      _tempCategory,
                      (value) {
                        setState(() {
                          _tempCategory = value;
                        });
                      },
                    ),
                    if (widget.isCategoryLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: const [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Loading categories...'),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Apply Filters button (fixed at bottom)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filters',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                    color: Color(0xFF6B7280),
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
        final screenWidth = MediaQuery.of(context).size.width;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
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
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: isSelected ? Colors.white : const Color(0xFF111827),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
