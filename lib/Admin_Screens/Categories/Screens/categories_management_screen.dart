import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Dashboard_Screens/custom_appbar.dart';

class Category {
  final String name;
  final String description;
  final bool isActive;

  Category({
    required this.name,
    required this.description,
    required this.isActive,
  });
}

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends State<CategoriesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';

  List<Category> allCategories = [
    Category(
      name: 'VIP',
      description: 'Visitors with VIP access',
      isActive: true,
    ),
    Category(name: 'Regular', description: 'Standard visitors', isActive: true),
    Category(
      name: 'Blocked',
      description: 'Visitors with restricted access',
      isActive: false,
    ),
    // Add more categories here
  ];

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

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => AddOrEditCategoryDialog(
        onSave: (category) {
          setState(() {
            allCategories.add(category);
          });
        },
      ),
    );
  }

  void _editCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AddOrEditCategoryDialog(
        category: category,
        onSave: (updatedCategory) {
          setState(() {
            int index = allCategories.indexOf(category);
            allCategories[index] = updatedCategory;
          });
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
              category.description,
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
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
          TextButton(
            onPressed: () {
              setState(() {
                allCategories.remove(category);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(userName: 'Admin', firstLetter: 'A'),
      drawer: Navigation(),
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
                      Icon(Icons.category, color: Colors.blue, size: 28),
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
                      value: '1,234',
                      icon: Icons.list_alt,
                    ),
                    StatsCard(
                      title: 'Active Categories',
                      value: '1,100',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    StatsCard(
                      title: 'Inactive Categories',
                      value: '134',
                      icon: Icons.block,
                      color: Colors.grey,
                    ),
                    StatsCard(
                      title: 'Active Rate',
                      value: '75%',
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
                  // 🔍 Search Field
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

                  // 🔽 Filter Dropdown
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
                      if (value != null) setState(() => _filterStatus = value);
                    },
                  ),

                  const SizedBox(width: 8),

                  // 🔄 Refresh Button beside filter
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _filterStatus = 'All';
                      });
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
                            onDelete: () => _deleteCategory(category),
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

// Stats Card Widget
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        //border: Border.all(color: const Color(0xFF9C27B0)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Colors.blue, size: 28),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Category Card Widget
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        //side: const BorderSide(color: Color(0xFF9C27B0)),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    category.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: category.isActive
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              category.description,
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'Edit',
                  child: IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 20),
                  ),
                ),
                Tooltip(
                  message: 'View',
                  child: IconButton(
                    onPressed: onView,
                    icon: const Icon(Icons.remove_red_eye, size: 20),
                  ),
                ),
                Tooltip(
                  message: 'Delete',
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Add/Edit Category Dialog
class AddOrEditCategoryDialog extends StatefulWidget {
  final Category? category;
  final void Function(Category category) onSave;

  const AddOrEditCategoryDialog({
    super.key,
    this.category,
    required this.onSave,
  });

  @override
  State<AddOrEditCategoryDialog> createState() =>
      _AddOrEditCategoryDialogState();
}

class _AddOrEditCategoryDialogState extends State<AddOrEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.category == null ? 'Add Category' : 'Edit Category',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter category name' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter description' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: '),
                const SizedBox(width: 8),
                DropdownButton<bool>(
                  value: _isActive,
                  items: [
                    DropdownMenuItem(value: true, child: Text('Active')),
                    DropdownMenuItem(value: false, child: Text('Inactive')),
                  ],
                  onChanged: (value) => setState(() => _isActive = value!),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                Category(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  isActive: _isActive,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
