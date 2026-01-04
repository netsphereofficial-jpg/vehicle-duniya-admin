import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Result of server-side Excel parsing for vehicles
class VehicleServerParseResult {
  final bool success;
  final List<Map<String, dynamic>> data;
  final int totalRows;
  final int successfulRows;
  final List<String> errors;
  final String? errorMessage;

  const VehicleServerParseResult({
    required this.success,
    this.data = const [],
    this.totalRows = 0,
    this.successfulRows = 0,
    this.errors = const [],
    this.errorMessage,
  });
}

/// Service for parsing Vehicle Excel files using Firebase Cloud Function
/// Supports both .xls and .xlsx formats via server-side parsing
class VehicleExcelConversionService {
  // Cloud Function URL for asia-south1 region
  static const String _parseUrl =
      'https://asia-south1-vehicle-duniya-198e5.cloudfunctions.net/parseVehicleExcelFile';

  /// Parse Vehicle Excel file on server (handles both .xls and .xlsx)
  /// Returns parsed JSON data ready for creating vehicles
  Future<VehicleServerParseResult> parseExcelOnServer({
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

          return VehicleServerParseResult(
            success: true,
            data: parsedData,
            totalRows: data['totalRows'] as int? ?? 0,
            successfulRows: data['successfulRows'] as int? ?? parsedData.length,
            errors: errors,
          );
        }

        return VehicleServerParseResult(
          success: false,
          errorMessage: data['error'] as String? ?? 'Parse failed',
        );
      } else {
        // Try to parse error message from response
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return VehicleServerParseResult(
            success: false,
            errorMessage:
                data['error'] as String? ?? 'Server error: ${response.statusCode}',
          );
        } catch (_) {
          return VehicleServerParseResult(
            success: false,
            errorMessage: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return VehicleServerParseResult(
        success: false,
        errorMessage: 'Failed to parse Excel file: $e',
      );
    }
  }

  /// Check if file is an Excel file
  static bool isExcelFile(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.xls') || lower.endsWith('.xlsx');
  }
}
