// visitor_card.dart
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
  final String? userRole;
  final bool hideMenu;
  final bool hideCheckoutButton;

  const VisitorCard({
    super.key,
    required this.visitor,
    this.onRefresh,
    this.userRole,
    this.hideMenu = false,
    this.hideCheckoutButton = false,
  });

  // Safe refresh to avoid setState-during-build asserts in parent
  void _safeRefresh() {
    if (onRefresh == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (onRefresh != null) onRefresh!();
      } catch (e, st) {
        debugPrint('onRefresh error: $e\n$st');
      }
    });
  }

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

  Color _getDisplayStageColor() {
    final stage = visitor.displayStage.toLowerCase();
    switch (stage) {
      case 'checked_in':
        return AppColors.primary; // Purple for checked-in
      case 'checked_out':
      case 'visited':
        return AppColors.approved; // Green for checked-out/visited
      case 'approved':
        return AppColors.approved; // Green for approved
      case 'pending':
        return Colors.orange; // Orange for pending
      case 'rejected':
        return AppColors.rejected; // Red for rejected
      case 'past':
        return AppColors.past; // Gray for past
      default:
        return AppColors.iconGray; // Default gray
    }
  }

  String _getDisplayStageLabel() {
    final stage = visitor.displayStage;
    // Convert CHECKED_IN to "Checked In", etc.
    return stage
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _getPassTypeLabel() {
    final type = visitor.passType.toUpperCase();
    switch (type) {
      case 'ONE_TIME':
        return 'One-time';
      case 'RECURRING':
        return 'Recurring';
      case 'PERMANENT':
        return 'Permanent';
      default:
        return visitor.passType;
    }
  }

  Color _getPassTypeColor() {
    switch (visitor.passType.toUpperCase()) {
      case 'ONE_TIME':
        return AppColors.primary;
      case 'RECURRING':
        return Colors.orange;
      case 'PERMANENT':
        return Colors.purple;
      default:
        return AppColors.iconGray;
    }
  }

  bool _isScheduledForToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final localVisit = visitor.visitingDate.toLocal();
    final visitDate = DateTime(
      localVisit.year,
      localVisit.month,
      localVisit.day,
    );

    return visitDate.isAtSameMomentAs(today);
  }

  Future<void> _handleApprove(BuildContext context) async {
    final visitorService = VisitorApiService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await visitorService.approveVisitor(visitor.id);

      if (context.mounted) {
        Navigator.pop(context);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${visitor.name} has been approved'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          _safeRefresh();
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
        Navigator.pop(context);
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
            child: Text('Reject', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final visitorService = VisitorApiService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await visitorService.rejectVisitor(visitor.id);

      if (context.mounted) {
        Navigator.pop(context);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${visitor.name} has been rejected'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );

          _safeRefresh();
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visitorService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReschedule(BuildContext context) async {
    // show dialog and refresh on success
    showDialog(
      context: context,
      builder: (context) => RescheduleDialog(
        visitorId: visitor.id,
        visitorName: visitor.name,
        onSuccess: () {
          _safeRefresh();
        },
      ),
    );
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    // Expect EntryOtpScreen to return the OTP string on success
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) =>
            EntryOtpScreen(visitor: visitor, action: EntryExitAction.entry),
      ),
    );

    String? otp;
    if (result is String && result.isNotEmpty) {
      otp = result;
    } else if (result is Map &&
        result['otp'] is String &&
        (result['otp'] as String).isNotEmpty) {
      otp = result['otp'] as String;
    } else if (result == true) {
      // screen returned boolean only — can't proceed without OTP
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP not returned by Entry screen. Cannot check in.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    } else {
      // user cancelled or invalid result
      return;
    }

    final visitorService = VisitorApiService();

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final resp = await visitorService.checkInVisitor(
        passId: visitor.passId,
        otp: otp,
      );

      if (context.mounted) {
        Navigator.pop(context);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${visitor.name} checked in successfully'),
              backgroundColor: AppColors.approved,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check-in failed: ${resp.statusCode}'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        _safeRefresh();
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visitorService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
        _safeRefresh();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unexpected error during check-in'),
            backgroundColor: Colors.red,
          ),
        );
        _safeRefresh();
      }
    }
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    // Expect EntryOtpScreen to return the OTP string on success
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) =>
            EntryOtpScreen(visitor: visitor, action: EntryExitAction.exit),
      ),
    );

    String? otp;
    if (result is String && result.isNotEmpty) {
      otp = result;
    } else if (result is Map &&
        result['otp'] is String &&
        (result['otp'] as String).isNotEmpty) {
      otp = result['otp'] as String;
    } else if (result == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'OTP not returned by Entry screen. Cannot check out.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    } else {
      return;
    }

    final visitorService = VisitorApiService();

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final resp = await visitorService.checkOutVisitor(
        passId: visitor.passId,
        otp: otp,
      );

      if (context.mounted) {
        Navigator.pop(context);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${visitor.name} checked out successfully'),
              backgroundColor: AppColors.approved,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check-out failed: ${resp.statusCode}'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        _safeRefresh();
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visitorService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
        _safeRefresh();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unexpected error during check-out'),
            backgroundColor: Colors.red,
          ),
        );
        _safeRefresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Treat rejected (and other terminal statuses if you add them) as terminal —
    // they should not be considered "past" even if the visitingDate is older.
    final terminalStatuses = {
      VisitorStatus.rejected,
      // Add more terminal statuses here if necessary, e.g.:
      // VisitorStatus.cancelled,
    };

    // previous: final isPast = visitor.isPast && !visitor.isCheckedOut;
    final isPast =
        visitor.isPast &&
        !visitor.isCheckedOut &&
        !terminalStatuses.contains(visitor.status);

    final isToday = _isScheduledForToday();
    final formattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(visitor.visitingDate.toLocal());

    // Normalize role checking - handle various cases
    final role = userRole?.toLowerCase().trim();
    final isSecurity = role == 'security';
    final isAdmin = role == 'admin';

    // If visitor has checked out, do not show any action buttons
    Widget? actionSection;
    if (visitor.isCheckedOut) {
      actionSection = null;
    } else {
      // --- If visitor is past and not checked out, allow reschedule for ALL roles EXCEPT security
      if (isPast) {
        if (!isSecurity) {
          actionSection = SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleReschedule(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
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
          );
        } else {
          actionSection = null;
        }
      }
      // Approve/Reject buttons - Only for Admin or null roles when pending and today
      else if ((isAdmin || role == null) &&
          isToday &&
          visitor.status == VisitorStatus.pending) {
        actionSection = Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleApprove(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
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
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
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
        );
      }
      // Check In button - HIDDEN for all roles (no check-in from card view)
      // else if (isSecurity && visitor.status == VisitorStatus.approved && !visitor.isCheckedIn) {
      //   ... button code removed
      // }
      // Check Out button - HIDDEN for all roles (no check-out from card view)
      // else if (isSecurity && visitor.isCheckedIn && !hideCheckoutButton) {
      //   ... button code removed
      // }
      else {
        actionSection = null;
      }
    }

    // --- Status badge: prefer explicit isCheckedOut / isCheckedIn checks before enum status
    Widget statusBadge() {
      // Prefer backend `current_stage` for display when available
      final ds = visitor.displayStage.toLowerCase();
      if (ds.contains('checked_out') ||
          ds.contains('checked out') ||
          ds.contains('visited')) {
        final color = _getDisplayStageColor();
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.008,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Checked Out',
            style: GoogleFonts.inter(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        );
      }

      if (ds.contains('checked_in') || ds.contains('checked in')) {
        final color = _getDisplayStageColor();
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.008,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Checked In',
            style: GoogleFonts.inter(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        );
      }

      // Fallback to flags if displayStage doesn't indicate checked in/out
      if (visitor.isCheckedOut) {
        final color = _getDisplayStageColor();
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.008,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Checked Out',
            style: GoogleFonts.inter(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        );
      }

      // Checked-in (show explicitly when backend indicates entry_time/is_inside)
      if (visitor.isCheckedIn) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.008,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Checked In',
            style: GoogleFonts.inter(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        );
      }

      // Past (but don't override explicit backend terminal statuses because isPast was adjusted)
      // IMPORTANT: use the computed `isPast` variable (which excludes terminal statuses)
      if (isPast) {
        return Container(
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
        );
      }

      // Default: use displayStage (which prefers currentStage) with color mapping
      final displayColor = _getDisplayStageColor();
      final displayLabel = _getDisplayStageLabel();

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.008,
        ),
        decoration: BoxDecoration(
          color: displayColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          displayLabel,
          style: GoogleFonts.inter(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.w500,
            color: displayColor,
          ),
        ),
      );
    }

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

                // Status badge (uses helper above)
                statusBadge(),

                SizedBox(width: screenWidth * 0.02),
                // ActionMenu - hide reschedule for security and hide entirely if checked out or hideMenu flag is set
                if (!hideMenu && !isSecurity)
                  ActionMenu(
                    visitor: visitor,
                    onRefresh: onRefresh,
                    showReschedule:
                        !isSecurity &&
                        !visitor.isCheckedOut &&
                        visitor.status != VisitorStatus.rejected,
                  ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
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
                SizedBox(width: screenWidth * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.004,
                  ),
                  decoration: BoxDecoration(
                    color: _getPassTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.vpn_key,
                        size: screenWidth * 0.03,
                        color: _getPassTypeColor(),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        _getPassTypeLabel(),
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.028,
                          fontWeight: FontWeight.w500,
                          color: _getPassTypeColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
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
              _formatTimeDisplay(),
              screenWidth,
              screenHeight,
            ),

            // Action buttons section
            if (actionSection != null) ...[
              SizedBox(height: screenHeight * 0.02),
              actionSection,
            ],
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

  /// Format time display: show entry and exit times if available, otherwise visiting time
  String _formatTimeDisplay() {
    // If visitor has entry time, prefer showing entry and exit times
    if (visitor.entryTime != null) {
      final entryStr = DateFormat('HH:mm').format(visitor.entryTime!);
      if (visitor.exitTime != null) {
        final exitStr = DateFormat('HH:mm').format(visitor.exitTime!);
        return '$entryStr - $exitStr';
      } else {
        return 'Entry: $entryStr';
      }
    }
    // Fallback to visiting time and purpose
    return '${visitor.visitingTime} - ${visitor.purpose}';
  }
}
