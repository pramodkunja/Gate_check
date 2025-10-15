import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:gatecheck/gatecheck_signin.dart';
=======
import 'package:gatecheck/dashboard.dart';
>>>>>>> cb5d09521c6e9743661bc1c243bcd5c0c56826c1

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gate Check',
      home: const GateCheckSignIn(),
    );
=======
    return MaterialApp(home: DashboardScreen());
>>>>>>> cb5d09521c6e9743661bc1c243bcd5c0c56826c1
  }
}
