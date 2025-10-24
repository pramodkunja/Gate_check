import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Categories/models/category_model.dart';
import 'package:gatecheck/Admin_Screens/Categories/utils/colors.dart';

typedef CategoryCallback = void Function(Category cat);

class CategoryRow extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const CategoryRow({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(category.name)),
          Expanded(flex: 3, child: Text(category.description)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(category.isActive ? 'Active' : 'Inactive'),
                backgroundColor: category.isActive
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.danger.withOpacity(0.12),
                labelStyle: TextStyle(
                  color: category.isActive
                      ? AppColors.success
                      : AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'View',
                  onPressed: onView,
                  icon: const Icon(Icons.remove_red_eye_outlined),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
