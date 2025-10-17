import 'package:flutter/material.dart';
import 'package:gatecheck/Dashboard_Screens/custom_appbar.dart';
import 'package:gatecheck/Dashboard_Screens/navigation_drawer.dart';
import 'package:gatecheck/Visitors_Screen/visitors_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate API fetched user data
    String userName = "Veni"; // you’ll replace with API data later
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "?";

    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        userName: userName,
        firstLetter: firstLetter,
      ),
      drawer: const Navigation(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome message
                    Container(
                      padding: const EdgeInsets.all(16),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Here's what's happening with your security system today.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              "Quick Actions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Action Cards
                            _buildActionCard(
                              context: context,
                              color: Colors.purple.shade50,
                              icon: Icons.person_add_alt,
                              label: "Add New Visitor",
                              iconColor: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegularVisitorsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildActionCard(
                              context: context,
                              color: Colors.blue.shade50,
                              icon: Icons.description_outlined,
                              label: "Generate Report",
                              iconColor: Colors.blue,
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const Reports(),
                                //   ),
                                // );
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildActionCard(
                              context: context,
                              color: Colors.green.shade50,
                              icon: Icons.security,
                              label: "Manage Security",
                              iconColor: Colors.green,
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const Organization(),
                                //   ),
                                // );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Visitors section
                    Column(
                      children: [
                        CircleAvatar(
                          radius: isSmall ? 20 : 24,
                          backgroundColor: Colors.purple.shade50,
                          child: Icon(
                            Icons.people_alt,
                            color: Colors.purple,
                            size: isSmall ? 22 : 26,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "56",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "Visitors",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

