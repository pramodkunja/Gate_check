// dialogs/user_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Organization_Management_Screens/models/models.dart';
import 'package:intl/intl.dart';

class UserDetailsDialog extends StatelessWidget {
  final User user;

  const UserDetailsDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                      'User Details',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
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
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Name', user.name),
                    const SizedBox(height: 16),
                    _buildDetailRow('Email', user.email),
                    const SizedBox(height: 16),
                    _buildDetailRow('Mobile Number', user.mobileNumber),
                    const SizedBox(height: 16),
                    _buildDetailRow('Company', user.companyName),
                    const SizedBox(height: 16),
                    _buildDetailRow('Role', user.role),
                    const SizedBox(height: 16),
                    if (user.aliasName != null) ...[
                      _buildDetailRow('Alias Name', user.aliasName!),
                      const SizedBox(height: 16),
                    ],
                    if (user.block != null) ...[
                      _buildDetailRow('Block/Building', user.block!),
                      const SizedBox(height: 16),
                    ],
                    if (user.floor != null) ...[
                      _buildDetailRow('Floor', user.floor!),
                      const SizedBox(height: 16),
                    ],
                    _buildDetailRow(
                      'Status',
                      user.isActive ? 'Active' : 'Inactive',
                      valueColor: user.isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Date Added',
                      user.dateAdded != null
                          ? DateFormat('yyyy-MM-dd').format(user.dateAdded!)
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            // Action button
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}