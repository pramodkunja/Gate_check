import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/widgets/bulk_visitor_preview.dart';
import 'package:gatecheck/Admin_Screens/Visitors_Screen/widgets/parser_code.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
    Overlay.of(context)!.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
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
      builder: (overlayContext) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx - 100,
              top: offset.dy + size.height + 8,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 220,
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

                          // Debug: Confirm tap
                          /*
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Debug'),
                              content: Text('Starting file picker...'),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                            ),
                          );
                          */

                          // pick file
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['xlsx', 'xls'],
                            withData: true, // Important for Web to get bytes
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

                          // parse excel
                          if (!mounted) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            print('DEBUG: Parsing file: $fileName');
                            final visitors = await parseExcel(fileBytes);
                            print('DEBUG: Parsed ${visitors.length} visitors');

                            if (mounted) {
                              Navigator.of(context).pop(); // remove loader
                            }

                            if (visitors.isEmpty) {
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('Debug: Empty Excel'),
                                    content: Text(
                                      'Parsed 0 visitors. Check headers and data.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }

                            // navigate to preview
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

                              print('DEBUG: Parse error: $e');

                              // Automatically fallback to direct upload if parsing fails
                              if (mounted) {
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
                                      visitors: [],
                                      fileBytes: fileBytes,
                                      fileName: fileName,
                                    ),
                                  ),
                                );

                                if (success == true &&
                                    widget.onSuccess != null) {
                                  widget.onSuccess!();
                                }
                              }
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_upload,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Import Excel',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.download_outlined,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Download Template',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
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
    try {
      // 1. Load from assets
      final byteData = await rootBundle.load('assets/visitor_schedule_1.xlsx');
      final fileBytes = byteData.buffer.asUint8List();

      // 5. Save File
      String fileName = 'visitor_schedule_1.xlsx';

      if (kIsWeb) {
        final uri = Uri.dataFromBytes(
          fileBytes,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        await launchUrl(uri);
        return;
      }

      // Request storage permission on Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Storage permission is required to download template',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }

      Directory? directory;
      if (Platform.isWindows) {
        directory = await getDownloadsDirectory();
      } else if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Template saved to Downloads'),
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
