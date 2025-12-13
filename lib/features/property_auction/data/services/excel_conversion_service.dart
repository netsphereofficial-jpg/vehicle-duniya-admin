import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Result of Excel conversion operation
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

/// Service for converting .xls files to .xlsx using Firebase Cloud Function
class ExcelConversionService {
  // Cloud Function URL for asia-south1 region
  static const String _functionUrl =
      'https://asia-south1-vehicle-duniya-198e5.cloudfunctions.net/convertXlsToXlsx';

  /// Convert .xls file to .xlsx format
  /// Returns the converted bytes or null if conversion fails
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
        Uri.parse(_functionUrl),
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
        // Try to parse error message from response
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
}
