import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../utils/colors.dart';

class RescheduleDialog extends StatefulWidget {
  final String visitorId;
  final String visitorName;
  final Function() onSuccess;

  const RescheduleDialog({
    super.key,
    required this.visitorId,
    required this.visitorName,
    required this.onSuccess,
  });

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  final VisitorApiService _visitorService = VisitorApiService();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isSubmitting = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submitReschedule() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select both date and time',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final newDate =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
      final newTime =
          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00';

      final response = await _visitorService.rescheduleVisitor(
        visitorId: widget.visitorId,
        newDate: newDate,
        newTime: newTime,
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Visit rescheduled successfully',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: AppColors.approved,
            ),
          );
          widget.onSuccess();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reschedule visit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_visitorService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final dialogWidth = width > 600 ? 400.0 : width * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(width * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Reschedule Visit',
                    style: GoogleFonts.inter(
                      fontSize: width < 360 ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: width * 0.06,
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Text(
              'Reschedule visit for ${widget.visitorName}',
              style: GoogleFonts.inter(
                fontSize: width < 360 ? 13 : 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: height * 0.03),
            Text(
              'New Visiting Date *',
              style: GoogleFonts.inter(
                fontSize: width < 360 ? 12 : 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: height * 0.01),
            InkWell(
              onTap: isSubmitting ? null : _selectDate,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: height * 0.018,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: isSubmitting ? Colors.grey[100] : Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? '${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year}'
                            : 'mm/dd/yyyy',
                        style: GoogleFonts.inter(
                          fontSize: width < 360 ? 13 : 14,
                          color: selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: width * 0.045,
                      color: AppColors.iconGray,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'New Visiting Time *',
              style: GoogleFonts.inter(
                fontSize: width < 360 ? 12 : 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: height * 0.01),
            InkWell(
              onTap: isSubmitting ? null : _selectTime,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: height * 0.018,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: isSubmitting ? Colors.grey[100] : Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedTime != null
                            ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                            : '--:--',
                        style: GoogleFonts.inter(
                          fontSize: width < 360 ? 13 : 14,
                          color: selectedTime != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.access_time,
                      size: width * 0.045,
                      color: AppColors.iconGray,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.03),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.018,
                      ),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: width < 360 ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitReschedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.018,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Reschedule',
                            style: GoogleFonts.inter(
                              fontSize: width < 360 ? 13 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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