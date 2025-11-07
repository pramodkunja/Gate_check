// Category Card Widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';


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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.poppins(
                      color: category.isActive
                          ? Colors.green
                          : Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

