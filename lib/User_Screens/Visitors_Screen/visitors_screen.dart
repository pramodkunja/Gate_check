import 'package:flutter/material.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/visitor_model.dart';
import 'utils/colors.dart';
import 'widgets/visitor_card.dart';
import 'widgets/add_visitor_dialog.dart';
import 'widgets/filter_dropdown.dart';
import 'widgets/excel_dropdown.dart';

class UserRegularVisitorsScreen extends StatefulWidget {
  const UserRegularVisitorsScreen({super.key});

  @override
  State<UserRegularVisitorsScreen> createState() => _UserRegularVisitorsScreenState();
}

class _UserRegularVisitorsScreenState extends State<UserRegularVisitorsScreen> {
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
      visitors.add(visitor);
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
    String userName = "Veni"; // you’ll replace with API data later
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";

    return Scaffold(
      // backgroundColor: AppColors.background,
      drawer: const UserNavigation(),
      appBar: UserAppBar(userName: userName, firstLetter: firstLetter),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.group_rounded, size: 30, color: AppColors.primary),

                const SizedBox(width: 8),
                Text(
                  "Regular Visitors",
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
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
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.iconGray,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Add Visitor',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    const SizedBox(width: 12),
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
                          size: 64,
                          color: AppColors.iconGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No visitors found',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
