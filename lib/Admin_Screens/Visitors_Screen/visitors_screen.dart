import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/visitor_model.dart';
import 'utils/colors.dart';
import 'widgets/visitor_card.dart';
import 'widgets/add_visitor_dialog.dart';
import 'widgets/filter_dropdown.dart';
import 'widgets/excel_dropdown.dart';

class RegularVisitorsScreen extends StatefulWidget {
  const RegularVisitorsScreen({super.key});

  @override
  State<RegularVisitorsScreen> createState() => _RegularVisitorsScreenState();
}

class _RegularVisitorsScreenState extends State<RegularVisitorsScreen> {
  List<Visitor> visitors = [];
  List<Visitor> filteredVisitors = [];
  String searchQuery = '';
  String selectedStatus = 'All Status';
  String selectedPassType = 'All Types';
  String selectedCategory = 'All Categories';

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    visitors = [
      Visitor(
        id: '12345',
        name: 'John Doe',
        phone: '+123-456-7890',
        email: 'john@example.com',
        category: 'Vendor',
        passType: 'One Time',
        visitingDate: DateTime(2024, 10, 26),
        visitingTime: '10:30',
        purpose: 'Meeting with marketing team',
        whomToMeet: 'Marketing Department',
        comingFrom: 'ABC Company',
        status: VisitorStatus.approved,
      ),
      Visitor(
        id: '67890',
        name: 'Jane Smith',
        phone: '+098-765-4321',
        email: 'jane@example.com',
        category: 'Walk-In',
        passType: 'One Time',
        visitingDate: DateTime(2024, 10, 27),
        visitingTime: '14:00',
        purpose: 'Interview',
        whomToMeet: 'HR Department',
        comingFrom: 'XYZ Corporation',
        status: VisitorStatus.pending,
      ),
      Visitor(
        id: '54321',
        name: 'Michael Brown',
        phone: '+111-222-3333',
        email: 'michael@example.com',
        category: 'Contractor',
        passType: 'Recurring',
        visitingDate: DateTime(2024, 10, 25),
        visitingTime: '09:00',
        purpose: 'Maintenance',
        whomToMeet: 'Facilities',
        comingFrom: 'BuildCo',
        status: VisitorStatus.approved,
        isCheckedOut: true,
      ),
    ];
    filteredVisitors = visitors;
  }

  void _applyFilters() {
    setState(() {
      filteredVisitors = visitors.where((visitor) {
        bool matchesSearch =
            searchQuery.isEmpty ||
            visitor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            visitor.id.contains(searchQuery) ||
            visitor.phone.contains(searchQuery);

        bool matchesStatus =
            selectedStatus == 'All Status' ||
            visitor.status.displayName == selectedStatus;

        bool matchesPassType =
            selectedPassType == 'All Types' ||
            visitor.passType == selectedPassType;

        bool matchesCategory =
            selectedCategory == 'All Categories' ||
            visitor.category == selectedCategory;

        return matchesSearch &&
            matchesStatus &&
            matchesPassType &&
            matchesCategory;
      }).toList();
    });
  }

  void _addVisitor(Visitor visitor) {
    setState(() {
      // Check if visitor is scheduled for today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final visitDate = DateTime(
        visitor.visitingDate.year,
        visitor.visitingDate.month,
        visitor.visitingDate.day,
      );

      // If scheduled for future date, auto-approve
      final newVisitor = visitDate.isAfter(today)
          ? visitor.copyWith(status: VisitorStatus.approved)
          : visitor;

      visitors.add(newVisitor);
      _applyFilters();
    });
  }

  void _updateVisitor(String id, Visitor updatedVisitor) {
    setState(() {
      final index = visitors.indexWhere((v) => v.id == id);
      if (index != -1) {
        visitors[index] = updatedVisitor;
        _applyFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    return Scaffold(
      drawer: const Navigation(),
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
        email: email,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.025),
            child: Row(
              children: [
                Icon(
                  Icons.group_rounded,
                  size: screenWidth * 0.075,
                  color: AppColors.primary,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "Regular Visitors",
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by Name, ID, or Phone',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: screenWidth * 0.035,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.iconGray,
                        size: screenWidth * 0.06,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.018,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AddVisitorDialog(onAdd: _addVisitor),
                          );
                        },
                        icon: Icon(Icons.add, size: screenWidth * 0.05),
                        label: Text(
                          'Add Visitor',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.018,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    FilterDropdown(
                      selectedStatus: selectedStatus,
                      selectedPassType: selectedPassType,
                      selectedCategory: selectedCategory,
                      onFilterChanged:
                          (String status, String passType, String category) {
                            setState(() {
                              selectedStatus = status;
                              selectedPassType = passType;
                              selectedCategory = category;
                              _applyFilters();
                            });
                          },
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    const ExcelDropdown(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredVisitors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: screenWidth * 0.16,
                          color: AppColors.iconGray,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'No visitors found',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.04,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    itemCount: filteredVisitors.length,
                    itemBuilder: (context, index) {
                      return VisitorCard(
                        visitor: filteredVisitors[index],
                        onUpdate: _updateVisitor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
