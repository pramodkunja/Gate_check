// widgets/user_card.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.poppins(
                    color: user.isActive ? Colors.green : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.mobileNumber,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          if (user.block != null || user.floor != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (user.block != null) user.block!,
                if (user.floor != null) user.floor!,
              ].join(', '),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
          if (user.dateAdded != null) ...[
            const SizedBox(height: 4),
            Text(
              'Added: ${DateFormat('yyyy-MM-dd').format(user.dateAdded!)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined),
                color: Colors.purple,
                tooltip: 'View Details',
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: Colors.purple,
                tooltip: 'Edit User',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: 'Delete User',
              ),
            ],
          ),
        ],
      ),
    );
  }
}