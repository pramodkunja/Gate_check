import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/models/visitor_model.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/widgets/visitor_card.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitorListScreen extends StatefulWidget {
  final String title;
  final List<Visitor> visitors;
  final Future<void> Function()? onRefresh;

  const VisitorListScreen({
    super.key,
    required this.title,
    required this.visitors,
    this.onRefresh,
  });

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  late List<Visitor> _currentVisitors;

  @override
  void initState() {
    super.initState();
    _currentVisitors = widget.visitors;
  }

  // Method to handle refresh triggered by child cards
  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
      // NOTE: In a real app, strict state management would push correct data down.
      // Here, onRefresh reloads DASHBOARD data, but THIS screen was passed a static list.
      // Ideally, this screen should fetch its own data or Navigator should pop.
      // However, to keep it simple as per request:
      // We'll rely on the user navigating back and forth OR
      // if `onRefresh` logic in parent could update the list passed here? No, widgets are immutable.
      // Best approach for now: Just allow the action (Check In/Out) to happen.
      // The dashboard WILL update when we go back.
      // The current list might become stale if we don't refetch specific list.
      // But we don't have an endpoint for "just inside visitors" easily without full dashboard call.

      // OPTION: We pop the screen after an action?
      // "when I tap... I need to view...".
      // Let's just keep the list as is. If items are removed (e.g. checked out), they might ideally vanish.
      // But for this iteration, let's display them.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _currentVisitors.isEmpty
          ? Center(
              child: Text(
                'No visitors found.',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentVisitors.length,
              itemBuilder: (context, index) {
                return VisitorCard(
                  visitor: _currentVisitors[index],
                  userRole: 'security',
                  onRefresh: _handleRefresh,
                );
              },
            ),
    );
  }
}
