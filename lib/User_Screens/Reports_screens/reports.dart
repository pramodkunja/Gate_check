import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({super.key});

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<UserReportsScreen> {
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
    super.build(context);

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: UserAppBar(userName: 'Admin', firstLetter: 'A'),
      drawer: UserNavigation(),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insert_drive_file, color: Colors.blue, size: 28),
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
                        // TabBar
                        TabBar(
                          controller: _tabController,
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                          indicator: BoxDecoration(
                            color: const Color(0xFF6F42C1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize:
                              TabBarIndicatorSize.tab, // 👈 fills entire tab
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

                        // Divider between tabs
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
  final List<String> years = ['2023', '2024', '2025'];
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildOutlinedButton(
                            'Excel',
                            const Color(0xFF00A651),
                          ),
                          _buildOutlinedButton('PDF', const Color(0xFFE53935)),
                          _buildOutlinedButton(
                            'Preview',
                            const Color(0xFF1E88E5),
                          ),
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

  Widget _buildOutlinedButton(String text, Color color) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w500),
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
              'From Time',
              Icons.access_time,
              fromTimeController,
              false,
            ),
            const SizedBox(height: 12),
            _buildDateTimePicker(
              'To Time',
              Icons.access_time,
              toTimeController,
              false,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildButton('Download Excel', const Color(0xFF00A651)),
                _buildButton('Download PDF', const Color(0xFFE53935)),
                _buildButton('Preview', const Color(0xFF1E88E5)),
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
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6F42C1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
