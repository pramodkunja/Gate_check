import 'package:flutter/material.dart';
import 'package:gatecheck/dashboard.dart';
import 'package:gatecheck/gatecheck_signin.dart';
import 'package:gatecheck/visitors_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gate Check',
<<<<<<< HEAD
      home: const DashboardScreen(),
=======
      home: const RegularVisitorsScreen(),
>>>>>>> f5f77260724d8d3674fa83933e85fd1335d9c1c8
    );
  }
}
