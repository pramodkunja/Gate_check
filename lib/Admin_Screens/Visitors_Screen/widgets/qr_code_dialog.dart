import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/visitor_model.dart';
import '../utils/colors.dart';

class QrCodeDialog extends StatefulWidget {
  final Visitor visitor;

  const QrCodeDialog({super.key, required this.visitor});

  @override
  State<QrCodeDialog> createState() => _QrCodeDialogState();
}

class _QrCodeDialogState extends State<QrCodeDialog> {
  bool _isDownloading = false;

  String _getFullQrUrl() {
    if (widget.visitor.qrCodeUrl == null) return '';
    
    final qrUrl = widget.visitor.qrCodeUrl!;
    
    // If it's already a full URL, return as is
    if (qrUrl.startsWith('http://') || qrUrl.startsWith('https://')) {
      return qrUrl;
    }
    
    // If it starts with /media, prepend the base URL
    if (qrUrl.startsWith('/media')) {
      return 'http://192.168.0.174:7000$qrUrl';
    }
    
    // Otherwise, assume it's a relative path
    return 'http://192.168.0.174:7000/$qrUrl';
  }

  Future<void> _downloadQrCode() async {
    final qrUrl = _getFullQrUrl();
    if (qrUrl.isEmpty) {
      _showMessage('QR code not available', isError: true);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            if (mounted) {
              _showMessage('Storage permission is required', isError: true);
            }
            return;
          }
        }
      }

      // Download the QR code image from the server
      final dio = Dio();
      
      // Get the directory to save
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final String fileName =
            'visitor_qr_${widget.visitor.passId}_${DateTime.now().millisecondsSinceEpoch}.png';
        final String savePath = '${directory.path}/$fileName';

        await dio.download(
          qrUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              debugPrint('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
            }
          },
        );

        if (mounted) {
          _showMessage('QR Code saved to ${directory.path}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to download QR code: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.rejected : AppColors.approved,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final hasQrCode = widget.visitor.qrCodeUrl != null && widget.visitor.qrCodeUrl!.isNotEmpty;
    final qrUrl = _getFullQrUrl();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 450 : screenWidth * 0.9),
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'QR Code Pass',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth < 360 ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: screenWidth * 0.06,
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),
            
            // Visitor Info
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    widget.visitor.name,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth < 360 ? 15 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Pass ID: ${widget.visitor.passId}',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth < 360 ? 13 : 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.06),
            
            // QR Code Image
            if (hasQrCode)
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Image.network(
                  qrUrl,
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('QR Code Error: $error');
                    debugPrint('QR URL: $qrUrl');
                    return Container(
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: screenWidth * 0.12,
                            color: AppColors.rejected,
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                            child: Text(
                              'Failed to load QR code',
                              style: GoogleFonts.inter(
                                fontSize: screenWidth < 360 ? 13 : 14,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Text(
                            'Check network connection',
                            style: GoogleFonts.inter(
                              fontSize: screenWidth < 360 ? 11 : 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: screenWidth * 0.16,
                      color: AppColors.iconGray,
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      'QR Code not available',
                      style: GoogleFonts.inter(
                        fontSize: screenWidth < 360 ? 13 : 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: screenWidth * 0.06),
            
            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isDownloading || !hasQrCode) ? null : _downloadQrCode,
                icon: _isDownloading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.download, size: screenWidth * 0.05),
                label: Text(
                  _isDownloading ? 'Downloading...' : 'Download',
                  style: GoogleFonts.inter(
                    fontSize: screenWidth < 360 ? 15 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              'Present this QR code at the entrance for quick access',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: screenWidth < 360 ? 12 : 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}