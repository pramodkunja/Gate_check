import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Categories/models/category_model.dart';
import 'package:gatecheck/Admin_Screens/Categories/widgets/add_edit_dialog.dart';
import 'package:gatecheck/Admin_Screens/Categories/widgets/category_card.dart';
import 'package:gatecheck/Admin_Screens/Categories/widgets/stats_card.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Services/Admin_Services/category_services.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Dashboard_Screens/custom_appbar.dart';

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends State<CategoriesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  String _filterStatus = 'All';
  List<Category> allCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories from API
  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categoriesData = await _categoryService.getAllCategories();
      if (!mounted) return;
      setState(() {
        allCategories = categoriesData
            .map((json) => Category.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Category> get filteredCategories {
    return allCategories.where((category) {
      bool matchesSearch = category.name.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      bool matchesFilter =
          _filterStatus == 'All' ||
          (_filterStatus == 'Active' && category.isActive) ||
          (_filterStatus == 'Inactive' && !category.isActive);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Get stats
  int get totalCategories => allCategories.length;
  int get activeCategories => allCategories.where((c) => c.isActive).length;
  int get inactiveCategories => allCategories.where((c) => !c.isActive).length;
  String get activeRate => totalCategories > 0
      ? '${((activeCategories / totalCategories) * 100).toStringAsFixed(0)}%'
      : '0%';

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => AddOrEditCategoryDialog(
        onSave: (category) async {
          try {
            // Show loading indicator while saving
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
            }

            await _categoryService.createCategory(
              name: category.name,
              description: category.description,
              isActive: category.isActive,
            );

            if (mounted) {
              Navigator.pop(context); // Close loading dialog
              Navigator.pop(context); // Close add dialog

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category added successfully'),
                  backgroundColor: Colors.green,
                ),
              );

              // Refresh on current page
              if (mounted) _loadCategories();
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding category: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

void _editCategory(Category category) {
  showDialog(
    context: context,
    builder: (context) => AddOrEditCategoryDialog(
      category: category,
      onSave: (updatedCategory) async {
        // 1) Show loading
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        try {
          await _categoryService.updateCategory(
            id: category.id,
            name: updatedCategory.name,
            description: updatedCategory.description,
            isActive: updatedCategory.isActive,
          );

          // 2) Close loading
          if (mounted) Navigator.of(context).pop();

          // 3) Close edit dialog
          if (mounted) Navigator.of(context).pop();

          // 4) Notify + refresh
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadCategories();
          }
        } catch (e) {
          // Close loading if open
          if (mounted) Navigator.of(context).pop();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating category: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    ),
  );
}


  void _viewCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          category.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.description.isEmpty
                  ? 'No description'
                  : category.description,
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Text(
              'Status:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(category.isActive ? 'Active' : 'Inactive'),
              backgroundColor: category.isActive
                  ? Colors.green[100]
                  : Colors.grey[300],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: Navigation(currentRoute: 'Categories'),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.category,
                              color: Colors.blue,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Categories\nManagement',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _addCategory,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Category'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage visitor categories and types',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Cards
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          StatsCard(
                            title: 'Total Categories',
                            value: totalCategories.toString(),
                            icon: Icons.list_alt,
                          ),
                          StatsCard(
                            title: 'Active Categories',
                            value: activeCategories.toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          StatsCard(
                            title: 'Inactive Categories',
                            value: inactiveCategories.toString(),
                            icon: Icons.block,
                            color: Colors.grey,
                          ),
                          StatsCard(
                            title: 'Active Rate',
                            value: activeRate,
                            icon: Icons.show_chart,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    // Search & Filter
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search by category name...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _filterStatus,
                          items: ['All', 'Active', 'Inactive']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _filterStatus = value);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filterStatus = 'All';
                            });
                            _loadCategories();
                          },
                          icon: const Icon(Icons.refresh, size: 28),
                          color: Colors.blue,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Category List
                    Expanded(
                      child: filteredCategories.isEmpty
                          ? Center(
                              child: Text(
                                'No categories found',
                                style: GoogleFonts.poppins(),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = filteredCategories[index];
                                return CategoryCard(
                                  category: category,
                                  onEdit: () => _editCategory(category),
                                  onView: () => _viewCategory(category),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
