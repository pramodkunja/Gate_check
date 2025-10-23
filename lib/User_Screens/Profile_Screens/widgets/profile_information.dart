import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/widgets/profile_infoitem.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileInformationSection extends StatelessWidget {
  final String role;
  final String companyName;
  final String userName;
  final String userId;
  final String aliasName;
  final String email;
  final String mobileNumber;
  final String blockBuilding;
  final String floor;
  final String address;
  final String location;
  final String pinCode;

  const UserProfileInformationSection({
    super.key,
    required this.role,
    required this.companyName,
    required this.userName,
    required this.userId,
    required this.aliasName,
    required this.email,
    required this.mobileNumber,
    required this.blockBuilding,
    required this.floor,
    required this.address,
    required this.location,
    required this.pinCode,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ProfileInfoItem(
            icon: Icons.person_outline,
            label: 'Role',
            value: role,
          ),
          ProfileInfoItem(
            icon: Icons.business_outlined,
            label: 'Company Name',
            value: companyName,
          ),
          ProfileInfoItem(
            icon: Icons.person_outline,
            label: 'User Name',
            value: userName,
          ),
          ProfileInfoItem(
            icon: Icons.person_outline,
            label: 'User ID',
            value: userId,
          ),
          ProfileInfoItem(
            icon: Icons.person_outline,
            label: 'Alias Name',
            value: aliasName,
          ),
          ProfileInfoItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
          ),
          ProfileInfoItem(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            value: mobileNumber,
          ),
          ProfileInfoItem(
            icon: Icons.apartment_outlined,
            label: 'Block/Building',
            value: blockBuilding,
          ),
          ProfileInfoItem(
            icon: Icons.layers_outlined,
            label: 'Floor',
            value: floor,
          ),
          ProfileInfoItem(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: address,
          ),
          ProfileInfoItem(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: location,
          ),
          ProfileInfoItem(
            icon: Icons.location_on_outlined,
            label: 'Pin Code',
            value: pinCode,
            isLast: true,
          ),
        ],
      ),
    );
  }
}