import 'package:flutter/material.dart';
// import 'package:gatecheck/Auth_Screens/confirm_password.dart';
import 'package:gatecheck/Auth_Screens/gatecheck_signin.dart';
// import 'package:gatecheck/Dashboard_Screens/dashboard.dart';
// import 'package:gatecheck/gatecheck_signin.dart';
// import 'package:gatecheck/visitors_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GateCheckSignIn(),
    );
  }
}
