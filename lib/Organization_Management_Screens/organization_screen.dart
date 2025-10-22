// screens/organization_management_screen.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Organization_Management_Screens/models/models.dart';
import 'package:gatecheck/Organization_Management_Screens/widgets/add_user_dialog.dart';
import 'package:gatecheck/Organization_Management_Screens/widgets/addorganization_dialog.dart';
import 'package:gatecheck/Organization_Management_Screens/widgets/organization_card.dart';
import 'package:gatecheck/Organization_Management_Screens/widgets/user_management.dart';

class OrganizationManagementScreen extends StatefulWidget {
  const OrganizationManagementScreen({super.key});

  @override
  State<OrganizationManagementScreen> createState() =>
      _OrganizationManagementScreenState();
}

class _OrganizationManagementScreenState
    extends State<OrganizationManagementScreen> {
  final List<Organization> _organizations = [
    Organization(
      id: '1',
      name: 'Sria Infotech Pvt Ltd',
      location: 'Hyderabad',
      pinCode: '500081',
      address:
          '1ST Floor, 1-121/63, Survey NO 63 Part, Behind Hotel Sitara Grand',
      users: [
        User(
          id: '1',
          name: 'Akshitha',
          email: 'akshithayellanki@gmail.com',
          mobileNumber: '1234567890',
          companyName: 'Sria Infotech Pvt Ltd',
          role: 'Admin',
          block: '4',
          floor: '2',
        ),
        User(
          id: '2',
          name: 'Vineeth',
          email: 'vineetherramalla31@gmail.com',
          mobileNumber: '0987654321',
          companyName: 'Sria Infotech Pvt Ltd',
          role: 'Manager',
        ),
      ],
    ),
    Organization(
      id: '2',
      name: 'Patil',
      location: 'Hyderabad',
      pinCode: '500082',
      address:
          'The Safe Legend, 3rd & 4th Floor, 6-3-1239/8/111 Ranuka Enclave, Raj Bhavan Road, Somajiguda',
      users: [
        User(
          id: '3',
          name: 'John Doe',
          email: 'john.doe@example.com',
          mobileNumber: '123-456-7890',
          companyName: 'Patil',
          role: 'Developer',
          dateAdded: DateTime(2023, 10, 27),
        ),
        User(
          id: '4',
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          mobileNumber: '987-654-3210',
          companyName: 'Patil',
          role: 'Designer',
          dateAdded: DateTime(2023, 10, 26),
        ),
      ],
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Organization> _filteredOrganizations = [];

  @override
  void initState() {
    super.initState();
    _filteredOrganizations = _organizations;
  }

  void _filterOrganizations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrganizations = _organizations;
      } else {
        _filteredOrganizations = _organizations
            .where(
              (org) =>
                  org.name.toLowerCase().contains(query.toLowerCase()) ||
                  org.location.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _addOrganization(Organization org) {
    setState(() {
      _organizations.add(org);
      _filteredOrganizations = _organizations;
    });
  }

  void _updateOrganization(Organization org) {
    setState(() {
      final index = _organizations.indexWhere((o) => o.id == org.id);
      if (index != -1) {
        _organizations[index] = org;
        _filteredOrganizations = _organizations;
      }
    });
  }

  void _deleteOrganization(String id) {
    setState(() {
      _organizations.removeWhere((org) => org.id == id);
      _filteredOrganizations = _organizations;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userName = "Veni"; // you’ll replace with API data later
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
    return Scaffold(
      appBar: CustomAppBar(userName: userName, firstLetter: firstLetter),
      drawer: const Navigation(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organization Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Manage your organizations and their members',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AddOrganizationDialog(onAdd: _addOrganization),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add\nOrganization'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterOrganizations,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Search Organizations...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterOrganizations('');
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredOrganizations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No organizations found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredOrganizations.length,
                      itemBuilder: (context, index) {
                        final org = _filteredOrganizations[index];
                        return OrganizationCard(
                          organization: org,
                          onEdit: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddOrganizationDialog(
                                organization: org,
                                onAdd: _updateOrganization,
                              ),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Organization'),
                                content: Text(
                                  'Are you sure you want to delete ${org.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _deleteOrganization(org.id);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onAddUser: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddUserDialog(
                                companyName: org.name,
                                onAdd: (newUser) {
                                  setState(() {
                                    org.users.add(newUser);
                                  });
                                  _updateOrganization(org);
                                },
                              ),
                            );
                          },
                          onViewUsers: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserManagementScreen(
                                  organization: org,
                                  onUpdate: (updatedOrg) {
                                    _updateOrganization(updatedOrg);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
