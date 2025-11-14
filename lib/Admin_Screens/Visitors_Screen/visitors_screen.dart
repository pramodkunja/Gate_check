import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:gatecheck/Services/visitor_service.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_custom_appbar.dart';
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_navigation_drawer.dart';
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
  final VisitorApiService _visitorService = VisitorApiService();

  List<Visitor> visitors = [];
  List<Visitor> filteredVisitors = [];
  String searchQuery = '';
  String selectedStatus = 'All Status';
  String selectedPassType = 'All Types';
  String selectedCategory = 'All Categories';

  bool isLoading = false;
  String? errorMessage;

  // Change this to your actual company ID
  static const int companyId = 1;

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _visitorService.getVisitors(companyId);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        setState(() {
          visitors = data.map((json) => Visitor.fromJson(json)).toList();
          _applyFilters();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load visitors';
          isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        errorMessage = _visitorService.getErrorMessage(e);
        isLoading = false;
      });
      _showErrorSnackBar(errorMessage!);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredVisitors = visitors.where((visitor) {
        bool matchesSearch =
            searchQuery.isEmpty ||
            visitor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            visitor.passId.toLowerCase().contains(searchQuery.toLowerCase()) ||
            visitor.phone.contains(searchQuery);

        bool matchesStatus =
            selectedStatus == 'All Status' ||
            visitor.status.displayName == selectedStatus;

        bool matchesPassType =
            selectedPassType == 'All Types' || visitor.passType == selectedPassType;

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

  Future<void> _addVisitor(Map<String, dynamic> visitorData) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _visitorService.createVisitor(visitorData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar('Visitor added successfully');
        await _loadVisitors(); // Reload the list
      } else {
        _showErrorSnackBar('Failed to add visitor');
      }
    } on DioException catch (e) {
      _showErrorSnackBar(_visitorService.getErrorMessage(e));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.approved,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.rejected,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    String userName = UserService().getUserName();
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    String email = UserService().getUserEmail();

    // decide role
  final String? role = UserService().getUserRole();  // assume you add this service method
  final bool isAdmin = (role == null || role == 'admin');

    return Scaffold(
      drawer: isAdmin
        ? const Navigation()  // assume admin drawer
        : const UserNavigation(),  // you should have a user drawer
    appBar: isAdmin
        ? CustomAppBar(
            userName: userName,
            firstLetter: firstLetter,
            email: email,
          )
        : UserCustomAppBar(
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
                        onPressed: isLoading
                            ? null
                            : () {
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: screenWidth * 0.16,
                              color: AppColors.rejected,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.1,
                              ),
                              child: Text(
                                errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.04,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            ElevatedButton.icon(
                              onPressed: _loadVisitors,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.08,
                                  vertical: screenHeight * 0.015,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredVisitors.isEmpty
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
                                  searchQuery.isEmpty
                                      ? 'No visitors found'
                                      : 'No visitors match your search',
                                  style: GoogleFonts.inter(
                                    fontSize: screenWidth * 0.04,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadVisitors,
                            child: ListView.builder(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              itemCount: filteredVisitors.length,
                              itemBuilder: (context, index) {
                                return VisitorCard(
                                  visitor: filteredVisitors[index],
                                  onRefresh: _loadVisitors,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}