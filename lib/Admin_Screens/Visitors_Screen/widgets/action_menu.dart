import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';
import 'manual_pass_dialog.dart';
import 'qr_code_dialog.dart';
import 'reschedule_dialog.dart';

class ActionMenu extends StatefulWidget {
  final Visitor visitor;
  final Function()? onRefresh;
  final bool showReschedule;

  const ActionMenu({
    super.key,
    required this.visitor,
    this.onRefresh,
    this.showReschedule = true,
  });

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  // Call onRefresh after current frame to avoid setState during build asserts
  void _safeRefresh() {
    if (widget.onRefresh == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (widget.onRefresh != null) widget.onRefresh!();
      } catch (e, st) {
        debugPrint('ActionMenu onRefresh error: $e\n$st');
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Build list of menu items dynamically based on flags
    final List<Widget> items = [
      _buildMenuItem(
        icon: Icons.description,
        label: 'Manual Pass',
        onTap: () {
          _closeMenu();
          showDialog(
            context: context,
            builder: (context) => ManualPassDialog(visitor: widget.visitor),
          );
        },
      ),
      Divider(height: 1, color: AppColors.border),
      _buildMenuItem(
        icon: Icons.qr_code,
        label: 'QR Pass',
        onTap: () {
          _closeMenu();
          showDialog(
            context: context,
            builder: (context) => QrCodeDialog(visitor: widget.visitor),
          );
        },
      ),
    ];

    // Insert Reschedule item (if allowed) after QR Pass
    // if (widget.showReschedule) {
    //   items.addAll([
    //     Divider(height: 1, color: AppColors.border),
    //     _buildMenuItem(
    //       icon: Icons.calendar_today,
    //       label: 'Reschedule',
    //       onTap: () {
    //         _closeMenu();
    //         // Open reschedule dialog and trigger onSuccess to refresh
    //         showDialog(
    //           context: context,
    //           builder: (context) => RescheduleDialog(
    //             visitorId: widget.visitor.id,
    //             visitorName: widget.visitor.name,
    //             onSuccess: () {
    //               _safeRefresh();
    //             },
    //           ),
    //         );
    //       },
    //     ),
    //   ]);
    // }

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // A full-screen transparent layer to detect taps outside menu
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: (offset.dx - 130).clamp(8.0, MediaQuery.of(context).size.width - 170.0),
              top: offset.dy + size.height + 8,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide entirely when visitor has checked out
    if (widget.visitor.isCheckedOut) {
      return const SizedBox.shrink();
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        icon: Icon(
          Icons.more_vert,
          color: AppColors.iconGray,
        ),
        onPressed: _toggleMenu,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }
}
