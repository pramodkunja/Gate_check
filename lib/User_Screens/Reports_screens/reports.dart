import 'package:flutter/material.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({super.key});

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<UserReportsScreen> {
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
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      appBar: UserCustomAppBar(userName: userName, firstLetter: firstLetter, email: email),
      drawer: const UserNavigation(),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insert_drive_file, color: Colors.blue, size: screenWidth * 0.07),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Reports',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                height: screenHeight * 0.09,
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
                            fontSize: screenWidth * 0.033,
                          ),
                          indicator: BoxDecoration(
                            color: const Color(0xFF6F42C1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          unselectedLabelColor: Colors.black54,
                          labelColor: Colors.white,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.calendar_today, size: screenWidth * 0.05),
                              text: 'Monthly Report',
                            ),
                            Tab(
                              icon: Icon(Icons.insert_drive_file_outlined, size: screenWidth * 0.05),
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
              SizedBox(height: screenHeight * 0.02),
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
  final List<String> years = ['2023', '2024', '2025'];
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
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
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.01,
                      ),
                    ),
                    items: years
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year, style: GoogleFonts.poppins()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedYear = value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: months.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
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
                          Icon(
                            Icons.calendar_today,
                            color: const Color(0xFF6F42C1),
                            size: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Text(
                              months[index],
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.012),
                      Wrap(
                        spacing: screenWidth * 0.02,
                        runSpacing: screenHeight * 0.01,
                        children: [
                          _buildOutlinedButton('Excel', const Color(0xFF00A651), screenWidth),
                          _buildOutlinedButton('PDF', const Color(0xFFE53935), screenWidth),
                          _buildOutlinedButton('Preview', const Color(0xFF1E88E5), screenWidth),
                        ],
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

  Widget _buildOutlinedButton(String text, Color color, double screenWidth) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: screenWidth * 0.033,
        ),
      ),
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

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    fromTimeController.dispose();
    toTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
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
            _buildDateTimePicker('From Date', Icons.calendar_today, fromDateController, true, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.015),
            _buildDateTimePicker('To Date', Icons.calendar_today, toDateController, true, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.015),
            _buildDateTimePicker('From Time', Icons.access_time, fromTimeController, false, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.015),
            _buildDateTimePicker('To Time', Icons.access_time, toTimeController, false, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: screenWidth * 0.02,
              runSpacing: screenHeight * 0.01,
              children: [
                _buildButton('Download Excel', const Color(0xFF00A651), screenWidth),
                _buildButton('Download PDF', const Color(0xFFE53935), screenWidth),
                _buildButton('Preview', const Color(0xFF1E88E5), screenWidth),
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
    double screenWidth,
    double screenHeight,
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
          }
        } else {
          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            controller.text = picked.format(context);
          }
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: screenWidth * 0.035),
        prefixIcon: Icon(icon, color: const Color(0xFF6F42C1), size: screenWidth * 0.055),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, double screenWidth) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.025),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: screenWidth * 0.033,
        ),
      ),
    );
  }
}