import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';

class ManualPassDialog extends StatelessWidget {
  final Visitor visitor;

  const ManualPassDialog({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MM/dd/yyyy').format(visitor.visitingDate);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manual Pass',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
            const SizedBox(height: 8),
            Divider(color: AppColors.border, thickness: 1),
            const SizedBox(height: 24),
            _buildInfoRow(
              Icons.person,
              visitor.name,
              visitor.id,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.phone,
              visitor.phone,
              null,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.email,
              visitor.email,
              null,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.calendar_today,
              formattedDate,
              null,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.access_time,
              '${visitor.visitingTime}:00',
              null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, String? subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.iconGray,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}