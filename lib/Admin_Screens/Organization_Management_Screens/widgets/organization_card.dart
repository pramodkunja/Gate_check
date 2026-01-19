// widgets/organization_card.dart
import 'package:flutter/material.dart';
import 'package:gatecheck/Admin_Screens/Organization_Management_Screens/models/models.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:gatecheck/Services/User_services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationCard extends StatefulWidget {
  final Organization organization;
  final int? userCount; // Add optional userCount parameter
  final String? userRole;
  final bool? isSuperuser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddUser;
  final VoidCallback onViewUsers;

  const OrganizationCard({
    super.key,
    required this.organization,
    this.userCount, // Optional parameter
    this.userRole,
    this.isSuperuser,
    required this.onEdit,
    required this.onDelete,
    required this.onAddUser,
    required this.onViewUsers,
  });

  @override
  State<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  late String? _resolvedUserRole;
  bool? _resolvedIsSuperuser;

  @override
  void initState() {
    super.initState();
    // Resolve role from passed prop or UserService
    _resolvedUserRole = widget.userRole ?? UserService().getUserRole();
    // If isSuperuser provided, use it; otherwise fetch from ApiService/SharedPreferences
    if (widget.isSuperuser != null) {
      _resolvedIsSuperuser = widget.isSuperuser;
    } else {
      ApiService().isSuperUser().then((v) {
        if (mounted) setState(() => _resolvedIsSuperuser = v);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use passed userCount if available, otherwise fall back to organization.memberCount
    final displayCount = widget.userCount ?? widget.organization.memberCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.organization.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$displayCount members',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: widget.onEdit,
                  color: Colors.purple,
                ),
                // Hide delete for Admin users who are not superusers
                if (!(_resolvedUserRole != null &&
                    _resolvedUserRole!.toLowerCase().trim() == 'admin' &&
                    _resolvedIsSuperuser == false))
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDelete,
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.organization.location,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'PIN: ${widget.organization.pinCode}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              widget.organization.address,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onAddUser,
                    icon: const Icon(Icons.person_add_outlined, size: 20),
                    label: Text('Add User', style: GoogleFonts.poppins()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: const BorderSide(color: Colors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onViewUsers,
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    label: Text('View Users', style: GoogleFonts.poppins()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: const BorderSide(color: Colors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
