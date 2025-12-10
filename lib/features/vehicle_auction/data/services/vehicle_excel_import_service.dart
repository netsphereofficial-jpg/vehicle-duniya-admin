import 'dart:typed_data';
import 'package:excel/excel.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/vehicle_item.dart';

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
/// Column mappings based on old admin panel (lot.xls format)
class VehicleExcelImportService {
  static const _tag = 'VehicleExcelImportService';

  /// Column name mappings from Excel headers to internal field names
  /// Based on the actual lot.xls file format used in production
  static const _columnMappings = {
    // Base price
    'base_price': 'baseprice',
    'baseprice': 'baseprice',

    // Contract number
    'contract_no': 'contractno',
    'contractno': 'contractno',

    // Yard info
    'yard_name': 'yardname',
    'yardname': 'yardname',
    'yard_city': 'yardcity',
    'yardcity': 'yardcity',
    'yard_state': 'yardstate',
    'yardstate': 'yardstate',

    // Vehicle details
    'make': 'make',
    'model': 'model',
    'ppt': 'ppt',

    // RC Number - THIS IS THE KEY MAPPING
    'veh_reg_no': 'rcno',
    'vehregno': 'rcno',
    'rc_no': 'rcno',
    'rcno': 'rcno',

    // Engine and chassis
    'engine_no': 'engineno',
    'engineno': 'engineno',
    'chassis_no': 'chassisno',
    'chassisno': 'chassisno',

    // Year of manufacture
    'yom': 'yom',

    // Dates
    'reposs_date': 'repodate',
    'repossdate': 'repodate',
    'repodate': 'repodate',
    'start_date': 'startdate',
    'startdate': 'startdate',
    'end_date': 'enddate',
    'enddate': 'enddate',

    // RC available status
    'rc_avaliable_status': 'rcavailable',
    'rcavaliablestatus': 'rcavailable',
    'rc_available_status': 'rcavailable',
    'rcavailable': 'rcavailable',

    // Fuel type
    'fuel_type': 'fueltype',
    'fueltype': 'fueltype',

    // Contact info
    'vehicle_duniya_contact_person': 'contactperson',
    'vehicleduniyacontactperson': 'contactperson',
    'contact_person': 'contactperson',
    'contactperson': 'contactperson',
    'vehicle_duniya_contact_number': 'contactnumber',
    'vehicleduniyacontactnumber': 'contactnumber',
    'contact_number': 'contactnumber',
    'contactnumber': 'contactnumber',

    // Other
    'remark': 'remark',
    'vahan_url': 'vahanurl',
    'vahanurl': 'vahanurl',

    // Bid increment - THIS IS THE KEY MAPPING
    'increament_amount_by': 'bidincrement',
    'increamentamountby': 'bidincrement',
    'increment_amount': 'bidincrement',
    'bid_increment': 'bidincrement',
    'bidincrement': 'bidincrement',

    // Multiple amount
    'multiple_amount': 'multipleamount',
    'multipleamount': 'multipleamount',
  };

  /// Required columns for vehicle import (using normalized names)
  static const _requiredColumns = [
    'contractno',
    'make',
    'model',
  ];

  /// Parse Excel file and extract vehicle data
  static ExcelImportResult parseExcelFile(Uint8List bytes, String auctionId) {
    AppLogger.info(_tag, 'Parsing Excel file for auction: $auctionId');

    final vehicles = <VehicleItem>[];
    final errors = <String>[];
    var totalRows = 0;
    var successfulRows = 0;

    try {
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        errors.add('Excel file is empty or has no sheets');
        return ExcelImportResult(
          vehicles: vehicles,
          errors: errors,
          totalRows: 0,
          successfulRows: 0,
        );
      }

      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null || sheet.rows.isEmpty) {
        errors.add('Sheet is empty');
        return ExcelImportResult(
          vehicles: vehicles,
          errors: errors,
          totalRows: 0,
          successfulRows: 0,
        );
      }

      // Get headers from first row and normalize them
      final headerRow = sheet.rows.first;
      final headers = <String, int>{};

