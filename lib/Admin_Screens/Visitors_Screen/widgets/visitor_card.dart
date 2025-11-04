import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';
import 'action_menu.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/entry_otp.dart';
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

  bool _isScheduledForToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDate = DateTime(
      visitor.visitingDate.year,
      visitor.visitingDate.month,
      visitor.visitingDate.day,
    );
    return visitDate.isAtSameMomentAs(today);
  }

  void _handleApprove(BuildContext context) {
    onUpdate(visitor.id, visitor.copyWith(status: VisitorStatus.approved));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} has been approved'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleReject(BuildContext context) {
    onUpdate(visitor.id, visitor.copyWith(status: VisitorStatus.rejected));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} has been rejected'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
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
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final isPast = visitor.isPast;
    final isToday = _isScheduledForToday();
    final formattedDate = DateFormat('yyyy-MM-dd').format(visitor.visitingDate);

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
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
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.07,
                  backgroundColor: AppColors.background,
                  child: Icon(
                    Icons.person,
                    size: screenWidth * 0.07,
                    color: AppColors.iconGray,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.name,
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.002),
                      Text(
                        'ID: ${visitor.id}',
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.0325,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPast)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pastLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Past',
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w500,
                        color: AppColors.past,
                      ),
                    ),
                  )
                else if (!visitor.isCheckedOut)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: visitor.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      visitor.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w500,
                        color: visitor.status.color,
                      ),
                    ),
                  ),
                SizedBox(width: screenWidth * 0.02),
                ActionMenu(visitor: visitor, onUpdate: onUpdate),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025,
                vertical: screenHeight * 0.005,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business_center,
                    size: screenWidth * 0.035,
                    color: _getCategoryColor(),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    visitor.category,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildInfoRow(
              Icons.phone,
              visitor.phone,
              screenWidth,
              screenHeight,
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildInfoRow(
              Icons.calendar_today,
              formattedDate,
              screenWidth,
              screenHeight,
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildInfoRow(
              Icons.access_time,
              '${visitor.visitingTime} - ${visitor.purpose}',
              screenWidth,
              screenHeight,
            ),
            SizedBox(height: screenHeight * 0.02),
            // Button logic based on conditions
            if (isPast)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleReschedule(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reschedule',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (visitor.isCheckedOut)
              const SizedBox.shrink()
            // For today's visitors with pending status - show Approve/Reject
            else if (isToday && visitor.status == VisitorStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApprove(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Approve',
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleReject(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Reject',
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            // For future dates with pending status - show approved status automatically
            else if (!isToday && visitor.status == VisitorStatus.pending)
              const SizedBox.shrink()
            // For approved visitors (either today after approval or future dates)
            else if (visitor.status == VisitorStatus.approved &&
                !visitor.isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCheckIn(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Check In',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            // For checked-in visitors - show Check Out
            else if (visitor.isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCheckOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Check Out',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
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

  Widget _buildInfoRow(
    IconData icon,
    String text,
    double screenWidth,
    double screenHeight,
  ) {
    return Row(
      children: [
        Icon(icon, size: screenWidth * 0.04, color: AppColors.iconGray),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: screenWidth * 0.035,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
