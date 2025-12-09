import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart ';

class VisitorCard extends StatelessWidget {
  final String name;
  final String time;
  final String status;

  const VisitorCard({
    super.key,
    required this.name,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF8),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Top Row Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.006,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE0E5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "Visitor",
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Status Chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.006,
                ),
                decoration: BoxDecoration(
                  color: status == "Inside"
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.bold,
                    color: status == "Inside" ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: h * 0.02),

          // Name
          Text(
            name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: w * 0.05,
            ),
          ),

          SizedBox(height: h * 0.005),

          // Check-in Time
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: w * 0.035,
              color: Colors.grey[700],
            ),
          ),

          SizedBox(height: h * 0.03),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: h * 0.015,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFB24BFF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  "View Details",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
