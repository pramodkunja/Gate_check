import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:gatecheck/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
      drawer: const Navigation(
        currentRoute: '',
      ),
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

  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true; // No permissions needed for web
    if (!Platform.isAndroid) return true; // iOS handles permissions differently

    // Check Android SDK version
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    // For Android 13+ (SDK 33+), write permission is not required for public downloads
    if (androidInfo.version.sdkInt >= 33) {
      return true;
    }

    // Check current permission status
    PermissionStatus storageStatus = await Permission.storage.status;
    
    // If already granted, return true
    if (storageStatus.isGranted || storageStatus.isLimited) {
      return true;
    }
    
    // Request permission
    PermissionStatus status = await Permission.storage.request();
    
    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      if (mounted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Storage Permission Required', style: GoogleFonts.poppins()),
            content: Text(
              'Please grant storage permission from app settings to download reports.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context, true);
                },
                child: Text('Open Settings', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        );
        return result ?? false;
      }
      return false;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Storage permission is required to download reports',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _downloadReport(
    String type,
    int monthIndex,
    bool isPreview,
  ) async {
    // Request permission before downloading (skip for preview)
    if (!isPreview && !await _requestStoragePermission()) {
      return; // Permission denied, don't proceed
    }

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
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'Report_${months[monthIndex]}_${selectedYear}_$timestamp.pdf';
      } else if (type == 'Excel') {
        endpoint =
            '/reports/monthly-visitor-excel/?year=$selectedYear&month=$month';
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'Report_${months[monthIndex]}_${selectedYear}_$timestamp.xlsx';
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
            // Capture response to inspect status
            final response = await ApiService().dio.download(
              endpoint,
              tempFile,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: false,
                validateStatus: (status) => true, // we handle manually
                headers: {'Authorization': 'Bearer $token'},
              ),
            );

            final statusCode = response.statusCode ?? 0;
            debugPrint('🔎 Monthly preview download status: $statusCode');

            if (statusCode < 200 || statusCode >= 300) {
              debugPrint(
                '❌ Monthly preview download failed. Status: $statusCode, data: ${response.data}',
              );

              // Throw DioException so outer catch handles 404, 500, etc.
              throw DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error:
                    'Failed to download monthly preview. Status: $statusCode',
              );
            }

            debugPrint('✅ Preview file downloaded to: $tempFile');
            final result = await OpenFile.open(tempFile);
            debugPrint('📂 Open result: ${result.message}');

            if (result.type != ResultType.done) {
              throw Exception('Could not open file: ${result.message}');
            }
          } on DioException {
            rethrow;
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
            : 'File saved: $fileName';
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

    // Download with progress + manual status check
    final response = await ApiService().dio.download(
      endpoint,
      filePath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => true, // we check manually
      ),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          debugPrint(
            'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
          );
        }
      },
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      debugPrint('❌ File download failed. Status: $statusCode');
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to download file. Status: $statusCode',
      );
    }

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
                    initialValue: selectedYear,
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
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const double gap = 8;
                          final double available = constraints.maxWidth;

                          double buttonWidth = (available - (gap * 2)) / 3;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        double available =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : screenWidth * 0.3;

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

  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true; // No permissions needed for web
    if (!Platform.isAndroid) return true; // iOS handles permissions differently

    // Check Android SDK version
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    // For Android 13+ (SDK 33+), write permission is not required for public downloads
    if (androidInfo.version.sdkInt >= 33) {
      return true;
    }

    // Check current permission status
    PermissionStatus storageStatus = await Permission.storage.status;
    
    // If already granted, return true
    if (storageStatus.isGranted || storageStatus.isLimited) {
      return true;
    }
    
    // Request permission
    PermissionStatus status = await Permission.storage.request();
    
    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      if (mounted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Storage Permission Required', style: GoogleFonts.poppins()),
            content: Text(
              'Please grant storage permission from app settings to download reports.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context, true);
                },
                child: Text('Open Settings', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        );
        return result ?? false;
      }
      return false;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Storage permission is required to download reports',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

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

    // Request permission before downloading (skip for preview)
    if (!isPreview && !await _requestStoragePermission()) {
      return; // Permission denied, don't proceed
    }

    setState(() {
      isLoading = true;
      loadingAction = type;
    });

    try {
      // Format dates for API (DD-MM-YYYY)
      final fromDateFormatted =
          "${fromDate!.day.toString().padLeft(2, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.year}";
      final toDateFormatted =
          "${toDate!.day.toString().padLeft(2, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.year}";

      String endpoint = '';
      String fileName = '';

      if (type == 'PDF') {
        endpoint =
            '/reports/custom-visitor-pdf/?from_date=$fromDateFormatted&to_date=$toDateFormatted${isPreview ? '&preview=true' : ''}';
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName =
            'Custom_Report_${fromDate!.day}-${fromDate!.month}-${fromDate!.year}_to_${toDate!.day}-${toDate!.month}-${toDate!.year}_$timestamp.pdf';
      } else if (type == 'Excel') {
        endpoint =
            '/reports/custom-visitor-excel/?from_date=$fromDateFormatted&to_date=$toDateFormatted';
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName =
            'Custom_Report_${fromDate!.day}-${fromDate!.month}-${fromDate!.year}_to_${toDate!.day}-${toDate!.month}-${toDate!.year}_$timestamp.xlsx';
      }

      // Add time parameters if provided, else default to full day
      if (fromTime != null) {
        final fromTimeStr =
            '${fromTime!.hour.toString().padLeft(2, '0')}:${fromTime!.minute.toString().padLeft(2, '0')}';
        endpoint += '&from_time=$fromTimeStr';
      } else {
        endpoint += '&from_time=00:00';
      }
      
      if (toTime != null) {
        final toTimeStr =
            '${toTime!.hour.toString().padLeft(2, '0')}:${toTime!.minute.toString().padLeft(2, '0')}';
        endpoint += '&to_time=$toTimeStr';
      } else {
        endpoint += '&to_time=23:59';
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
            final response = await ApiService().dio.download(
              endpoint,
              tempFile,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: false,
                validateStatus: (status) => true, // manual check
                headers: {'Authorization': 'Bearer $token'},
              ),
            );

            final statusCode = response.statusCode ?? 0;
            debugPrint('🔎 Custom preview download status: $statusCode');

            if (statusCode < 200 || statusCode >= 300) {
              debugPrint(
                '❌ Custom preview failed. Status: $statusCode, data: ${response.data}',
              );

              throw DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error:
                    'Failed to download custom preview. Status: $statusCode',
              );
            }

            debugPrint('✅ Preview file downloaded to: $tempFile');
            final result = await OpenFile.open(tempFile);
            debugPrint('📂 Open result: ${result.message}');

            if (result.type != ResultType.done) {
              throw Exception('Could not open file: ${result.message}');
            }
          } on DioException {
            rethrow;
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
            : 'File saved: $fileName';
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
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
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

    // For mobile platforms - use Downloads directory (same as monthly reports)
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
    debugPrint('📁 Saving custom report file to: $filePath');

    // Download with progress + manual status check
    final response = await ApiService().dio.download(
      endpoint,
      filePath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => true, // we check manually
      ),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          debugPrint(
            'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
          );
        }
      },
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      debugPrint('❌ Custom file download failed. Status: $statusCode');
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to download custom file. Status: $statusCode',
      );
    }

    debugPrint('✅ Custom report file saved successfully at: $filePath');

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
                  _buildButton(
                    'Preview',
                    const Color(0xFF1E88E5),
                    'PDF',
                    true,
                  ),
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
          DateTime today = DateTime.now();

          DateTime initialDate = today;
          DateTime firstDate = DateTime(2023);
          DateTime lastDate = today;

          // TO DATE restriction
          if (label.toLowerCase().contains('to') && fromDate != null) {
            initialDate = fromDate!;
            firstDate = fromDate!;
          }

          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );

          if (picked != null) {
            controller.text =
                "${picked.day}-${picked.month}-${picked.year}";

            if (label.toLowerCase().contains('from')) {
              fromDate = picked;
              toDate = null;
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

        setState(() {});
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
            (type == 'PDF' && isPreview)) {
          iconData = Icons.remove_red_eye_outlined;
        }

        final isLoadingThis = isLoading && loadingAction == type;

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 100,
            maxWidth: available < 140 ? 200 : available,
          ),
          child: OutlinedButton(
            onPressed:
                isLoading ? null : () => _downloadCustomReport(type, isPreview),
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
