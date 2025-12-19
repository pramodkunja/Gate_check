import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart';

class BulkVisitorsPreviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> visitors;
  final List<int>? fileBytes; // Optional: if provided, we upload this file
  final String? fileName;

  const BulkVisitorsPreviewScreen({
    super.key,
    required this.visitors,
    this.fileBytes,
    this.fileName,
  });

  @override
  State<BulkVisitorsPreviewScreen> createState() =>
      _BulkVisitorsPreviewScreenState();
}

class _BulkVisitorsPreviewScreenState extends State<BulkVisitorsPreviewScreen> {
  late List<Map<String, dynamic>> visitors;

  @override
  void initState() {
    super.initState();
    // Deep copy to allow local edits
    visitors = widget.visitors
        .map((v) => Map<String, dynamic>.from(v))
        .toList();
  }

  void _removeRow(int index) {
    setState(() => visitors.removeAt(index));
  }

  void _editRow(int index) async {
    final updated = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => _EditVisitorDialog(visitor: Map.from(visitors[index])),
    );

    if (updated != null) {
      setState(() {
        visitors[index] = updated;
      });
    }
  }

  Future<void> _uploadVisitors() async {
    if (visitors.isEmpty && widget.fileBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No visitors to upload')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Response response;
      
      // 1. If we have parsed visitors (and potentially edited them), generate a new Excel file and upload it
      if (visitors.isNotEmpty) {
         print('DEBUG: Generating Excel from ${visitors.length} visitors...');
         final generatedBytes = _generateExcelBytes(visitors);
         
         if (generatedBytes != null) {
           print('DEBUG: Uploading generated file (Edited Data)');
           response = await ApiService().uploadBulkVisitorsFile(
             fileBytes: generatedBytes,
             fileName: 'edited_visitors.xlsx',
           );
         } else {
           throw Exception("Failed to generate Excel file");
         }
      } 
      // 2. Fallback: If parsing failed (visitors empty) but we have file, upload file directly
      else if (widget.fileBytes != null && widget.fileName != null) {
         print('DEBUG: Uploading original file (Blind Upload): ${widget.fileName}');
         response = await ApiService().uploadBulkVisitorsFile(
           fileBytes: widget.fileBytes!,
           fileName: widget.fileName!,
         );
      } else {
        throw Exception("No data to upload");
      }
      
      print('DEBUG: Upload response status: ${response.statusCode}');
      print('DEBUG: Upload response data: ${response.data}');

      Navigator.of(context).pop(); // remove loader

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitors uploaded successfully')),
        );
        Navigator.of(context).pop(true); // close preview screen with success
      } else {
        // Try to parse backend message using ApiService helper if possible
        String msg = 'Upload failed (${response.statusCode})';
        try {
          if (response.data != null) {
            if (response.data is Map && response.data['detail'] != null) {
              msg = response.data['detail'].toString();
            } else {
              msg = response.data.toString();
            }
          }
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      Navigator.of(context).pop(); // remove loader
      final msg = ApiService().getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = w < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preview Visitors',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          children: [
            Expanded(
              child: visitors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.fileBytes != null
                                ? Icons.file_present
                                : Icons.info_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            widget.fileBytes != null
                                ? 'Preview unavailable for this file.\nYou can still upload it.'
                                : 'No visitors found',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: visitors.length,
                      itemBuilder: (context, idx) {
                        final v = visitors[idx];
                        return Container(
                          margin: EdgeInsets.only(bottom: h * 0.015),
                          padding: EdgeInsets.all(w * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      v['name'] ?? '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmall ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _editRow(idx),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeRow(idx),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  _metaChip(
                                    'Mobile',
                                    v['phone'] ?? '-',
                                  ),
                                  _metaChip(
                                    'Purpose',
                                    v['purpose'] ?? '-',
                                  ),
                                  _metaChip('Date', v['scheduled_date'] ?? '-'),
                                  _metaChip('Time', v['scheduled_time'] ?? '-'),
                                  _metaChip(
                                    'Category',
                                    v['category']?.toString() ?? '-',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // upload button
            SizedBox(
              width: double.infinity,
              height: h * 0.065,
              child: ElevatedButton(
                onPressed: (visitors.isEmpty && widget.fileBytes == null)
                    ? null
                    : _uploadVisitors,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  visitors.isNotEmpty
                      ? 'Upload ${visitors.length} Visitors'
                      : 'Upload File Directly',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 6),
        Text(value, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  List<int>? _generateExcelBytes(List<Map<String, dynamic>> data) {
    try {
      var excel = Excel.createExcel();
      // Rename default sheet to 'Sheet1' or use default
      var sheetName = excel.tables.keys.first;
      var sheet = excel[sheetName];

      if (data.isEmpty) return null;

      // Headers
      var headers = data.first.keys.toList();
      sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

      // Rows
      for (var row in data) {
        List<CellValue> cellValues = [];
        for (var header in headers) {
          var value = row[header];
          if (value == null) {
            cellValues.add(TextCellValue(""));
          } else if (value is int) {
            cellValues.add(IntCellValue(value));
          } else if (value is double) {
            cellValues.add(DoubleCellValue(value));
          } else {
            cellValues.add(TextCellValue(value.toString()));
          }
        }
        sheet.appendRow(cellValues);
      }

      return excel.save();
    } catch (e) {
      print('DEBUG: Error generating Excel: $e');
      return null;
    }
  }
}

class _EditVisitorDialog extends StatefulWidget {
  final Map<String, dynamic> visitor;
  const _EditVisitorDialog({required this.visitor});

  @override
  State<_EditVisitorDialog> createState() => _EditVisitorDialogState();
}

class _EditVisitorDialogState extends State<_EditVisitorDialog> {
  late TextEditingController nameC;
  late TextEditingController mobileC;
  late TextEditingController emailC;
  late TextEditingController dateC;
  late TextEditingController timeC;
  late TextEditingController purposeC;
  late TextEditingController categoryC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(
      text: widget.visitor['name']?.toString() ?? '',
    );
    mobileC = TextEditingController(
      text: widget.visitor['phone']?.toString() ?? '',
    );
    emailC = TextEditingController(
      text: widget.visitor['email']?.toString() ?? '',
    );
    dateC = TextEditingController(
      text: widget.visitor['scheduled_date']?.toString() ?? '',
    );
    timeC = TextEditingController(
      text: widget.visitor['scheduled_time']?.toString() ?? '',
    );
    purposeC = TextEditingController(
      text: widget.visitor['purpose']?.toString() ?? '',
    );
    categoryC = TextEditingController(
      text: widget.visitor['category']?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final w = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: const Text('Edit Visitor'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _field('Name', nameC),
            _field('Mobile', mobileC),
            _field('Email', emailC),
            _field('Date (YYYY-MM-DD)', dateC),
            _field('Time (HH:MM:SS)', timeC),
            _field('Purpose', purposeC),
            _field(
              'Category ID',
              categoryC,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updated = {
              'name': nameC.text.trim(),
              'phone': mobileC.text.trim(),
              'email': emailC.text.trim(),
              'scheduled_date': dateC.text.trim(),
              'scheduled_time': timeC.text.trim(),
              'purpose': purposeC.text.trim(),
              'category':
                  int.tryParse(categoryC.text.trim()) ?? categoryC.text.trim(),
            };
            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
