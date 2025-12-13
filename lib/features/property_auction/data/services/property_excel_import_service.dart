import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../domain/entities/property_auction.dart';

/// Result of Excel import operation
class PropertyExcelImportResult {
  final List<PropertyAuction> auctions;
  final List<String> errors;
  final int totalRows;
  final int successfulRows;

  const PropertyExcelImportResult({
    required this.auctions,
    required this.errors,
    required this.totalRows,
    required this.successfulRows,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => errors.isEmpty && auctions.isNotEmpty;

  String get summary {
    if (auctions.isEmpty && errors.isEmpty) {
      return 'No data found in Excel file';
    }
    if (hasErrors) {
      return '$successfulRows/$totalRows properties imported, ${errors.length} errors';
    }
    return '$successfulRows properties imported successfully';
  }
}

/// Service for importing property auctions from Excel files
class PropertyExcelImportService {
  /// Column name mappings (normalized lowercase)
  static const Map<String, String> _columnMappings = {
    // Event info
    'event type': 'eventType',
    'eventtype': 'eventType',
    'event no': 'eventNo',
    'eventno': 'eventNo',
    'event_no': 'eventNo',
    'nit ref. no': 'nitRefNo',
    'nit ref no': 'nitRefNo',
    'nitrefno': 'nitRefNo',
    'tender/event title': 'eventTitle',
    'tenderevent title': 'eventTitle',
    'event title': 'eventTitle',
    'eventtitle': 'eventTitle',
    'event bank:': 'eventBank',
    'event bank': 'eventBank',
    'eventbank': 'eventBank',
    'event branch:': 'eventBranch',
    'event branch': 'eventBranch',
    'eventbranch': 'eventBranch',

    // Property info
    'property category': 'propertyCategory',
    'propertycategory': 'propertyCategory',
    'property sub category:': 'propertySubCategory',
    'property sub category': 'propertySubCategory',
    'propertysubcategory': 'propertySubCategory',
    'property description:': 'propertyDescription',
    'property description': 'propertyDescription',
    'propertydescription': 'propertyDescription',
    'borrower\'s name': 'borrowerName',
    'borrowers name': 'borrowerName',
    'borrowername': 'borrowerName',

    // Pricing
    'reserve price:': 'reservePrice',
    'reserve price': 'reservePrice',
    'reserveprice': 'reservePrice',
    'tender fee:': 'tenderFee',
    'tender fee': 'tenderFee',
    'tenderfee': 'tenderFee',
    'price bid:': 'priceBid',
    'price bid': 'priceBid',
    'pricebid': 'priceBid',
    'bid increment value': 'bidIncrementValue',
    'bidincrementvalue': 'bidIncrementValue',
    'bid_increment_value': 'bidIncrementValue',

    // Extension
    'auto extension time': 'autoExtensionTime',
    'autoextensiontime': 'autoExtensionTime',
    'no. of auto extension': 'noOfAutoExtension',
    'no of auto extension': 'noOfAutoExtension',
    'noofautoextension': 'noOfAutoExtension',

    // DSC
    'dsc required:': 'dscRequired',
    'dsc required': 'dscRequired',
    'dscrequired': 'dscRequired',

    // EMD
    'emd amount:': 'emdAmount',
    'emd amount': 'emdAmount',
    'emdamount': 'emdAmount',
    'emd deposit bank name': 'emdBankName',
    'emddepositbankname': 'emdBankName',
    'emd deposit bank account number': 'emdAccountNo',
    'emddepositbankaccountnumber': 'emdAccountNo',
    'emd deposit bank ifsc code:': 'emdIfscCode',
    'emd deposit bank ifsc code': 'emdIfscCode',
    'emddepositbankifsccode': 'emdIfscCode',

    // Dates
    'press release date': 'pressReleaseDate',
    'pressreleasedate': 'pressReleaseDate',
    'date of inspection  of property (from):': 'inspectionDateFrom',
    'date of inspection of property (from):': 'inspectionDateFrom',
    'date of inspection of property (from)': 'inspectionDateFrom',
    'inspectiondatefrom': 'inspectionDateFrom',
    'date of inspection of property (to):': 'inspectionDateTo',
    'date of inspection of property (to)': 'inspectionDateTo',
    'inspectiondateto': 'inspectionDateTo',
    'offer (first round quote) submission last date:': 'submissionLastDate',
    'offer (first round quote) submission last date': 'submissionLastDate',
    'submissionlastdate': 'submissionLastDate',
    'offer (first round quote) opening date:': 'offerOpeningDate',
    'offer (first round quote) opening date': 'offerOpeningDate',
    'offeropeningdate': 'offerOpeningDate',
    'auction start date and time:': 'auctionStartDate',
    'auction start date and time': 'auctionStartDate',
    'auctionstartdate': 'auctionStartDate',
    'auction end date and time': 'auctionEndDate',
    'auction end date and time:': 'auctionEndDate',
    'auctionenddate': 'auctionEndDate',

    // Documents
    'documents to be submitted': 'documentsRequired',
    'documentstobesubmitted': 'documentsRequired',
    'paper publishing': 'paperPublishingUrl',
    'paperpublishing': 'paperPublishingUrl',
    'annexure 2/details of bidder': 'detailsOfBidderUrl',
    'annexure2detailsofbidder': 'detailsOfBidderUrl',
    'annexure 3/declaration by bidders': 'declarationUrl',
    'annexure3declarationbybidders': 'declarationUrl',
  };

  /// Parse Excel file and return import result
  static PropertyExcelImportResult parseExcelFile({
    required Uint8List bytes,
    required DateTime startDate,
    required DateTime endDate,
    required String createdBy,
  }) {
    final auctions = <PropertyAuction>[];
    final errors = <String>[];
    int totalRows = 0;

    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];

      if (sheet == null || sheet.rows.isEmpty) {
        return const PropertyExcelImportResult(
          auctions: [],
          errors: ['Excel file is empty or could not be read'],
          totalRows: 0,
          successfulRows: 0,
        );
      }

      // Get header row and create column index map
      final headerRow = sheet.rows.first;
      final columnIndexMap = <String, int>{};

      for (int i = 0; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell?.value != null) {
          final headerText = cell!.value.toString().toLowerCase().trim();
          final normalizedName = _columnMappings[headerText];
          if (normalizedName != null) {
            columnIndexMap[normalizedName] = i;
          }
        }
      }

      // Process data rows
      for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        final row = sheet.rows[rowIndex];
        totalRows++;

        try {
          // Create helper to get cell value
          String getCellValue(String fieldName, {String defaultValue = ''}) {
            final index = columnIndexMap[fieldName];
            if (index == null || index >= row.length) return defaultValue;
            final cell = row[index];
            if (cell?.value == null) return defaultValue;
            return cell!.value.toString().trim();
          }

          double getNumericValue(String fieldName, {double defaultValue = 0.0}) {
            final value = getCellValue(fieldName);
            if (value.isEmpty) return defaultValue;
            final cleaned = value.replaceAll(',', '').replaceAll(' ', '');
            return double.tryParse(cleaned) ?? defaultValue;
          }

          DateTime? getDateValue(String fieldName) {
            final value = getCellValue(fieldName);
            if (value.isEmpty || value.toLowerCase() == 'download') return null;
            try {
              return DateTime.parse(value);
            } catch (_) {
              // Try other formats
              final parts = value.split(RegExp(r'[-/\s]'));
              if (parts.length >= 3) {
                try {
                  // Try dd-mm-yyyy format
                  final day = int.tryParse(parts[0]) ?? 1;
                  final month = int.tryParse(parts[1]) ?? 1;
                  final year = int.tryParse(parts[2]) ?? DateTime.now().year;
                  return DateTime(year, month, day);
                } catch (_) {}
              }
              return null;
            }
          }

          // Check for required fields
          final eventNo = getCellValue('eventNo');
          final eventType = getCellValue('eventType');

          if (eventNo.isEmpty && eventType.isEmpty) {
            // Skip empty rows
            totalRows--;
            continue;
          }

          // Determine status based on dates
          final now = DateTime.now();
          PropertyAuctionStatus status;
          if (now.isBefore(startDate)) {
            status = PropertyAuctionStatus.upcoming;
          } else if (now.isAfter(endDate)) {
            status = PropertyAuctionStatus.ended;
          } else {
            status = PropertyAuctionStatus.live;
          }

          final auction = PropertyAuction(
            id: '', // Will be assigned by Firestore
            eventType: eventType,
            eventNo: eventNo,
            nitRefNo: getCellValue('nitRefNo'),
            eventTitle: getCellValue('eventTitle'),
            eventBank: getCellValue('eventBank'),
            eventBranch: getCellValue('eventBranch'),
            propertyCategory: getCellValue('propertyCategory'),
            propertySubCategory: getCellValue('propertySubCategory'),
            propertyDescription: getCellValue('propertyDescription'),
            borrowerName: getCellValue('borrowerName'),
            reservePrice: getNumericValue('reservePrice'),
            tenderFee: getNumericValue('tenderFee'),
            priceBid: getCellValue('priceBid'),
            bidIncrementValue: getNumericValue('bidIncrementValue'),
            autoExtensionTime: getCellValue('autoExtensionTime'),
            noOfAutoExtension: getCellValue('noOfAutoExtension'),
            dscRequired: getCellValue('dscRequired'),
            emdAmount: getNumericValue('emdAmount'),
            emdBankName: getCellValue('emdBankName'),
            emdAccountNo: getCellValue('emdAccountNo'),
            emdIfscCode: getCellValue('emdIfscCode'),
            pressReleaseDate: getDateValue('pressReleaseDate'),
            inspectionDateFrom: getDateValue('inspectionDateFrom'),
            inspectionDateTo: getDateValue('inspectionDateTo'),
            submissionLastDate: getDateValue('submissionLastDate'),
            offerOpeningDate: getDateValue('offerOpeningDate'),
            auctionStartDate: startDate,
            auctionEndDate: endDate,
            documentsRequired: getCellValue('documentsRequired'),
            paperPublishingUrl: _parseUrl(getCellValue('paperPublishingUrl')),
            detailsOfBidderUrl: _parseUrl(getCellValue('detailsOfBidderUrl')),
            declarationUrl: _parseUrl(getCellValue('declarationUrl')),
            status: status,
            isActive: true,
            createdBy: createdBy,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          auctions.add(auction);
        } catch (e) {
          errors.add('Row ${rowIndex + 1}: $e');
        }
      }

      return PropertyExcelImportResult(
        auctions: auctions,
        errors: errors,
        totalRows: totalRows,
        successfulRows: auctions.length,
      );
    } catch (e) {
      // Check if it's a format issue (likely .xls instead of .xlsx)
      final errorMessage = e.toString().toLowerCase();
      String userMessage;

      if (errorMessage.contains('unsupported') ||
          errorMessage.contains('format') ||
          errorMessage.contains('invalid')) {
        userMessage = 'Invalid Excel format. Please save the file as .xlsx (Excel Workbook) format and try again. The older .xls format is not supported.';
      } else {
        userMessage = 'Failed to parse Excel file: $e';
      }

      return PropertyExcelImportResult(
        auctions: [],
        errors: [userMessage],
        totalRows: 0,
        successfulRows: 0,
      );
    }
  }

  /// Parse URL value (returns null for non-URL values like "Download")
  static String? _parseUrl(String value) {
    if (value.isEmpty) return null;
    if (value.toLowerCase() == 'download') return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return null;
  }
}
