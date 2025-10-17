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
<<<<<<< HEAD


      home: const DashboardScreen(),

=======
      title: 'Gate Check',
      home: const DashboardScreen(),
>>>>>>> 955f63d4796e5e44ff567982793265956fcc85d0
    );
  }
}
