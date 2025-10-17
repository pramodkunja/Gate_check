import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';
import 'action_menu.dart';
import 'package:gatecheck/Visitors_Screen/entry_otp.dart';
import 'reschedule_dialog.dart';

class VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final Function(String, Visitor) onUpdate;

  const VisitorCard({super.key, required this.visitor, required this.onUpdate});

  Color _getCategoryColor() {
    switch (visitor.category.toLowerCase()) {
      case 'vendor':
        return AppColors.primary;
      case 'walk-in':
        return const Color(0xFF0984E3);
      case 'contractor':
        return const Color(0xFFE17055);
      default:
        return AppColors.iconGray;
    }
  }

  void _handleCheckIn(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EntryOtpVerificationScreen(visitorName: visitor.name),
      ),
    );

    if (result == true) {
      onUpdate(visitor.id, visitor.copyWith(isCheckedIn: true));
    }
  }

  void _handleCheckOut(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EntryOtpVerificationScreen(visitorName: visitor.name),
      ),
    );

    if (result == true) {
      onUpdate(
        visitor.id,
        visitor.copyWith(isCheckedOut: true, isCheckedIn: false),
      );
    }
  }

  void _handleReschedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RescheduleDialog(
        visitorName: visitor.name,
        onReschedule: (newDate, newTime) {
          onUpdate(
            visitor.id,
            visitor.copyWith(visitingDate: newDate, visitingTime: newTime),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPast = visitor.isPast;
    final formattedDate = DateFormat('yyyy-MM-dd').format(visitor.visitingDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.background,
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.iconGray,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${visitor.id}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pastLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Past',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.past,
                      ),
                    ),
                  )
                else if (!visitor.isCheckedOut)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: visitor.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      visitor.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: visitor.status.color,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                ActionMenu(visitor: visitor, onUpdate: onUpdate),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business_center,
                    size: 14,
                    color: _getCategoryColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    visitor.category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone, visitor.phone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, formattedDate),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              '${visitor.visitingTime} - ${visitor.purpose}',
            ),
            const SizedBox(height: 16),
            if (isPast)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleReschedule(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reschedule',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (visitor.isCheckedOut)
              const SizedBox.shrink()
            else if (visitor.status == VisitorStatus.pending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCheckIn(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Check In',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (visitor.status == VisitorStatus.approved &&
                !visitor.isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCheckIn(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Check In',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (visitor.isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCheckOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Check Out',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.iconGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
