import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<ReportsScreen> {
  late TabController _tabController;
  String selectedYear = '2025';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();
    super.build(context);

    final size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: const Navigation(),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    color: Colors.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reports',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / 2;
                    return Stack(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                          indicator: BoxDecoration(
                            color: const Color(0xFF6F42C1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          unselectedLabelColor: Colors.black54,
                          labelColor: Colors.white,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.calendar_today),
                              text: 'Monthly Report',
                            ),
                            Tab(
                              icon: Icon(Icons.insert_drive_file_outlined),
                              text: 'Customized Report',
                            ),
                          ],
                        ),
                        Positioned(
                          left: tabWidth - 0.5,
                          top: 8,
                          bottom: 8,
                          child: Container(
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [MonthlyReportTab(), CustomizedReportTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MonthlyReportTab extends StatefulWidget {
  const MonthlyReportTab({super.key});

  @override
  State<MonthlyReportTab> createState() => _MonthlyReportTabState();
}

class _MonthlyReportTabState extends State<MonthlyReportTab> {
  String selectedYear = '2025';
  final List<String> years = ['2023', '2024', '2025', '2026'];
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  bool isLoading = false;
  String? loadingAction;
  int? loadingMonth;

  Future<void> _downloadReport(
    String type,
    int monthIndex,
    bool isPreview,
  ) async {
    setState(() {
      isLoading = true;
      loadingAction = type;
      loadingMonth = monthIndex;
    });

    try {
      final month = monthIndex + 1;
      String endpoint = '';
      String fileName = '';

      if (type == 'PDF') {
        endpoint =
            '/reports/monthly-visitor-pdf/?year=$selectedYear&month=$month${isPreview ? '&preview=true' : ''}';
        fileName = 'Report_${months[monthIndex]}_$selectedYear.pdf';
      } else if (type == 'Excel') {
        endpoint =
            '/reports/monthly-visitor-excel/?year=$selectedYear&month=$month';
        fileName = 'Report_${months[monthIndex]}_$selectedYear.xlsx';
      }

      if (isPreview) {
        // For preview, open in browser or PDF viewer
        final baseUrl = ApiService.baseUrl;
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');
        final previewUrl = '$baseUrl$endpoint';

        debugPrint('🔍 Preview URL: $previewUrl');

        if (kIsWeb) {
          // On web, open in new tab
          if (await canLaunchUrl(Uri.parse(previewUrl))) {
            await launchUrl(
              Uri.parse(previewUrl),
              mode: LaunchMode.externalApplication,
            );
          }
        } else {
          // On mobile, download to temp and open
          final tempDir = await getTemporaryDirectory();
          final tempFile = '${tempDir.path}/preview_$fileName';

          try {
            await ApiService().dio.download(
              endpoint,
              tempFile,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: true,
                validateStatus: (status) => status! < 500,
                headers: {'Authorization': 'Bearer $token'},
              ),
            );

            debugPrint('✅ Preview file downloaded to: $tempFile');
            final result = await OpenFile.open(tempFile);
            debugPrint('📂 Open result: ${result.message}');

            if (result.type != ResultType.done) {
              throw Exception('Could not open file: ${result.message}');
            }
          } catch (e) {
            debugPrint('❌ Preview error: $e');
            rethrow;
          }
        }
      } else {
        // Download file
        await _downloadAndOpenFile(endpoint, fileName, false);
      }

      if (mounted) {
        String message = isPreview
            ? 'Opening preview...'
            : 'File saved to Downloads folder';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');

      if (mounted) {
        String errorMessage = 'Failed to download report';
        if (e.response?.statusCode == 404) {
          errorMessage =
              'No data available for ${months[monthIndex]} $selectedYear';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Server error. Please try again later';
        } else if (e.response?.data != null) {
          errorMessage = ApiService().getErrorMessage(e);
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Download timeout. File might be too large';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ General error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          loadingAction = null;
          loadingMonth = null;
        });
      }
    }
  }

  Future<void> _downloadAndOpenFile(
    String endpoint,
    String fileName,
    bool openFile,
  ) async {
    if (kIsWeb) {
      // For web, construct download URL
      final baseUrl = ApiService.baseUrl;
      final downloadUrl = '$baseUrl$endpoint';
      if (await canLaunchUrl(Uri.parse(downloadUrl))) {
        await launchUrl(
          Uri.parse(downloadUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return;
    }

    // For mobile platforms - use Downloads directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final filePath = '${directory!.path}/$fileName';
    debugPrint('📁 Saving file to: $filePath');

    // Download with progress
    await ApiService().dio.download(
      endpoint,
      filePath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      ),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          debugPrint(
            'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
          );
        }
      },
    );

    debugPrint('✅ File saved successfully at: $filePath');

    // Open the file
    if (openFile) {
      final result = await OpenFile.open(filePath);
      debugPrint('📂 Open file result: ${result.message}');
    } else {
      // Show file location to user with auto-dismiss
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File saved to Downloads folder',
              style: GoogleFonts.poppins(),
            ),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                OpenFile.open(filePath);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Select Year:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: years
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year, style: GoogleFonts.poppins()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedYear = value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: months.length,
            itemBuilder: (context, index) {
              final isLoadingThisMonth = isLoading && loadingMonth == index;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF6F42C1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              months[index],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isLoadingThisMonth)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // --- START: REPLACED WRAP (Option A: force three buttons same line) ---
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const double gap = 8; // same as your Wrap spacing
                          final double available = constraints.maxWidth;

                          // Compute width for each button so 3 buttons fit on one line when possible.
                          // We subtract gaps between buttons (2 gaps for 3 buttons).
                          double buttonWidth = (available - (gap * 2)) / 3;

                          // Clamp to sensible min/max so buttons don't become too small or too wide.
                          if (buttonWidth < 84) buttonWidth = 84;
                          if (buttonWidth > 220) buttonWidth = 220;

                          return Wrap(
                            spacing: gap,
                            runSpacing: 8,
                            children: [
                              SizedBox(
                                width: buttonWidth,
                                child: _buildOutlinedButton(
                                  'Excel',
                                  const Color(0xFF00A651),
                                  index,
                                  isLoadingThisMonth &&
                                      loadingAction == 'Excel',
                                ),
                              ),
                              SizedBox(
                                width: buttonWidth,
                                child: _buildOutlinedButton(
                                  'PDF',
                                  const Color(0xFFE53935),
                                  index,
                                  isLoadingThisMonth && loadingAction == 'PDF',
                                ),
                              ),
                              SizedBox(
                                width: buttonWidth,
                                child: _buildOutlinedButton(
                                  'Preview',
                                  const Color(0xFF1E88E5),
                                  index,
                                  isLoadingThisMonth &&
                                      loadingAction == 'Preview',
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // --- END: REPLACED WRAP ---
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(
    String text,
    Color color,
    int monthIndex,
    bool isLoadingThis,
  ) {
    // Responsive OutlinedButton with icon + spinner while loading.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine available width per button: if infinite, fallback to screen fraction.
        final screenWidth = MediaQuery.of(context).size.width;
        double available =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : screenWidth * 0.3;

        // Some Wrap items may be small; clamp sensible icon/text sizes.
        double iconSize = (available * 0.08);
        if (iconSize < 14) iconSize = 14;
        if (iconSize > 22) iconSize = 22;

        double fontSize = (available * 0.07);
        if (fontSize < 12) fontSize = 12;
        if (fontSize > 16) fontSize = 16;

        IconData? iconData;
        if (text == 'Excel' || text == 'PDF') {
          iconData = Icons.download_rounded;
        } else if (text == 'Preview') {
          iconData = Icons.remove_red_eye_outlined;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 84,
            maxWidth: available < 120 ? 160 : available,
          ),
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (text == 'Excel') {
                      _downloadReport('Excel', monthIndex, false);
                    } else if (text == 'PDF') {
                      _downloadReport('PDF', monthIndex, false);
                    } else if (text == 'Preview') {
                      _downloadReport('PDF', monthIndex, true);
                    }
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isLoading ? Colors.grey : color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledForegroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              foregroundColor: color,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconData != null)
                  SizedBox(
                    width: iconSize + 6,
                    height: iconSize,
                    child: Center(
                      child: isLoadingThis
                          ? SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: CircularProgressIndicator(
                                strokeWidth: (iconSize * 0.12).clamp(1.2, 3.0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                              ),
                            )
                          : Icon(iconData, size: iconSize),
                    ),
                  ),
                if (iconData != null) const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      color: isLoading ? Colors.grey : color,
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomizedReportTab extends StatefulWidget {
  const CustomizedReportTab({super.key});

  @override
  State<CustomizedReportTab> createState() => _CustomizedReportTabState();
}

class _CustomizedReportTabState extends State<CustomizedReportTab> {
  DateTime? fromDate;
  DateTime? toDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController fromTimeController = TextEditingController();
  final TextEditingController toTimeController = TextEditingController();

  bool isLoading = false;
  String? loadingAction;

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    fromTimeController.dispose();
    toTimeController.dispose();
    super.dispose();
  }

  Future<void> _downloadCustomReport(String type, bool isPreview) async {
    // Validate inputs
    if (fromDateController.text.isEmpty || toDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select both dates',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      loadingAction = type;
    });

    try {
      // Format dates for API (YYYY-MM-DD)
      final fromDateFormatted =
          "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}";
      final toDateFormatted =
          "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}";

      String endpoint = '';
      String fileName = '';

      if (type == 'PDF') {
        endpoint =
            '/reports/custom-visitor-pdf/?from_date=$fromDateFormatted&to_date=$toDateFormatted${isPreview ? '&preview=true' : ''}';
        fileName =
            'Custom_Report_${fromDate!.day}-${fromDate!.month}-${fromDate!.year}_to_${toDate!.day}-${toDate!.month}-${toDate!.year}.pdf';
      } else if (type == 'Excel') {
        endpoint =
            '/reports/custom-visitor-excel/?from_date=$fromDateFormatted&to_date=$toDateFormatted';
        fileName =
            'Custom_Report_${fromDate!.day}-${fromDate!.month}-${fromDate!.year}_to_${toDate!.day}-${toDate!.month}-${toDate!.year}.xlsx';
      }

      // Add time parameters if provided
      if (fromTime != null) {
        final fromTimeStr =
            '${fromTime!.hour.toString().padLeft(2, '0')}:${fromTime!.minute.toString().padLeft(2, '0')}';
        endpoint += '&from_time=$fromTimeStr';
      }
      if (toTime != null) {
        final toTimeStr =
            '${toTime!.hour.toString().padLeft(2, '0')}:${toTime!.minute.toString().padLeft(2, '0')}';
        endpoint += '&to_time=$toTimeStr';
      }

      if (isPreview) {
        final baseUrl = ApiService.baseUrl;
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');
        final previewUrl = '$baseUrl$endpoint';

        debugPrint('🔍 Preview URL: $previewUrl');

        if (kIsWeb) {
          if (await canLaunchUrl(Uri.parse(previewUrl))) {
            await launchUrl(
              Uri.parse(previewUrl),
              mode: LaunchMode.externalApplication,
            );
          }
        } else {
          final tempDir = await getTemporaryDirectory();
          final tempFile = '${tempDir.path}/preview_$fileName';

          try {
            await ApiService().dio.download(
              endpoint,
              tempFile,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: true,
                validateStatus: (status) => status! < 500,
                headers: {'Authorization': 'Bearer $token'},
              ),
            );

            debugPrint('✅ Preview file downloaded to: $tempFile');
            final result = await OpenFile.open(tempFile);
            debugPrint('📂 Open result: ${result.message}');

            if (result.type != ResultType.done) {
              throw Exception('Could not open file: ${result.message}');
            }
          } catch (e) {
            debugPrint('❌ Preview error: $e');
            rethrow;
          }
        }
      } else {
        await _downloadAndOpenFile(endpoint, fileName, false);
      }

      if (mounted) {
        String message = isPreview
            ? 'Opening preview...'
            : 'File saved to Downloads folder';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');

      if (mounted) {
        String errorMessage = 'Failed to download report';
        if (e.response?.statusCode == 404) {
          errorMessage = 'No data available for selected date range';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Server error. Please try again later';
        } else if (e.response?.data != null) {
          errorMessage = ApiService().getErrorMessage(e);
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Download timeout. File might be too large';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ General error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          loadingAction = null;
        });
      }
    }
  }

  Future<void> _downloadAndOpenFile(
    String endpoint,
    String fileName,
    bool openFile,
  ) async {
    if (kIsWeb) {
      final baseUrl = ApiService.baseUrl;
      final downloadUrl = '$baseUrl$endpoint';
      if (await canLaunchUrl(Uri.parse(downloadUrl))) {
        await launchUrl(
          Uri.parse(downloadUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    await ApiService().dio.download(
      endpoint,
      filePath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );

    if (openFile) {
      await OpenFile.open(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDateTimePicker(
              'From Date',
              Icons.calendar_today,
              fromDateController,
              true,
            ),
            const SizedBox(height: 12),
            _buildDateTimePicker(
              'To Date',
              Icons.calendar_today,
              toDateController,
              true,
            ),
            const SizedBox(height: 12),
            _buildDateTimePicker(
              'From Time (Optional)',
              Icons.access_time,
              fromTimeController,
              false,
            ),
            const SizedBox(height: 12),
            _buildDateTimePicker(
              'To Time (Optional)',
              Icons.access_time,
              toTimeController,
              false,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton(
                    'Download Excel',
                    const Color(0xFF00A651),
                    'Excel',
                    false,
                  ),
                  _buildButton(
                    'Download PDF',
                    const Color(0xFFE53935),
                    'PDF',
                    false,
                  ),
                  _buildButton('Preview', const Color(0xFF1E88E5), 'PDF', true),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isDate,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        if (isDate) {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2023),
            lastDate: DateTime(2026),
          );
          if (picked != null) {
            controller.text = "${picked.day}-${picked.month}-${picked.year}";
            if (label.contains('From')) {
              fromDate = picked;
            } else {
              toDate = picked;
            }
          }
        } else {
          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            controller.text = picked.format(context);
            if (label.contains('From')) {
              fromTime = picked;
            } else {
              toTime = picked;
            }
          }
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6F42C1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, String type, bool isPreview) {
    // Responsive OutlinedButton with icon + spinner while loading.
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        double available =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : screenWidth * 0.28;

        double iconSize = (available * 0.08);
        if (iconSize < 14) iconSize = 14;
        if (iconSize > 22) iconSize = 22;

        double fontSize = (available * 0.065);
        if (fontSize < 12) fontSize = 12;
        if (fontSize > 16) fontSize = 16;

        IconData? iconData;
        if (text.toLowerCase().contains('excel') ||
            text.toLowerCase().contains('pdf') ||
            type == 'Excel') {
          iconData = Icons.download_rounded;
        } else if (text.toLowerCase().contains('preview') ||
            type == 'PDF' && isPreview) {
          iconData = Icons.remove_red_eye_outlined;
        }

        final isLoadingThis = isLoading && loadingAction == type;

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 100,
            maxWidth: available < 140 ? 200 : available,
          ),
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () => _downloadCustomReport(type, isPreview),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isLoading ? Colors.grey : color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              disabledForegroundColor: Colors.grey,
              foregroundColor: color,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconData != null)
                  SizedBox(
                    width: iconSize + 6,
                    height: iconSize,
                    child: Center(
                      child: isLoadingThis
                          ? SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: CircularProgressIndicator(
                                strokeWidth: (iconSize * 0.12).clamp(1.2, 3.0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                              ),
                            )
                          : Icon(iconData, size: iconSize),
                    ),
                  ),
                if (iconData != null) const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      color: isLoading ? Colors.grey : color,
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
