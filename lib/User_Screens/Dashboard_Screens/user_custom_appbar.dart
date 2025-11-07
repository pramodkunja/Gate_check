import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatecheck/Auth_Screens/gatecheck_signin.dart';

class UserCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UserCustomAppBar({
    super.key,
    required this.userName,
    required this.firstLetter,
    required this.email,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final String userName;
  final String firstLetter;
  final String email;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.03),
          child: PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == "profile") {
                // Navigation handled in itemBuilder
              } else if (value == "signout") {
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey,
                      ),
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
                    Icon(Icons.person_outline, size: screenWidth * 0.045),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "Profile",
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.033,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "signout",
                child: Row(
                  children: [
                    Icon(Icons.logout, size: screenWidth * 0.045),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "Sign out",
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.033,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.005),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 1),
              ),
              child: CircleAvatar(
                radius: screenWidth * 0.045,
                backgroundColor: Colors.white,
                child: Text(
                  firstLetter,
                  style: GoogleFonts.poppins(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
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