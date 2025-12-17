import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/checkin_sucess_screen.dart';
import 'package:gatecheck/Services/Visitor_service/visitor_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

class VisitorVerifyScreen extends StatefulWidget {
  final Map<String, dynamic> visitorData;
  final String otp;

  const VisitorVerifyScreen({
    super.key,
    required this.visitorData,
    required this.otp,
  });

  @override
  State<VisitorVerifyScreen> createState() => _VisitorVerifyScreenState();
}

class _VisitorVerifyScreenState extends State<VisitorVerifyScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _showOtpVerified = true;
  final VisitorApiService _visitorApiService = VisitorApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Hide OTP Verified badge after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showOtpVerified = false;
        });
      }
    });
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error taking picture: $e',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manual Check-In',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.02,
            ),
            child: Column(
              children: [
                // OTP Verified Badge with fade animation
                AnimatedOpacity(
                  opacity: _showOtpVerified ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: _showOtpVerified ? null : 0,
                    child: _showOtpVerified
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4F4DD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF34C759),
                                  size: 18,
                                ),
                                SizedBox(width: size.width * 0.02),
                                Text(
                                  'OTP Verified',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF34C759),
                                    fontSize: isSmallScreen ? 13 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                SizedBox(height: _showOtpVerified ? size.height * 0.03 : 0),

                // Main Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        'Verify visitor details before final check-in',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.03),

                      // Profile Image with Camera Icon
                      Stack(
                        children: [
                          Container(
                            width: size.width * 0.32,
                            height: size.width * 0.32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF0F0F5),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: size.width * 0.16,
                                      color: Colors.grey[400],
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _takePicture,
                              child: Container(
                                width: size.width * 0.1,
                                height: size.width * 0.1,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF7C3AED,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: size.width * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),

                      // Name
                      Text(
                        widget.visitorData['visitor_name'] ?? 'Unknown Visitor',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 22 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),

                      // Phone
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            widget.visitorData['phone'] ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.03),

                      // Category and Purpose
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(size.width * 0.04),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.business_center,
                                        size: isSmallScreen ? 16 : 18,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        'Category',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 12 : 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                    widget.visitorData['category_details']?['name'] ?? 
                                    (widget.visitorData['category']?.toString() ?? 'N/A'),
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 15 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.03),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(size.width * 0.04),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.build,
                                        size: isSmallScreen ? 16 : 18,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        'Purpose',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 12 : 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                    widget.visitorData['purpose_of_visit'] ?? 'N/A',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 15 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),

                      // Issued By with person icon
                      Container(
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Person Icon
                            Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E0F5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: isSmallScreen ? 20 : 24,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Issued By',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  Text(
                                    widget.visitorData['created_by'] ?? 'Admin',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 15 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),

                      // Approve Button
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.065,
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : ElevatedButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              var passId = widget.visitorData['pass_id'];
                              passId ??= widget.visitorData['id']; // Fallback to 'id'
                              
                              if (passId == null) {
                                debugPrint("❌ Pass ID missing. Available keys: ${widget.visitorData.keys.toList()}");
                                throw Exception('Pass ID not found in response');
                              }

                              await _visitorApiService.checkInVisitor(
                                passId: passId.toString(),
                                otp: widget.otp,
                                notes: 'Checked in via App',
                              );

                              if (!context.mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckInSuccessScreen(
                                    visitorName: widget.visitorData['visitor_name'] ?? 'Visitor',
                                    issuedBy: widget.visitorData['created_by_name'] ?? 'Admin',
                                    visitorImage: '', 
                                  ),
                                ),
                              );
                            } on DioException catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _visitorApiService.getErrorMessage(e),
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, color: Colors.white),
                              SizedBox(width: size.width * 0.02),
                              Text(
                                'Approve Check-In',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 15 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),

                      // Cancel Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 15 : 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
