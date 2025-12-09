import 'package:flutter/material.dart';

// Auth Screens
import 'package:gatecheck/Auth_Screens/gatecheck_signin.dart';
import 'package:gatecheck/Auth_Screens/password.dart';

// Admin Screens
import 'package:gatecheck/Admin_Screens/Dashboard_Screens/dashboard_screen.dart';
import 'package:gatecheck/Admin_Screens/Profile_Screen/profile_screen.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/organization_screen.dart';
import 'package:gatecheck/Admin_Screens/Reports_screens/reports.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/visitors_screen.dart';

// User Screens
import 'package:gatecheck/User_Screens/Dashboard_Screens/user_dashboard.dart';
import 'package:gatecheck/User_Screens/Reports_screens/reports.dart';

// Security Screens
import 'package:gatecheck/Security_Screens/security_dashboard.dart';
import 'package:gatecheck/Security_Screens/visitor_live_status.dart';

class AppRoutes {
  // Route Names
  
  // Auth Routes
  static const String login = '/login';
  static const String signIn = '/signin';
  
  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProfile = '/admin/profile';
  static const String adminOrganization = '/admin/organization';
  static const String adminReports = '/admin/reports';
  static const String adminVisitors = '/admin/visitors';
  
  // User Routes
  static const String userDashboard = '/user/dashboard';
  static const String userProfile = '/user/profile';
  static const String userVisitors = '/user/visitors';
  static const String userReports = '/user/reports';

// Security Routes
static const String securityDashboard = '/security/dashboard';
static const String visitorLiveStatus = '/security/visitor-live-status';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case login:
        return MaterialPageRoute(builder: (_) => const GateCheckSignIn());
      
      case signIn:
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => SignInScreen(email: args ?? ''),
        );

      // Admin Routes
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case adminProfile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case adminOrganization:
        return MaterialPageRoute(builder: (_) => const OrganizationManagementScreen());
      
      case adminReports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      
      case adminVisitors:
        return MaterialPageRoute(builder: (_) => const RegularVisitorsScreen());

      // User Routes
      case userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboardScreen());
      
      case userProfile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case userVisitors:
        return MaterialPageRoute(builder: (_) => const RegularVisitorsScreen());
      
      case userReports:
        return MaterialPageRoute(builder: (_) => const UserReportsScreen());

        //security routes
      case securityDashboard:
        return MaterialPageRoute(builder: (_) => const SecurityDashboardScreen());
      case visitorLiveStatus:
        return MaterialPageRoute(builder: (_) => const VisitorLiveStatusScreen());  

      // Default Route
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation Helpers for Admin
  static void navigateToAdminDashboard(BuildContext context, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, adminDashboard);
    } else {
      Navigator.pushNamed(context, adminDashboard);
    }
  }

  static void navigateToAdminProfile(BuildContext context) {
    Navigator.pushNamed(context, adminProfile);
  }

  static void navigateToAdminOrganization(BuildContext context) {
    Navigator.pushNamed(context, adminOrganization);
  }

  static void navigateToAdminReports(BuildContext context) {
    Navigator.pushNamed(context, adminReports);
  }

  static void navigateToAdminVisitors(BuildContext context) {
    Navigator.pushNamed(context, adminVisitors);
  }

  // Navigation Helpers for User
  static void navigateToUserDashboard(BuildContext context, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, userDashboard);
    } else {
      Navigator.pushNamed(context, userDashboard);
    }
  }

  static void navigateToUserProfile(BuildContext context) {
    Navigator.pushNamed(context, adminProfile);
  }

  static void navigateToUserVisitors(BuildContext context) {
    Navigator.pushNamed(context, userVisitors);
  }

  static void navigateToUserReports(BuildContext context) {
    Navigator.pushNamed(context, userReports);
  }

  // Navigation Helper for Login
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }
}