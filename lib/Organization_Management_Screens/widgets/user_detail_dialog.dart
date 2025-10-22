// dialogs/user_details_dialog.dart
import 'package:flutter/material.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'User Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Name', user.name),
                const SizedBox(height: 16),
                _buildDetailRow('Email', user.email),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}