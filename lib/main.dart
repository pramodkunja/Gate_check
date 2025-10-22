import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:gatecheck/Auth_Screens/confirm_password.dart';
=======
>>>>>>> 45217eb475fb486bca3486cbba1774e231d1501a
import 'package:gatecheck/Auth_Screens/gatecheck_signin.dart';
import 'package:gatecheck/Dashboard_Screens/dashboard.dart';
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
