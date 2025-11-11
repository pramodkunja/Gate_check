import 'package:flutter/material.dart';
import 'package:gatecheck/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gate Check',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set initial route
      initialRoute: AppRoutes.login,
      // Use the route generator
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}