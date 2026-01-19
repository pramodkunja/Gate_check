import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/entry_otp_screen.dart';
import 'package:gatecheck/Security_Screens/qr_scanner.dart';
import 'package:gatecheck/Security_Screens/security_custom_appbar.dart';
import 'package:gatecheck/Security_Screens/security_navigation_drawer.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/models/visitor_model.dart'; // Import Visitor model
import 'package:gatecheck/Security_Screens/visitor_list_screen.dart'; // Import Detail Screen

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() =>
      _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  final VisitorApiService _visitorService = VisitorApiService();

  // Stats
  String checkedIn = "-";
  String checkedOut = "-";
  String insidePremises = "-";

  // Lists to hold visitor data
  List<Visitor> insideVisitorsList = [];
  List<Visitor> outsideVisitorsList = [];
  List<Visitor> checkedInVisitorsList = []; // Combined or specific list

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVisitorCounts();
  }

  Future<void> _fetchVisitorCounts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _visitorService.getVisitorStatus(
        companyId: '',
        today: 'true',
      ); // Fetch today's data

      if (response.data != null) {
        final data = response.data;
        // ignore: unused_local_variable
        final counts = data['counts'] ?? {};

        setState(() {
          // Use parsed lists to derive counts so UI matches detail views
          // Parse Inside Premises Visitors (checked in, not checked out)
          if (data['on_premises_visitors'] != null) {
            insideVisitorsList = (data['on_premises_visitors'] as List)
                .map((json) => _mapDashboardJson(json, isInside: true))
                .toList();
          } else {
            insideVisitorsList = [];
          }

          // Parse Outside/Checked-Out Visitors (checked in and checked out)
          if (data['outside_visitors'] != null) {
            outsideVisitorsList = (data['outside_visitors'] as List)
                .map((json) => _mapDashboardJson(json, isInside: false))
                .toList();
          } else {
            outsideVisitorsList = [];
          }

          // Today's Visitors = All who checked in today (both inside and outside)
          checkedInVisitorsList = [
            ...insideVisitorsList,
            ...outsideVisitorsList,
          ];

          // Derive counts from lists so UI count matches detail views
          checkedIn = checkedInVisitorsList.length.toString();
          insidePremises = insideVisitorsList.length.toString();
          checkedOut = outsideVisitorsList.length.toString();

          // Sort by entry time (latest first) for combined today's visitors
          checkedInVisitorsList.sort((a, b) {
            final aTime = a.entryTime ?? DateTime.now();
            final bTime = b.entryTime ?? DateTime.now();
            return bTime.compareTo(aTime);
          });

          // Sort inside visitors by entry time
          insideVisitorsList.sort((a, b) {
            final aTime = a.entryTime ?? DateTime.now();
            final bTime = b.entryTime ?? DateTime.now();
            return bTime.compareTo(aTime);
          });

          // Sort outside visitors by exit time
          outsideVisitorsList.sort((a, b) {
            final aTime = a.exitTime ?? DateTime.now();
            final bTime = b.exitTime ?? DateTime.now();
            return bTime.compareTo(aTime);
          });

          isLoading = false;
        });
      }
    } on DioException catch (e) {
      String msg = _visitorService.getErrorMessage(e);
      setState(() {
        errorMessage = msg;
        isLoading = false;
      });
      _showErrorSnackBar(msg);
    } catch (e, stacktrace) {
      debugPrint("Error parsing dashboard: $e\n$stacktrace");
      setState(() {
        errorMessage = "An unexpected error occurred.";
        isLoading = false;
      });
      _showErrorSnackBar(errorMessage!);
    }
  }

  // Helper to map simplified dashboard JSON to full Visitor object
  Visitor _mapDashboardJson(
    Map<String, dynamic> json, {
    required bool isInside,
  }) {
    // Extract times safely
    DateTime? entry = json['entry_time'] != null
        ? DateTime.tryParse(json['entry_time'])
        : null;
    DateTime? exit = json['exit_time'] != null
        ? DateTime.tryParse(json['exit_time'])
        : null;

    // Use entry time as visiting date fallback, or today
    DateTime visitDate = entry ?? DateTime.now();

    return Visitor(
      id: '', // Missing in dashboard
      passId: json['pass_id']?.toString() ?? '',
      name: json['visitor_name']?.toString() ?? 'Unknown',
      phone: json['mobile_number']?.toString() ?? '',
      email: '', // Missing
      category: json['category']?.toString() ?? 'Visitor',
      passType: json['pass_type']?.toString().toUpperCase() ?? 'ONE_TIME',
      visitingDate: visitDate,
      visitingTime: entry != null ? "${entry.hour}:${entry.minute}" : "00:00",
      purpose: 'N/A', // Missing
      whomToMeet: 'N/A', // Missing
      comingFrom: '',
      status: isInside
          ? VisitorStatus.approved
          : VisitorStatus.approved, // Assumed approved if they entered
      isInside: isInside,
      isCheckedOut: exit != null,
      entryTime: entry,
      exitTime: exit,
    );
  }

  void _navigateToList(String title, List<Visitor> list) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisitorListScreen(
          title: title,
          visitors: list,
          onRefresh: _fetchVisitorCounts,
        ),
      ),
    );
    // Refresh dashboard when returning from list (in case of changes)
    _fetchVisitorCounts();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final bool isSmall = w < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: SecurityCustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      drawer: SecurityNavigation(currentRoute: 'Dashboard'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchVisitorCounts,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Allow refresh even if content is short
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.025),

                  /// Title
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmall ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.purple, width: 1.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back, $userName!",
                          style: GoogleFonts.poppins(
                            fontSize: isSmall ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        SizedBox(height: isSmall ? 4 : 6),
                        Text(
                          "Here's today's Visitor Activity",
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: isSmall ? 12 : 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.025),

                  /// Visitor Statistics Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(w * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _fetchVisitorCounts,
                                    child: const Text("Retry"),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          _visitorCard(
                            context,
                            title: "Today's Visitors",
                            count: checkedIn,
                            bgColor: const Color(0xFFEDEAFF),
                            icon: Icons.login,
                            onTap: () => _navigateToList(
                              "Today's Visitors",
                              checkedInVisitorsList,
                            ),
                          ),

                          SizedBox(height: h * 0.015),

                          _visitorCard(
                            context,
                            title: "Inside Premises",
                            count: insidePremises,
                            bgColor: const Color(0xFFE4FFD9),
                            icon: Icons.people,
                            onTap: () => _navigateToList(
                              'Inside Premises',
                              insideVisitorsList,
                            ),
                          ),

                          SizedBox(height: h * 0.015),

                          _visitorCard(
                            context,
                            title: "Checked-Out Visitors",
                            count: checkedOut,
                            bgColor: const Color(0xFFD6EAFB),
                            icon: Icons.logout,
                            onTap: () => _navigateToList(
                              'Checked Out Visitors',
                              outsideVisitorsList,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.03),

                  /// Quick Actions Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(w * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quick Actions",
                          style: GoogleFonts.poppins(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: h * 0.02),

                        _actionButton(
                          context,
                          title: "Scan QR",
                          bg: const Color(0xFFEDEAFF),
                          icon: Icons.qr_code_scanner,
                          action: 'scan_qr',
                        ),
                        SizedBox(height: h * 0.015),

                        _actionButton(
                          context,
                          title: "OTP Check-In/Out",
                          bg: const Color(0xFFFFE0E3),
                          icon: Icons.edit,
                          action: 'OTP',
                        ),
                        SizedBox(height: h * 0.015),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.025),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Visitor Card
  Widget _visitorCard(
    BuildContext context, {
    required String title,
    required String count,
    required Color bgColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final w = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(w * 0.035),
      child: Container(
        padding: EdgeInsets.all(w * 0.03),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(w * 0.035),
        ),
        child: Row(
          children: [
            Container(
              width: w * 0.10,
              height: w * 0.10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: w * 0.055, color: Colors.black87),
            ),
            SizedBox(width: w * 0.04),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    count,
                    style: GoogleFonts.poppins(
                      fontSize: w * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action Button
  Widget _actionButton(
    BuildContext context, {
    required String title,
    required Color bg,
    required IconData icon,
    required String action,
  }) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () => _onActionTap(context, action),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04),
        height: h * 0.10,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(w * 0.035),
        ),
        child: Row(
          children: [
            Icon(icon, size: w * 0.085, color: Colors.black87),
            SizedBox(width: w * 0.045),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation
  void _onActionTap(BuildContext context, String action) {
    if (action == 'scan_qr') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
    } else if (action == 'OTP') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EntryOtpScreen()),
      );
    }
  }
}
