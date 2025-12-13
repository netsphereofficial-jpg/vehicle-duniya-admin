import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

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
  final FirebaseFunctions _functions;

  ExcelConversionService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-south1');

  /// Convert .xls file to .xlsx format
  /// Returns the converted bytes or null if conversion fails
  Future<ExcelConversionResult> convertXlsToXlsx({
    required Uint8List xlsBytes,
    required String fileName,
  }) async {
    try {
      // Check if file is actually .xls
      if (!fileName.toLowerCase().endsWith('.xls')) {
        return ExcelConversionResult(
          success: false,
          errorMessage: 'File is not a .xls file',
        );
      }

      // Encode to base64
      final base64Data = base64Encode(xlsBytes);

      // Call Cloud Function
      final callable = _functions.httpsCallable(
        'convertXlsToXlsx',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'fileBase64': base64Data,
        'fileName': fileName,
      });

      final data = result.data;

      if (data['success'] == true && data['xlsxBase64'] != null) {
        final xlsxBytes = base64Decode(data['xlsxBase64'] as String);
        return ExcelConversionResult(
          success: true,
          xlsxBytes: Uint8List.fromList(xlsxBytes),
          fileName: data['fileName'] as String? ?? fileName.replaceAll('.xls', '.xlsx'),
        );
      }

      return const ExcelConversionResult(
        success: false,
        errorMessage: 'Conversion failed - no data returned',
      );
    } on FirebaseFunctionsException catch (e) {
      return ExcelConversionResult(
        success: false,
        errorMessage: e.message ?? 'Cloud function error: ${e.code}',
      );
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
