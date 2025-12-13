import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Result of server-side Excel parsing
class ServerParseResult {
  final bool success;
  final List<Map<String, dynamic>> data;
  final int totalRows;
  final int successfulRows;
  final List<String> errors;
  final String? errorMessage;

  const ServerParseResult({
    required this.success,
    this.data = const [],
    this.totalRows = 0,
    this.successfulRows = 0,
    this.errors = const [],
    this.errorMessage,
  });
}

/// Result of Excel conversion operation (legacy)
class ExcelConversionResult {
  final bool success;
  final Uint8List? xlsxBytes;
  final String? fileName;
  final String? errorMessage;

  const ExcelConversionResult({
    required this.success,
    this.xlsxBytes,
    this.fileName,
    this.errorMessage,
  });
}

/// Service for parsing Excel files using Firebase Cloud Function
/// This bypasses Dart's excel package issues by parsing on the server
class ExcelConversionService {
  // Cloud Function URLs for asia-south1 region
  static const String _parseUrl =
      'https://asia-south1-vehicle-duniya-198e5.cloudfunctions.net/parseExcelFile';
  static const String _convertUrl =
      'https://asia-south1-vehicle-duniya-198e5.cloudfunctions.net/convertXlsToXlsx';

  /// Parse Excel file on server (recommended - handles all formats properly)
  /// Returns parsed JSON data ready for creating auctions
  Future<ServerParseResult> parseExcelOnServer({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      // Encode to base64
      final base64Data = base64Encode(fileBytes);

      // Call Cloud Function via HTTP
      final response = await http.post(
        Uri.parse(_parseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fileBase64': base64Data,
          'fileName': fileName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          final List<dynamic> rawData = data['data'] ?? [];
          final List<Map<String, dynamic>> parsedData =
              rawData.map((e) => Map<String, dynamic>.from(e as Map)).toList();

          final List<dynamic> rawErrors = data['errors'] ?? [];
          final List<String> errors =
              rawErrors.map((e) => e.toString()).toList();

          return ServerParseResult(
            success: true,
            data: parsedData,
            totalRows: data['totalRows'] as int? ?? 0,
            successfulRows: data['successfulRows'] as int? ?? parsedData.length,
            errors: errors,
          );
        }

        return ServerParseResult(
          success: false,
          errorMessage: data['error'] as String? ?? 'Parse failed',
        );
      } else {
        // Try to parse error message from response
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return ServerParseResult(
            success: false,
            errorMessage:
                data['error'] as String? ?? 'Server error: ${response.statusCode}',
          );
        } catch (_) {
          return ServerParseResult(
            success: false,
            errorMessage: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return ServerParseResult(
        success: false,
        errorMessage: 'Failed to parse Excel file: $e',
      );
    }
  }

  /// Convert .xls file to .xlsx format (legacy method)
  /// Use parseExcelOnServer instead for better compatibility
  Future<ExcelConversionResult> convertXlsToXlsx({
    required Uint8List xlsBytes,
    required String fileName,
  }) async {
    try {
      // Check if file is actually .xls
      if (!needsConversion(fileName)) {
        return ExcelConversionResult(
          success: false,
          errorMessage: 'File is not a .xls file',
        );
      }

      // Encode to base64
      final base64Data = base64Encode(xlsBytes);

      // Call Cloud Function via HTTP
      final response = await http.post(
        Uri.parse(_convertUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fileBase64': base64Data,
          'fileName': fileName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['xlsxBase64'] != null) {
          final xlsxBytes = base64Decode(data['xlsxBase64'] as String);
          return ExcelConversionResult(
            success: true,
            xlsxBytes: Uint8List.fromList(xlsxBytes),
            fileName: data['fileName'] as String? ??
                fileName.replaceAll('.xls', '.xlsx'),
          );
        }

        return ExcelConversionResult(
          success: false,
          errorMessage: data['error'] as String? ?? 'Conversion failed',
        );
      } else {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return ExcelConversionResult(
            success: false,
            errorMessage: data['error'] as String? ??
                'Server error: ${response.statusCode}',
          );
        } catch (_) {
          return ExcelConversionResult(
            success: false,
            errorMessage: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return ExcelConversionResult(
        success: false,
        errorMessage: 'Conversion failed: $e',
      );
    }
  }

  /// Check if a file needs conversion (is .xls format)
  static bool needsConversion(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.xls') && !lower.endsWith('.xlsx');
  }

  /// Check if file is an Excel file
  static bool isExcelFile(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.xls') || lower.endsWith('.xlsx');
  }
}
