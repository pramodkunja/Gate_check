import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'colors.dart';

class ExcelHelper {
  static Future<void> importExcel(BuildContext context) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            if (context.mounted) {
              _showMessage(
                context,
                'Storage permission is required to import files',
                isError: true,
              );
            }
            return;
          }
        }
      }

      // In a real app, you would use file_picker package here
      // For this example, we'll simulate the import
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null && context.mounted) {
        // Simulate successful import
        _showMessage(
          context,
          'Excel file would be imported from: ${directory.path}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage(
          context,
          'Failed to import Excel file: $e',
          isError: true,
        );
      }
    }
  }

  static void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
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
}