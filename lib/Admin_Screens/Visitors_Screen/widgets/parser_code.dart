import 'dart:io';
import 'package:excel/excel.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

Future<List<Map<String, dynamic>>> parseExcel(List<int> bytes) async {
  try {
    return await _parseExcelOriginal(bytes);
  } catch (e) {
    print('DEBUG: Standard parser failed ($e). Trying fallback parser...');
    return _parseExcelFallback(bytes);
  }
}

Future<List<Map<String, dynamic>>> _parseExcelOriginal(List<int> bytes) async {
  final excel = Excel.decodeBytes(bytes);

  List<Map<String, dynamic>> visitors = [];

  try {
    for (var sheetName in excel.tables.keys) {
      final sheet = excel.tables[sheetName];
      if (sheet == null || sheet.maxRows == 0) continue;

      // First row = headers
      if (sheet.rows.isEmpty) continue;
      
      final headers = <String>[];
      for (var cell in sheet.rows.first) {
        headers.add(_normalizeKey(_getCellValue(cell?.value)));
      }
      print('DEBUG: Found headers: $headers');

      // Loop through rows (skip header)
      for (int r = 1; r < sheet.rows.length; r++) {
        final row = sheet.rows[r];
        Map<String, dynamic> map = {};

        for (int c = 0; c < headers.length; c++) {
          final key = headers[c];
          if (key.isEmpty) continue;

          final cell = c < row.length ? row[c] : null;
          final value = _getCellValue(cell?.value);
          
          if (value.isNotEmpty) {
             map[key] = value;
          }
        }

        if (map.isNotEmpty) {
          visitors.add(map);
        }
      }
    }
  } catch (e, stack) {
    print('DEBUG: Error parsing Excel (Original): $e');
    print(stack);
    rethrow;
  }

  print('DEBUG: Total visitors parsed (Original): ${visitors.length}');
  return visitors;
}

List<Map<String, dynamic>> _parseExcelFallback(List<int> bytes) {
  print('DEBUG: Starting fallback parser...');
  final decoder = SpreadsheetDecoder.decodeBytes(bytes);
  List<Map<String, dynamic>> visitors = [];

  for (var table in decoder.tables.keys) {
    var sheet = decoder.tables[table];
    print('DEBUG: Processing sheet: $table (Max rows: ${sheet?.maxRows})');
    
    if (sheet == null || sheet.maxRows == 0) continue;

    // Headers
    if (sheet.rows.isEmpty) continue;
    var headers = sheet.rows.first.map((e) => _normalizeKey(e?.toString() ?? '')).toList();
    print('DEBUG: Fallback headers: $headers');

    for (var i = 1; i < sheet.rows.length; i++) {
      var row = sheet.rows[i];
      Map<String, dynamic> map = {};
      
      for (var j = 0; j < headers.length; j++) {
        String key = headers[j].toString();
        if (key.isEmpty) continue;
        
        if (j < row.length) {
          var value = row[j]?.toString() ?? '';
          if (value.isNotEmpty) {
            map[key] = value;
          }
        }
      }

      if (map.isNotEmpty) {
        visitors.add(map);
        print('DEBUG: Parsed row $i: $map');
      } else {
        print('DEBUG: Skipped empty row $i');
      }
    }
  }
  
  print('DEBUG: Total visitors parsed (Fallback): ${visitors.length}');
  return visitors;
}

String _getCellValue(CellValue? cellValue) {
  if (cellValue == null) return '';
  
  try {
    if (cellValue is TextCellValue) {
      return cellValue.value.toString().trim();
    } else if (cellValue is IntCellValue) {
      return cellValue.value.toString();
    } else if (cellValue is DoubleCellValue) {
      return cellValue.value.toString();
    } else if (cellValue is DateCellValue) {
      return "${cellValue.year}-${cellValue.month.toString().padLeft(2, '0')}-${cellValue.day.toString().padLeft(2, '0')}";
    } else {
      return cellValue.toString();
    }
  } catch (e) {
    print('DEBUG: Error getting cell value: $e');
    return '';
  }
}

String _normalizeKey(String header) {
  final key = header.toLowerCase().trim().replaceAll(RegExp(r'[\s_]+'), '');
  
  if (['name', 'visitorname', 'fullname'].contains(key)) return 'name';
  if (['phone', 'mobile', 'mobilenumber', 'contact'].contains(key)) return 'phone';
  if (['email', 'email', 'mail'].contains(key)) return 'email';
  if (['date', 'visitingdate', 'scheduleddate', 'visitdate'].contains(key)) return 'scheduled_date';
  if (['time', 'visitingtime', 'scheduledtime', 'visittime'].contains(key)) return 'scheduled_time';
  if (['purpose', 'purpose', 'reason'].contains(key)) return 'purpose';
  if (['category', 'categoryid'].contains(key)) return 'category';
  if (['Company', 'company_name', 'companyname'].contains(key)) return 'company_name';
  
  return header; // Return original if no match
}
