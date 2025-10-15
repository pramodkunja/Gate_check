import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'password.dart';

class GateCheckSignIn extends StatefulWidget {
  const GateCheckSignIn({super.key});

  @override
  State<GateCheckSignIn> createState() => _GateCheckSignInState();
}

class _GateCheckSignInState extends State<GateCheckSignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();

  final RegExp validInput = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$|^[a-zA-Z0-9._-]+$',
  );

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveWidth = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Container(
            width: responsiveWidth,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9C27B0)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Section
                  Text(
                    "GATE CHECK",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth < 400 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign In",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "UserID / AliasName / Email",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Input Field
                  TextFormField(
                    controller: _userController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Enter userid / aliasname / email",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFC107),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF6A1B9A),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your User ID, AliasName, or Email.";
                      } else if (!validInput.hasMatch(value.trim())) {
                        return "Invalid format. Enter valid Email or Username.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // First run the form validators (not empty etc.)
                        if (!(_formKey.currentState?.validate() ?? false))
                          return;

                        final input = _userController.text.trim();
                        // Basic email-only regex for navigation decision
                        final emailOnly = RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
                        );

                        if (emailOnly.hasMatch(input)) {
                          // Navigate to the password screen and pass the email
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(email: input),
                            ),
                          );
                        } else {
                          // Show a clear error if the input is not an email
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter a valid email address.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Continue →",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