      for (var i = 0; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell != null && cell.value != null) {
          final rawHeader = cell.value.toString().trim();
          final normalizedHeader = _normalizeHeader(rawHeader);
          headers[normalizedHeader] = i;
          AppLogger.debug(_tag, 'Column $i: "$rawHeader" -> "$normalizedHeader"');
        }
      }

      AppLogger.debug(_tag, 'Found ${headers.length} columns');

      // Validate required columns
      final missingColumns = <String>[];
      for (final required in _requiredColumns) {
        if (!headers.containsKey(required)) {
          missingColumns.add(required);
        }
      }

      if (missingColumns.isNotEmpty) {
        errors.add('Missing required columns: ${missingColumns.join(', ')}');
        AppLogger.warning(_tag, 'Missing columns: $missingColumns');
        AppLogger.debug(_tag, 'Available columns: ${headers.keys.toList()}');
      }

      // Parse data rows (skip header)
      totalRows = sheet.rows.length - 1;

      for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        final row = sheet.rows[rowIndex];

        // Skip empty rows
        if (_isEmptyRow(row)) {
          totalRows--;
          continue;
        }

        try {
          final vehicle = _parseRow(row, headers, auctionId, rowIndex);
          vehicles.add(vehicle);
          successfulRows++;
        } catch (e) {
          errors.add('Row ${rowIndex + 1}: ${e.toString()}');
          AppLogger.warning(_tag, 'Error parsing row $rowIndex: $e');
        }
      }

      AppLogger.info(_tag, 'Parsed $successfulRows/$totalRows vehicles successfully');

    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse Excel file', e);
      errors.add('Failed to parse Excel file: ${e.toString()}');
    }

    return ExcelImportResult(
      vehicles: vehicles,
      errors: errors,
      totalRows: totalRows,
      successfulRows: successfulRows,
    );
  }

  /// Check if a row is empty
  static bool _isEmptyRow(List<Data?> row) {
    return row.every((cell) =>
      cell == null ||
      cell.value == null ||
      cell.value.toString().trim().isEmpty
    );
  }

  /// Normalize header names to match expected field names
  static String _normalizeHeader(String header) {
    // Remove spaces, underscores, convert to lowercase, trim whitespace
    final cleaned = header.toLowerCase().replaceAll(' ', '').replaceAll('_', '').trim();

    // Check if we have a mapping for this header
    if (_columnMappings.containsKey(header.toLowerCase().trim())) {
      return _columnMappings[header.toLowerCase().trim()]!;
    }

    // Check cleaned version
    if (_columnMappings.containsKey(cleaned)) {
      return _columnMappings[cleaned]!;
    }

    // Return cleaned version as fallback
    return cleaned;
  }

  /// Parse a single row into a VehicleItem
  static VehicleItem _parseRow(
    List<Data?> row,
    Map<String, int> headers,
    String auctionId,
    int rowIndex,
  ) {
    String getCellValue(String column, {String defaultValue = ''}) {
      final index = headers[column];
      if (index == null || index >= row.length) return defaultValue;
      final cell = row[index];
      if (cell == null || cell.value == null) return defaultValue;
      final value = cell.value.toString().trim();
      return value == 'nan' || value == 'null' ? defaultValue : value;
    }

    double getNumericValue(String column, {double defaultValue = 0}) {
      final value = getCellValue(column);
      if (value.isEmpty) return defaultValue;
      return double.tryParse(value.replaceAll(',', '')) ?? defaultValue;
    }

    int getIntValue(String column, {int defaultValue = 0}) {
      final value = getCellValue(column);
      if (value.isEmpty) return defaultValue;
      // Handle values like "2022.0"
      final numVal = double.tryParse(value.replaceAll(',', ''));
      if (numVal != null) return numVal.toInt();
      return int.tryParse(value.split('.').first) ?? defaultValue;
    }

    bool getBoolValue(String column, {bool defaultValue = false}) {
      final value = getCellValue(column).toLowerCase();
      if (value.isEmpty) return defaultValue;
      return value == 'yes' || value == 'true' || value == '1' || value == 'available';
    }

    DateTime? getDateValue(String column) {
      final value = getCellValue(column);
      if (value.isEmpty) return null;

      // Try various date formats
      // Format: dd-mm-yyyy HH:mm:ss or dd-mm-yyyy
      final formats = [
        RegExp(r'^(\d{2})-(\d{2})-(\d{4})\s+(\d{2}):(\d{2}):(\d{2})$'),
        RegExp(r'^(\d{2})-(\d{2})-(\d{4})\s+(\d{2}):(\d{2})$'),
        RegExp(r'^(\d{2})-(\d{2})-(\d{4})$'),
      ];

      for (final format in formats) {
        final match = format.firstMatch(value);
        if (match != null) {
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final year = int.parse(match.group(3)!);
          final hour = match.groupCount >= 4 ? int.parse(match.group(4)!) : 0;
          final minute = match.groupCount >= 5 ? int.parse(match.group(5)!) : 0;
          final second = match.groupCount >= 6 ? int.parse(match.group(6)!) : 0;
          return DateTime(year, month, day, hour, minute, second);
        }
      }

      // Try ISO format as fallback
      return DateTime.tryParse(value);
    }

    List<String> getImageLinks() {
      final images = <String>[];
      for (var i = 1; i <= 20; i++) {
        // Try different column name formats
        var link = getCellValue('imagelink$i');
        if (link.isEmpty) {
          link = getCellValue('image_link_$i');
        }
        if (link.isNotEmpty && !link.startsWith('nan')) {
          images.add(link);
        }
      }
      return images;
    }

    // Get values with fallbacks
    final contractNo = getCellValue('contractno');
    final rcNo = getCellValue('rcno');
    final make = getCellValue('make');
    final model = getCellValue('model');

    // Validate minimum required fields
    if (contractNo.isEmpty && rcNo.isEmpty) {
      throw Exception('Either Contract No or RC No is required');
    }
    if (make.isEmpty) {
      throw Exception('Make is required');
    }

    final now = DateTime.now();

    return VehicleItem(
      id: '',
      auctionId: auctionId,
      contractNo: contractNo,
      rcNo: rcNo,
      make: make,
      model: model,
      chassisDesc: '', // model is used as chassis_desc in old system
      engineNo: getCellValue('engineno'),
      chassisNo: getCellValue('chassisno'),
      yom: getIntValue('yom'),
      fuelType: getCellValue('fueltype'),
      ppt: getCellValue('ppt'),
      yardName: getCellValue('yardname'),
      yardCity: getCellValue('yardcity'),
      yardState: getCellValue('yardstate'),
      basePrice: getNumericValue('baseprice'),
      bidIncrement: getNumericValue('bidincrement'),
      multipleAmount: getNumericValue('multipleamount'),
      vahanUrl: getCellValue('vahanurl'),
      contactPerson: getCellValue('contactperson'),
      contactNumber: getCellValue('contactnumber'),
      remark: getCellValue('remark'),
      rcAvailable: getBoolValue('rcavailable'),
      repoDate: getDateValue('repodate'),
      startDate: getDateValue('startdate'),
      endDate: getDateValue('enddate'),
      images: getImageLinks(),
      createdAt: now,
      updatedAt: now,
    );
  }
}
