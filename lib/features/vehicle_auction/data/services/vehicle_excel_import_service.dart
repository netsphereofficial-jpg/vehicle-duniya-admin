import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/vehicle_item.dart';
import 'excel_conversion_service.dart';

/// Result of Excel parsing
class ExcelImportResult {
  final List<VehicleItem> vehicles;
  final List<String> errors;
  final int totalRows;
  final int successfulRows;

  const ExcelImportResult({
    required this.vehicles,
    required this.errors,
    required this.totalRows,
    required this.successfulRows,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => errors.isEmpty && vehicles.isNotEmpty;
}

/// Service for importing vehicles from Excel files
/// Uses server-side parsing for robust .xls and .xlsx support
class VehicleExcelImportService {
  static const _tag = 'VehicleExcelImportService';

  /// Parse Excel file on server (recommended - handles all formats properly)
  /// Returns ExcelImportResult with vehicles and any errors
  static Future<ExcelImportResult> parseExcelOnServer({
    required Uint8List bytes,
    required String fileName,
    required String auctionId,
  }) async {
    AppLogger.info(_tag, 'Parsing Excel file on server: $fileName');

    final service = VehicleExcelConversionService();
    final result = await service.parseExcelOnServer(
      fileBytes: bytes,
      fileName: fileName,
    );

    if (!result.success) {
      return ExcelImportResult(
        vehicles: [],
        errors: [result.errorMessage ?? 'Failed to parse Excel file'],
        totalRows: 0,
        successfulRows: 0,
      );
    }

    return createVehiclesFromServerData(
      data: result.data,
      auctionId: auctionId,
      serverErrors: result.errors,
      serverTotalRows: result.totalRows,
    );
  }

  /// Create vehicles from server-parsed JSON data
  static ExcelImportResult createVehiclesFromServerData({
    required List<Map<String, dynamic>> data,
    required String auctionId,
    List<String> serverErrors = const [],
    int serverTotalRows = 0,
  }) {
    final vehicles = <VehicleItem>[];
    final errors = <String>[...serverErrors];

    for (int i = 0; i < data.length; i++) {
      try {
        final row = data[i];

        // Helper functions
        String getString(String key, {String defaultValue = ''}) {
          final value = row[key];
          if (value == null) return defaultValue;
          return value.toString().trim();
        }

        double getDouble(String key, {double defaultValue = 0.0}) {
          final value = row[key];
          if (value == null) return defaultValue;
          if (value is num) return value.toDouble();
          final str = value.toString().replaceAll(',', '').replaceAll(' ', '');
          return double.tryParse(str) ?? defaultValue;
        }

        int getInt(String key, {int defaultValue = 0}) {
          final value = row[key];
          if (value == null) return defaultValue;
          if (value is int) return value;
          if (value is double) return value.toInt();
          final str = value.toString().replaceAll(',', '').replaceAll(' ', '');
          return int.tryParse(str) ?? defaultValue;
        }

        DateTime? getDateTime(String key) {
          final value = row[key];
          if (value == null) return null;
          if (value is DateTime) return value;
          final str = value.toString();
          if (str.isEmpty) return null;
          try {
            return DateTime.parse(str);
          } catch (_) {
            return null;
          }
        }

        bool getBool(String key, {bool defaultValue = false}) {
          final value = row[key];
          if (value == null) return defaultValue;
          if (value is bool) return value;
          final str = value.toString().toLowerCase();
          return str == 'true' || str == 'yes' || str == '1' || str == 'available';
        }

        List<String> getImages(String key) {
          final value = row[key];
          if (value == null) return [];
          if (value is List) {
            return value.map((e) => e.toString()).toList();
          }
          if (value is String) {
            if (value.isEmpty) return [];
            try {
              final parsed = jsonDecode(value);
              if (parsed is List) {
                return parsed.map((e) => e.toString()).toList();
              }
            } catch (_) {
              // Not JSON, treat as single URL
              if (value.startsWith('http')) {
                return [value];
              }
            }
          }
          return [];
        }

        // Check for required fields
        final contractNo = getString('contractNo');
        final rcNo = getString('rcNo');
        final make = getString('make');

        if (contractNo.isEmpty && rcNo.isEmpty) {
          continue; // Skip rows without identifiers
        }

        if (make.isEmpty) {
          continue; // Skip rows without make
        }

        // Determine RC availability
        bool rcAvailable = getBool('rcAvailable');
        if (!rcAvailable) {
          final rcStatus = getString('rcStatus').toLowerCase();
          rcAvailable = rcStatus.contains('available') ||
                        rcStatus == 'yes' ||
                        rcStatus == 'true';
        }

        // Use variant as chassisDesc if available
        final variant = getString('variant');
        final assetDesc = getString('assetDesc');
        final chassisDesc = variant.isNotEmpty ? variant : assetDesc;

        final now = DateTime.now();

        final vehicle = VehicleItem(
          id: '', // Will be assigned by Firestore
          auctionId: auctionId,
          contractNo: contractNo,
          rcNo: rcNo,
          make: make,
          model: getString('model'),
          chassisDesc: chassisDesc,
          engineNo: getString('engineNo'),
          chassisNo: getString('chassisNo'),
          yom: getInt('yom'),
          fuelType: getString('fuelType'),
          ppt: '', // Not in TATA Capital format
          yardName: getString('yardName'),
          yardCity: getString('yardCity'),
          yardState: getString('yardState'),
          basePrice: getDouble('basePrice'),
          bidIncrement: getDouble('bidIncrement'),
          multipleAmount: getDouble('multipleAmount'),
          vahanUrl: null, // Not in TATA Capital format
          contactPerson: getString('contactPerson'),
          contactNumber: getString('contactNumber'),
          remark: getString('remark'),
          rcAvailable: rcAvailable,
          repoDate: getDateTime('repoDate'),
          startDate: getDateTime('startDate'),
          endDate: getDateTime('endDate'),
          images: getImages('images'),
          createdAt: now,
          updatedAt: now,
        );

        vehicles.add(vehicle);
      } catch (e) {
        errors.add('Row ${i + 2}: $e'); // +2 for header row and 0-indexing
        AppLogger.warning(_tag, 'Error parsing row $i: $e');
      }
    }

    AppLogger.info(_tag, 'Created ${vehicles.length} vehicles from ${data.length} rows');

    return ExcelImportResult(
      vehicles: vehicles,
      errors: errors,
      totalRows: serverTotalRows > 0 ? serverTotalRows : data.length,
      successfulRows: vehicles.length,
    );
  }

  /// Legacy client-side parsing (kept for backward compatibility)
  /// Note: This only works with .xlsx files, not .xls
  /// Prefer using parseExcelOnServer for robust format support
  static ExcelImportResult parseExcelFile(Uint8List bytes, String auctionId) {
    AppLogger.warning(_tag, 'Using legacy client-side parsing. Prefer parseExcelOnServer.');

    // Return empty result - server-side parsing is preferred
    return const ExcelImportResult(
      vehicles: [],
      errors: ['Client-side parsing is deprecated. Please use server-side parsing.'],
      totalRows: 0,
      successfulRows: 0,
    );
  }
}
