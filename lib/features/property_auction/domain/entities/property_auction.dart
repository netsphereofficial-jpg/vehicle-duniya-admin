import 'package:equatable/equatable.dart';

/// Status of a property auction
enum PropertyAuctionStatus {
  upcoming('Upcoming'),
  live('Live'),
  ended('Ended');

  final String label;
  const PropertyAuctionStatus(this.label);

  static PropertyAuctionStatus fromString(String value) {
    return PropertyAuctionStatus.values.firstWhere(
      (e) => e.name == value || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => PropertyAuctionStatus.upcoming,
    );
  }
}

/// Entity representing a Property Auction
class PropertyAuction extends Equatable {
  final String id;
  final String eventType;
  final String eventNo;
  final String nitRefNo;
  final String eventTitle;
  final String eventBank;
  final String eventBranch;
  final String propertyCategory;
  final String propertySubCategory;
  final String propertyDescription;
  final String borrowerName;
  final double reservePrice;
  final double tenderFee;
  final String priceBid;
  final double bidIncrementValue;
  final String autoExtensionTime;
  final String noOfAutoExtension;
  final String dscRequired;
  final double emdAmount;
  final String emdBankName;
  final String emdAccountNo;
  final String emdIfscCode;
  final DateTime? pressReleaseDate;
  final DateTime? inspectionDateFrom;
  final DateTime? inspectionDateTo;
  final DateTime? submissionLastDate;
  final DateTime? offerOpeningDate;
  final DateTime auctionStartDate;
  final DateTime auctionEndDate;
  final String documentsRequired;
  final String? paperPublishingUrl;
  final String? detailsOfBidderUrl;
  final String? declarationUrl;
  final PropertyAuctionStatus status;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyAuction({
    required this.id,
    required this.eventType,
    required this.eventNo,
    required this.nitRefNo,
    required this.eventTitle,
    required this.eventBank,
    required this.eventBranch,
    required this.propertyCategory,
    required this.propertySubCategory,
    required this.propertyDescription,
    required this.borrowerName,
    required this.reservePrice,
    required this.tenderFee,
    required this.priceBid,
    required this.bidIncrementValue,
    required this.autoExtensionTime,
    required this.noOfAutoExtension,
    required this.dscRequired,
    required this.emdAmount,
    required this.emdBankName,
    required this.emdAccountNo,
    required this.emdIfscCode,
    this.pressReleaseDate,
    this.inspectionDateFrom,
    this.inspectionDateTo,
    this.submissionLastDate,
    this.offerOpeningDate,
    required this.auctionStartDate,
    required this.auctionEndDate,
    required this.documentsRequired,
    this.paperPublishingUrl,
    this.detailsOfBidderUrl,
    this.declarationUrl,
    required this.status,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with optional field updates
  PropertyAuction copyWith({
    String? id,
    String? eventType,
    String? eventNo,
    String? nitRefNo,
    String? eventTitle,
    String? eventBank,
    String? eventBranch,
    String? propertyCategory,
    String? propertySubCategory,
    String? propertyDescription,
    String? borrowerName,
    double? reservePrice,
    double? tenderFee,
    String? priceBid,
    double? bidIncrementValue,
    String? autoExtensionTime,
    String? noOfAutoExtension,
    String? dscRequired,
    double? emdAmount,
    String? emdBankName,
    String? emdAccountNo,
    String? emdIfscCode,
    DateTime? pressReleaseDate,
    DateTime? inspectionDateFrom,
    DateTime? inspectionDateTo,
    DateTime? submissionLastDate,
    DateTime? offerOpeningDate,
    DateTime? auctionStartDate,
    DateTime? auctionEndDate,
    String? documentsRequired,
    String? paperPublishingUrl,
    String? detailsOfBidderUrl,
    String? declarationUrl,
    PropertyAuctionStatus? status,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyAuction(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      eventNo: eventNo ?? this.eventNo,
      nitRefNo: nitRefNo ?? this.nitRefNo,
      eventTitle: eventTitle ?? this.eventTitle,
      eventBank: eventBank ?? this.eventBank,
      eventBranch: eventBranch ?? this.eventBranch,
      propertyCategory: propertyCategory ?? this.propertyCategory,
      propertySubCategory: propertySubCategory ?? this.propertySubCategory,
      propertyDescription: propertyDescription ?? this.propertyDescription,
      borrowerName: borrowerName ?? this.borrowerName,
      reservePrice: reservePrice ?? this.reservePrice,
      tenderFee: tenderFee ?? this.tenderFee,
      priceBid: priceBid ?? this.priceBid,
      bidIncrementValue: bidIncrementValue ?? this.bidIncrementValue,
      autoExtensionTime: autoExtensionTime ?? this.autoExtensionTime,
      noOfAutoExtension: noOfAutoExtension ?? this.noOfAutoExtension,
      dscRequired: dscRequired ?? this.dscRequired,
      emdAmount: emdAmount ?? this.emdAmount,
      emdBankName: emdBankName ?? this.emdBankName,
      emdAccountNo: emdAccountNo ?? this.emdAccountNo,
      emdIfscCode: emdIfscCode ?? this.emdIfscCode,
      pressReleaseDate: pressReleaseDate ?? this.pressReleaseDate,
      inspectionDateFrom: inspectionDateFrom ?? this.inspectionDateFrom,
      inspectionDateTo: inspectionDateTo ?? this.inspectionDateTo,
      submissionLastDate: submissionLastDate ?? this.submissionLastDate,
      offerOpeningDate: offerOpeningDate ?? this.offerOpeningDate,
      auctionStartDate: auctionStartDate ?? this.auctionStartDate,
      auctionEndDate: auctionEndDate ?? this.auctionEndDate,
      documentsRequired: documentsRequired ?? this.documentsRequired,
      paperPublishingUrl: paperPublishingUrl ?? this.paperPublishingUrl,
      detailsOfBidderUrl: detailsOfBidderUrl ?? this.detailsOfBidderUrl,
      declarationUrl: declarationUrl ?? this.declarationUrl,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formatted reserve price for display
  String get formattedReservePrice {
    if (reservePrice >= 10000000) {
      return '${(reservePrice / 10000000).toStringAsFixed(2)} Cr';
    } else if (reservePrice >= 100000) {
      return '${(reservePrice / 100000).toStringAsFixed(2)} L';
    }
    return reservePrice.toStringAsFixed(0);
  }

  /// Formatted EMD amount for display
  String get formattedEmdAmount {
    if (emdAmount >= 10000000) {
      return '${(emdAmount / 10000000).toStringAsFixed(2)} Cr';
    } else if (emdAmount >= 100000) {
      return '${(emdAmount / 100000).toStringAsFixed(2)} L';
    }
    return emdAmount.toStringAsFixed(0);
  }

  /// Formatted tender fee for display
  String get formattedTenderFee {
    if (tenderFee >= 10000000) {
      return '${(tenderFee / 10000000).toStringAsFixed(2)} Cr';
    } else if (tenderFee >= 100000) {
      return '${(tenderFee / 100000).toStringAsFixed(2)} L';
    }
    return tenderFee.toStringAsFixed(0);
  }

  /// Check if auction is currently live
  bool get isLive {
    final now = DateTime.now();
    return now.isAfter(auctionStartDate) && now.isBefore(auctionEndDate);
  }

  /// Check if auction is upcoming
  bool get isUpcoming {
    return DateTime.now().isBefore(auctionStartDate);
  }

  /// Check if auction has ended
  bool get hasEnded {
    return DateTime.now().isAfter(auctionEndDate);
  }

  /// Calculate current status based on dates
  PropertyAuctionStatus get calculatedStatus {
    if (hasEnded) return PropertyAuctionStatus.ended;
    if (isLive) return PropertyAuctionStatus.live;
    return PropertyAuctionStatus.upcoming;
  }

  /// Short description for display
  String get shortDescription {
    if (propertyDescription.length > 100) {
      return '${propertyDescription.substring(0, 100)}...';
    }
    return propertyDescription;
  }

  @override
  List<Object?> get props => [
        id,
        eventType,
        eventNo,
        nitRefNo,
        eventTitle,
        eventBank,
        eventBranch,
        propertyCategory,
        propertySubCategory,
        propertyDescription,
        borrowerName,
        reservePrice,
        tenderFee,
        priceBid,
        bidIncrementValue,
        autoExtensionTime,
        noOfAutoExtension,
        dscRequired,
        emdAmount,
        emdBankName,
        emdAccountNo,
        emdIfscCode,
        pressReleaseDate,
        inspectionDateFrom,
        inspectionDateTo,
        submissionLastDate,
        offerOpeningDate,
        auctionStartDate,
        auctionEndDate,
        documentsRequired,
        paperPublishingUrl,
        detailsOfBidderUrl,
        declarationUrl,
        status,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
