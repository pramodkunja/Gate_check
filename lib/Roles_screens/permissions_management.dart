import 'package:flutter/material.dart';
import 'package:gatecheck/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Roles_screens/add_user_dialog.dart';
import 'package:gatecheck/Roles_screens/permission_add_user_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PermissionManagementScreen extends StatefulWidget {
  const PermissionManagementScreen({super.key});

  @override
  State<PermissionManagementScreen> createState() =>
      _PermissionManagementScreenState();
}

class _PermissionManagementScreenState
    extends State<PermissionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Permissions';

  final List<Map<String, dynamic>> Permissions = [
    {
      'name': 'Administrator',
      'id': '#101',
      'status': 'Active',
      'createdBy': 'John Doe',
      'createdDate': '2024-08-12',
      'modifiedDate': '2024-10-15',
    },
    {
      'name': 'Editor',
      'id': '#102',
      'status': 'Inactive',
      'createdBy': 'Jane Smith',
      'createdDate': '2024-07-20',
      'modifiedDate': '2024-09-22',
    },
    {
      'name': 'Viewer',
      'id': '#103',
      'status': 'Active',
      'createdBy': 'Alice Brown',
      'createdDate': '2024-06-14',
      'modifiedDate': '2024-10-01',
    },
  ];

  // Custom colors
  final Color purpleColor = const Color(0xFF7C4585);
  final Color greenColor = const Color(0xFF4CAF50);
  final Color redColor = const Color(0xFFFF6B6B);
  final Color greyColor = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return Scaffold(
      appBar: CustomAppBar(userName: 'Admin', firstLetter: 'A'),
      drawer: Navigation(),
      backgroundColor: greyColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.security_outlined, color: Colors.blue, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Permission\nManagement',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Manage user permissions',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddNewPermissionDialog(
                          onSubmit: (permissionName, isActive) {
                            print('Permission Name: $permissionName');
                            print('Active: $isActive');
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Add Permission',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Statistic Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total Permissions',
                      '12',
                      purpleColor,
                      FontAwesomeIcons.users,
                    ),
                    _buildStatCard(
                      'Active Permissions',
                      '8',
                      greenColor,
                      FontAwesomeIcons.checkCircle,
                    ),
                    _buildStatCard(
                      'Inactive Permissions',
                      '4',
                      redColor,
                      FontAwesomeIcons.timesCircle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search & Filter Section
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search permissions…',
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          items: ['All Permissions', 'Active', 'Inactive']
                              .map(
                                (filter) => DropdownMenuItem<String>(
                                  value: filter,
                                  child: Text(
                                    filter,
                                    style: GoogleFonts.poppins(fontSize: 8),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh, size: 28),
                    color: purpleColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Roles List
              Expanded(
                child: ListView.builder(
                  itemCount: Permissions.length,
                  itemBuilder: (context, index) {
                    final permission = Permissions[index];
                    if (_selectedFilter != 'All Permissions' &&
                        permission['status'] != _selectedFilter) {
                      return const SizedBox.shrink();
                    }
                    if (_searchController.text.isNotEmpty &&
                        !permission['name'].toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        )) {
                      return const SizedBox.shrink();
                    }
                    return _buildPermissionCard(permission, isSmallScreen);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String number,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      width: 160,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
          Text(
            number,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(Map<String, dynamic> permission, bool isSmall) {
    final Color statusColor = permission['status'] == 'Active'
        ? greenColor
        : redColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permission name & status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${permission['name']} (${permission['id']})',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmall ? 16 : 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  permission['status'],
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Created by: ${permission['createdBy']} on ${permission['createdDate']}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            'Modified: ${permission['modifiedDate']}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: purpleColor),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: greenColor),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.delete, color: redColor),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
