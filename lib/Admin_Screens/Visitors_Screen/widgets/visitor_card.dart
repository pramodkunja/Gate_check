import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/entry_otp.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';
import 'action_menu.dart';
import 'reschedule_dialog.dart';

class VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final Function()? onRefresh;

  const VisitorCard({
    super.key,
    required this.visitor,
    this.onRefresh,
  });

  Color _getCategoryColor() {
    switch (visitor.category.toLowerCase()) {
      case 'vendor':
        return AppColors.primary;
      case 'walk-in':
      case 'walk in':
        return const Color(0xFF0984E3);
      case 'contractor':
        return const Color(0xFFE17055);
      default:
        return AppColors.iconGray;
    }
  }

  bool _isScheduledForToday() {
    // Use local times to avoid timezone mismatches
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final localVisit = visitor.visitingDate.toLocal();
    final visitDate = DateTime(localVisit.year, localVisit.month, localVisit.day);

    return visitDate.isAtSameMomentAs(today);
  }

  Future<void> _handleApprove(BuildContext context) async {
    final visitorService = VisitorApiService();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await visitorService.approveVisitor(visitor.id);

      if (context.mounted) {
        Navigator.pop(context); // Remove loading

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${visitor.name} has been approved'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Refresh the list
          if (onRefresh != null) {
            onRefresh!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to approve visitor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visitorService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Visitor', style: GoogleFonts.inter()),
        content: Text(
          'Are you sure you want to reject ${visitor.name}?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reject',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final visitorService = VisitorApiService();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await visitorService.rejectVisitor(visitor.id);

      if (context.mounted) {
        Navigator.pop(context); // Remove loading

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${visitor.name} has been rejected'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );

          // Refresh the list
          if (onRefresh != null) {
            onRefresh!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject visitor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visitorService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EntryOtpScreen(
          visitor: visitor,
          action: EntryExitAction.entry,
        ),
      ),
    );

    if (result == true && onRefresh != null) {
      onRefresh!();
    }
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EntryOtpScreen(
          visitor: visitor,
          action: EntryExitAction.exit,
        ),
      ),
    );

    // If entry_otp reported success, update status to "visited" and refresh list
    if (result == true) {
      final visitorService = VisitorApiService();

      // Optional: show small loading dialog while updating status
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        // NOTE: choose the exact status string your backend expects.
        // I'm using 'visited' here — change to 'VISITED' or other if backend requires uppercase.
        final resp = await visitorService.updateVisitorStatus(
          visitorId: visitor.id,
          status: 'visited',
        );

        if (context.mounted) {
          Navigator.pop(context); // remove loading

          if (resp.statusCode == 200 || resp.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${visitor.name} marked as visited'),
                backgroundColor: AppColors.approved,
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Checked out but failed to update status'),
                backgroundColor: AppColors.rejected,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          if (onRefresh != null) onRefresh!();
        }
      } on DioException catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // remove loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(visitorService.getErrorMessage(e)),
              backgroundColor: Colors.red,
            ),
          );
          if (onRefresh != null) onRefresh!();
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // remove loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unexpected error updating status'),
              backgroundColor: Colors.red,
            ),
          );
          if (onRefresh != null) onRefresh!();
        }
      }
    }
  }

  void _handleReschedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RescheduleDialog(
        visitorId: visitor.id,
        visitorName: visitor.name,
        onSuccess: () {
          if (onRefresh != null) {
            onRefresh!();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Change: don't mark as "Past" if visitor has already checked out.
    // This keeps the post-checkout display consistent even on subsequent days.
    final isPast = visitor.isPast && !visitor.isCheckedOut;
    final isToday = _isScheduledForToday();
    final formattedDate = DateFormat('yyyy-MM-dd').format(visitor.visitingDate.toLocal());

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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.002),
                      Text(
                        'ID: ${visitor.passId}',
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.0325,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Show "Past" badge only when isPast == true
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
                else
                  // For non-past visitors, show status badge.
                  // If visitor has checked out, show "Visited" explicitly.
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: (visitor.isCheckedOut
                              ? AppColors.approved
                              : visitor.status.color)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      visitor.isCheckedOut ? 'Visited' : visitor.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w500,
                        color: visitor.isCheckedOut ? AppColors.approved : visitor.status.color,
                      ),
                    ),
                  ),

                SizedBox(width: screenWidth * 0.02),
                ActionMenu(
                  visitor: visitor,
                  onRefresh: onRefresh,
                ),
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
                  Flexible(
                    child: Text(
                      visitor.category,
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
