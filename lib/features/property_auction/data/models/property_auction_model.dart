import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/property_auction.dart';

/// Model for Firestore serialization of PropertyAuction
class PropertyAuctionModel extends PropertyAuction {
  const PropertyAuctionModel({
    required super.id,
    required super.eventType,
    required super.eventNo,
    required super.nitRefNo,
    required super.eventTitle,
    required super.eventBank,
    required super.eventBranch,
    required super.propertyCategory,
    required super.propertySubCategory,
    required super.propertyDescription,
    required super.borrowerName,
    required super.reservePrice,
    required super.tenderFee,
    required super.priceBid,
    required super.bidIncrementValue,
    required super.autoExtensionTime,
    required super.noOfAutoExtension,
    required super.dscRequired,
    required super.emdAmount,
    required super.emdBankName,
    required super.emdAccountNo,
    required super.emdIfscCode,
    super.pressReleaseDate,
    super.inspectionDateFrom,
    super.inspectionDateTo,
    super.submissionLastDate,
    super.offerOpeningDate,
    required super.auctionStartDate,
    required super.auctionEndDate,
    required super.documentsRequired,
    super.paperPublishingUrl,
    super.detailsOfBidderUrl,
    super.declarationUrl,
    required super.status,
    required super.isActive,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore document
  factory PropertyAuctionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PropertyAuctionModel(
      id: doc.id,
      eventType: data['eventType'] ?? '',
      eventNo: data['eventNo'] ?? '',
      nitRefNo: data['nitRefNo'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventBank: data['eventBank'] ?? '',
      eventBranch: data['eventBranch'] ?? '',
      propertyCategory: data['propertyCategory'] ?? '',
      propertySubCategory: data['propertySubCategory'] ?? '',
      propertyDescription: data['propertyDescription'] ?? '',
      borrowerName: data['borrowerName'] ?? '',
      reservePrice: _parseDouble(data['reservePrice']),
      tenderFee: _parseDouble(data['tenderFee']),
      priceBid: data['priceBid'] ?? '',
      bidIncrementValue: _parseDouble(data['bidIncrementValue']),
      autoExtensionTime: data['autoExtensionTime'] ?? '',
      noOfAutoExtension: data['noOfAutoExtension'] ?? '',
      dscRequired: data['dscRequired'] ?? '',
      emdAmount: _parseDouble(data['emdAmount']),
      emdBankName: data['emdBankName'] ?? '',
      emdAccountNo: data['emdAccountNo'] ?? '',
      emdIfscCode: data['emdIfscCode'] ?? '',
      pressReleaseDate: _parseTimestamp(data['pressReleaseDate']),
      inspectionDateFrom: _parseTimestamp(data['inspectionDateFrom']),
      inspectionDateTo: _parseTimestamp(data['inspectionDateTo']),
      submissionLastDate: _parseTimestamp(data['submissionLastDate']),
      offerOpeningDate: _parseTimestamp(data['offerOpeningDate']),
      auctionStartDate: _parseTimestamp(data['auctionStartDate']) ?? DateTime.now(),
      auctionEndDate: _parseTimestamp(data['auctionEndDate']) ?? DateTime.now(),
      documentsRequired: data['documentsRequired'] ?? '',
      paperPublishingUrl: data['paperPublishingUrl'],
      detailsOfBidderUrl: data['detailsOfBidderUrl'],
      declarationUrl: data['declarationUrl'],
      status: PropertyAuctionStatus.fromString(data['status'] ?? 'upcoming'),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'eventType': eventType,
      'eventNo': eventNo,
      'nitRefNo': nitRefNo,
      'eventTitle': eventTitle,
      'eventBank': eventBank,
      'eventBranch': eventBranch,
      'propertyCategory': propertyCategory,
      'propertySubCategory': propertySubCategory,
      'propertyDescription': propertyDescription,
      'borrowerName': borrowerName,
      'reservePrice': reservePrice,
      'tenderFee': tenderFee,
      'priceBid': priceBid,
      'bidIncrementValue': bidIncrementValue,
      'autoExtensionTime': autoExtensionTime,
      'noOfAutoExtension': noOfAutoExtension,
      'dscRequired': dscRequired,
      'emdAmount': emdAmount,
      'emdBankName': emdBankName,
      'emdAccountNo': emdAccountNo,
      'emdIfscCode': emdIfscCode,
      'pressReleaseDate': pressReleaseDate != null ? Timestamp.fromDate(pressReleaseDate!) : null,
      'inspectionDateFrom': inspectionDateFrom != null ? Timestamp.fromDate(inspectionDateFrom!) : null,
      'inspectionDateTo': inspectionDateTo != null ? Timestamp.fromDate(inspectionDateTo!) : null,
      'submissionLastDate': submissionLastDate != null ? Timestamp.fromDate(submissionLastDate!) : null,
      'offerOpeningDate': offerOpeningDate != null ? Timestamp.fromDate(offerOpeningDate!) : null,
      'auctionStartDate': Timestamp.fromDate(auctionStartDate),
      'auctionEndDate': Timestamp.fromDate(auctionEndDate),
      'documentsRequired': documentsRequired,
      'paperPublishingUrl': paperPublishingUrl,
      'detailsOfBidderUrl': detailsOfBidderUrl,
      'declarationUrl': declarationUrl,
      'status': status.name,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create from PropertyAuction entity
  factory PropertyAuctionModel.fromEntity(PropertyAuction entity) {
    return PropertyAuctionModel(
      id: entity.id,
      eventType: entity.eventType,
      eventNo: entity.eventNo,
      nitRefNo: entity.nitRefNo,
      eventTitle: entity.eventTitle,
      eventBank: entity.eventBank,
      eventBranch: entity.eventBranch,
      propertyCategory: entity.propertyCategory,
      propertySubCategory: entity.propertySubCategory,
      propertyDescription: entity.propertyDescription,
      borrowerName: entity.borrowerName,
      reservePrice: entity.reservePrice,
      tenderFee: entity.tenderFee,
      priceBid: entity.priceBid,
      bidIncrementValue: entity.bidIncrementValue,
      autoExtensionTime: entity.autoExtensionTime,
      noOfAutoExtension: entity.noOfAutoExtension,
      dscRequired: entity.dscRequired,
      emdAmount: entity.emdAmount,
      emdBankName: entity.emdBankName,
      emdAccountNo: entity.emdAccountNo,
      emdIfscCode: entity.emdIfscCode,
      pressReleaseDate: entity.pressReleaseDate,
      inspectionDateFrom: entity.inspectionDateFrom,
      inspectionDateTo: entity.inspectionDateTo,
      submissionLastDate: entity.submissionLastDate,
      offerOpeningDate: entity.offerOpeningDate,
      auctionStartDate: entity.auctionStartDate,
      auctionEndDate: entity.auctionEndDate,
      documentsRequired: entity.documentsRequired,
      paperPublishingUrl: entity.paperPublishingUrl,
      detailsOfBidderUrl: entity.detailsOfBidderUrl,
      declarationUrl: entity.declarationUrl,
      status: entity.status,
      isActive: entity.isActive,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Parse Timestamp to DateTime
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parse to double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').replaceAll(' ', '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}
