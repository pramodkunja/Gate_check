import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'password.dart';

class GateCheckSignIn extends StatefulWidget {
  const GateCheckSignIn({super.key});

  @override
  State<GateCheckSignIn> createState() => _GateCheckSignInState();
}

class _GateCheckSignInState extends State<GateCheckSignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final ApiService _apiService = ApiService();

  final RegExp validInput = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$|^[a-zA-Z0-9._-]+$',
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  Future<void> _validateAndContinue() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;

  final input = _userController.text.trim();
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final userIdRegex = RegExp(r'^[0-9]+$');
  final aliasRegex  = RegExp(r'^[a-zA-Z0-9._-]+$');

  if (!( emailRegex.hasMatch(input)
         || userIdRegex.hasMatch(input)
         || aliasRegex.hasMatch(input)
       )) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter a valid Email, User ID or Alias name."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);
  try {
    final response = await _apiService.validateUser(input);
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SignInScreen(email: input),
          ),
        );
      }
    } else {
      // Handle unexpected non-200 codes
      final errorMsg = response.data['message']?.toString()
                     ?? 'User not found. Please check your UserID, Alias, or Email.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  } on DioException catch (e) {
    setState(() => _isLoading = false);

    String errorMessage = "An error occurred. Please try again.";
    if (e.response?.statusCode == 404) {
      errorMessage = "No account found with this identifier. Please contact your administrator.";
    } else if (e.response?.statusCode == 400) {
      errorMessage = e.response?.data['message']?.toString() ?? "Invalid input format.";
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Connection timeout. Please check your internet connection.";
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = "Cannot connect to server. Please try again later.";
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  } catch (e) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unexpected error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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

                  TextFormField(
                    controller: _userController,
                    enabled: !_isLoading,
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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _validateAndContinue,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                      label: Text(
                        _isLoading ? "Validating..." : "Continue →",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        disabledBackgroundColor: 
                            const Color(0xFF6A1B9A).withOpacity(0.6),
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