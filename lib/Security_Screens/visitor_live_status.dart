import 'package:flutter/material.dart';
import 'package:gatecheck/Security_Screens/visitor_card.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitorLiveStatusScreen extends StatefulWidget {
  const VisitorLiveStatusScreen({super.key});

  @override
  State<VisitorLiveStatusScreen> createState() => _VisitorLiveStatusScreenState();
}

class _VisitorLiveStatusScreenState extends State<VisitorLiveStatusScreen> {
  String selectedFilter = "All";

  final filters = ["All", "Inside", "Checked-Out"];

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ---------------- HEADER ----------------
              SizedBox(height: h * 0.05),
              Center(
                child: Text(
                  "Visitor Live Status",
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: h * 0.03),

              // ---------------- FILTER CHIPS ----------------
              SizedBox(
                height: h * 0.055,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    final isActive = selectedFilter == filters[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filters[index];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: w * 0.03),
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.05,
                          vertical: h * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFB24BFF) : const Color(0xFFDAE0E5),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            filters[index],
                            style: GoogleFonts.poppins(
                              color: isActive ? Colors.white : Colors.black87,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              fontSize: w * 0.04,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: h * 0.02),

              // ---------------- LIST OF VISITORS ----------------
              Expanded(
                child: ListView(
                  children: [
                    VisitorCard(
                      name: "Rahul Sharma",
                      time: "Check-in: 09:45 AM",
                      status: "Inside",
                    ),
                    SizedBox(height: h * 0.02),
                    VisitorCard(
                      name: "Megha Kapoor",
                      time: "Check-in: 10:15 AM",
                      status: "Checked-Out",
                    ),
                    SizedBox(height: h * 0.02),
                    VisitorCard(
                      name: "Arun Kumar",
                      time: "Check-in: 11:00 AM",
                      status: "Inside",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

