import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/widgets/bulk_visitor_preview.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/widgets/parser_code.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';

class ExcelDropdown extends StatefulWidget {
  final VoidCallback? onSuccess;
  const ExcelDropdown({super.key, this.onSuccess});

  @override
  State<ExcelDropdown> createState() => _ExcelDropdownState();
}

class _ExcelDropdownState extends State<ExcelDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    const double maxDropdownWidth = 220.0;
    double dropdownWidth =
        screenSize.width - 32 < maxDropdownWidth ? screenSize.width - 32 : maxDropdownWidth;

    // Clamp horizontally so it never overflows
    double left = offset.dx;
    if (left + dropdownWidth > screenSize.width - 16) {
      left = screenSize.width - dropdownWidth - 16;
    }
    if (left < 16) left = 16;

    final double top = offset.dy + size.height + 8;

    return OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          // Tap outside to close
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: dropdownWidth,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        _closeDropdown();

                        if (!mounted) return;

                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['xlsx', 'xls'],
                          withData: true,
                        );

                        if (result == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No file selected"),
                              ),
                            );
                          }
                          return;
                        }

                        List<int>? fileBytes;
                        String fileName = result.files.single.name;

                        if (kIsWeb) {
                          fileBytes = result.files.single.bytes;
                        } else {
                          final path = result.files.single.path;
                          if (path != null) {
                            fileBytes = await File(path).readAsBytes();
                          }
                        }

                        if (fileBytes == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cannot access file data"),
                              ),
                            );
                          }
                          return;
                        }

                        if (!mounted) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          final visitors = await parseExcel(fileBytes);

                          if (mounted) {
                            Navigator.of(context).pop(); // remove loader
                          }

                          if (visitors.isEmpty) {
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Debug: Empty Excel'),
                                  content: const Text(
                                    'Parsed 0 visitors. Check headers and data.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return;
                          }

                          if (mounted) {
                            final success = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BulkVisitorsPreviewScreen(
                                  visitors: visitors,
                                  fileBytes: fileBytes,
                                  fileName: fileName,
                                ),
                              ),
                            );

                            if (success == true && widget.onSuccess != null) {
                              widget.onSuccess!();
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(context).pop(); // remove loader

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Could not preview file. You can still upload it directly.",
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );

                            final success = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BulkVisitorsPreviewScreen(
                                  visitors: const [],
                                  fileBytes: fileBytes,
                                  fileName: fileName,
                                ),
                              ),
                            );

                            if (success == true && widget.onSuccess != null) {
                              widget.onSuccess!();
                            }
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.file_upload,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Import Excel',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                    ),
                    const Divider(height: 1),
                    InkWell(
                      onTap: () {
                        _closeDropdown();
                        _downloadTemplate();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Download Template',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OutlinedButton.icon(
        onPressed: _toggleDropdown,
        icon: Icon(
          Icons.description,
          size: 18,
          color: _isOpen ? AppColors.primary : AppColors.textPrimary,
        ),
        label: Text(
          'Excel',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _isOpen ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          side: BorderSide(
            color: _isOpen ? AppColors.primary : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _isOpen ? AppColors.primaryLight : Colors.white,
        ),
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    const fileName = 'visitor_schedule_1.xlsx';

    try {
      // 🌐 WEB: open as data URL
      if (kIsWeb) {
        final byteData = await rootBundle.load('assets/visitor_schedule_1.xlsx');
        final fileBytes = byteData.buffer.asUint8List();
        final uri = Uri.dataFromBytes(
          fileBytes,
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        await launchUrl(uri);
        return;
      }

      // Load from assets once
      final byteData = await rootBundle.load('assets/visitor_schedule_1.xlsx');
      final Uint8List fileBytes = byteData.buffer.asUint8List();

      String filePath;

      if (Platform.isAndroid) {
        // ✅ Try to save into public Downloads WITHOUT requesting runtime permission
        // This works on many devices; if it fails, we fall back to app directory.
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (!downloadsDir.existsSync()) {
            downloadsDir.createSync(recursive: true);
          }
          filePath = '${downloadsDir.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(fileBytes, flush: true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Template saved in Downloads folder'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Open',
                  textColor: Colors.white,
                  onPressed: () {
                    OpenFile.open(filePath);
                  },
                ),
              ),
            );
          }
          return; // success, no need to fall back
        } catch (e) {
          // Fall back below
          debugPrint('Failed to write to public Downloads, falling back: $e');
        }

        // Fallback: app-specific documents directory
        final docsDir = await getApplicationDocumentsDirectory();
        filePath = '${docsDir.path}/$fileName';
      } else if (Platform.isIOS) {
        // iOS – app documents directory
        final docsDir = await getApplicationDocumentsDirectory();
        filePath = '${docsDir.path}/$fileName';
      } else {
        // Desktop / others
        Directory? directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$fileName';
      }

      final file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Platform.isAndroid
                ? 'Template downloaded (app storage, use Open to view)'
                : 'Template downloaded',
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () {
              OpenFile.open(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error downloading template: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }
}
