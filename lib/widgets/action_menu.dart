import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';
import 'manual_pass_dialog.dart';
import 'qr_code_dialog.dart';

class ActionMenu extends StatefulWidget {
  final Visitor visitor;
  final Function(String, Visitor) onUpdate;

  const ActionMenu({
    super.key,
    required this.visitor,
    required this.onUpdate,
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
    setState(() {
      _isOpen = true;
    });
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx - 130,
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
                    children: [
                      _buildMenuItem(
                        icon: Icons.description,
                        label: 'Manual Pass',
                        onTap: () {
                          _closeMenu();
                          showDialog(
                            context: context,
                            builder: (context) => ManualPassDialog(
                              visitor: widget.visitor,
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                      _buildMenuItem(
                        icon: Icons.qr_code,
                        label: 'QR Pass',
                        onTap: () {
                          _closeMenu();
                          showDialog(
                            context: context,
                            builder: (context) => QrCodeDialog(
                              visitor: widget.visitor,
                            ),
                          );
                        },
                      ),
                    ],
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
            Icon(
              icon,
              size: 18,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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