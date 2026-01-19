import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitorCard extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final String? exitTime;

  const VisitorCard({
    super.key,
    required this.name,
    required this.time,
    required this.status,
    this.exitTime,
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
          ),
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

              // Status Chip - normalize status and prefer Checked Out when applicable
              Builder(
                builder: (_) {
                  final raw = status;
                  final s = raw.toLowerCase();

                  String displayLabel;
                  Color textColor;
                  Color bgColor;

                  if (s.contains('checked_out') ||
                      s.contains('checked out') ||
                      s.contains('visited') ||
                      s == 'checkedout') {
                    displayLabel = 'Checked Out';
                    textColor = Colors.green;
                    bgColor = Colors.green.withOpacity(0.18);
                  } else if (s.contains('checked_in') ||
                      s.contains('checked in') ||
                      s.contains('inside')) {
                    displayLabel = 'Checked In';
                    textColor = Colors.green;
                    bgColor = Colors.green.withOpacity(0.18);
                  } else {
                    // fallback: capitalize words
                    displayLabel = raw
                        .split(RegExp(r"[_\s]+"))
                        .map(
                          (w) => w.isEmpty
                              ? w
                              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
                        )
                        .join(' ');
                    textColor = Colors.red;
                    bgColor = Colors.red.withOpacity(0.12);
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      displayLabel,
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  );
                },
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
            'Entry: $time',
            style: GoogleFonts.poppins(
              fontSize: w * 0.035,
              color: Colors.grey[700],
            ),
          ),

          // Exit Time (if available)
          if (exitTime != null && exitTime!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: h * 0.005),
              child: Text(
                'Exit: $exitTime',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.035,
                  color: Colors.grey[700],
                ),
              ),
            ),

          SizedBox(height: h * 0.03),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: h * 0.015),
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
