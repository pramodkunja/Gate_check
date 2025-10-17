import 'package:flutter/material.dart';
import 'package:gatecheck/Profile_Screen/profile_screen.dart';
import 'package:gatecheck/Auth_Screens/gatecheck_signin.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.userName,
    required this.firstLetter,
    
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final String userName;
  final String firstLetter;
  

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == "profile") {
                // Navigate to profile page if needed
              } else if (value == "signout") {
                // Navigate back to sign-in and clear stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const GateCheckSignIn(),
                  ),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "name",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "teerdavenig@gmail.com",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 8),
                    Text("Profile"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "signout",
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text("Sign out"),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(2), // thickness of the border
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.purple, // border color
                  width: 1, // border width
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
