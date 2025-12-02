import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/auction.dart';

/// Auction model with Firestore serialization
class AuctionModel extends Auction {
  const AuctionModel({
    required super.id,
    required super.name,
    required super.category,
    super.categoryName,
    required super.startDate,
    required super.endDate,
    required super.mode,
    required super.checkBasePrice,
    required super.eventType,
    super.eventId,
    super.bidReportUrl,
    super.imagesZipUrl,
    required super.zipType,
    required super.status,
    super.vehicleIds,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create AuctionModel from Firestore document
  factory AuctionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuctionModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      categoryName: data['categoryName'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mode: _parseAuctionMode(data['mode']),
      checkBasePrice: data['checkBasePrice'] ?? false,
      eventType: _parseEventType(data['eventType']),
      eventId: data['eventId'],
      bidReportUrl: data['bidReportUrl'],
      imagesZipUrl: data['imagesZipUrl'],
      zipType: _parseZipType(data['zipType']),
      status: _parseAuctionStatus(data['status']),
      vehicleIds: List<String>.from(data['vehicleIds'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create AuctionModel from Map
  factory AuctionModel.fromMap(String id, Map<String, dynamic> data) {
    return AuctionModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      categoryName: data['categoryName'] ?? '',
      startDate: data['startDate'] is Timestamp
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: data['endDate'] is Timestamp
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.parse(data['endDate'] ?? DateTime.now().toIso8601String()),
      mode: _parseAuctionMode(data['mode']),
      checkBasePrice: data['checkBasePrice'] ?? false,
      eventType: _parseEventType(data['eventType']),
      eventId: data['eventId'],
      bidReportUrl: data['bidReportUrl'],
      imagesZipUrl: data['imagesZipUrl'],
      zipType: _parseZipType(data['zipType']),
      status: _parseAuctionStatus(data['status']),
      vehicleIds: List<String>.from(data['vehicleIds'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create AuctionModel from Auction entity
  factory AuctionModel.fromEntity(Auction auction) {
    return AuctionModel(
      id: auction.id,
      name: auction.name,
      category: auction.category,
      categoryName: auction.categoryName,
      startDate: auction.startDate,
      endDate: auction.endDate,
      mode: auction.mode,
      checkBasePrice: auction.checkBasePrice,
      eventType: auction.eventType,
      eventId: auction.eventId,
      bidReportUrl: auction.bidReportUrl,
      imagesZipUrl: auction.imagesZipUrl,
      zipType: auction.zipType,
      status: auction.status,
      vehicleIds: auction.vehicleIds,
      createdBy: auction.createdBy,
      createdAt: auction.createdAt,
      updatedAt: auction.updatedAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'categoryName': categoryName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'mode': mode.name,
      'checkBasePrice': checkBasePrice,
      'eventType': eventType.name,
      'eventId': eventId,
      'bidReportUrl': bidReportUrl,
      'imagesZipUrl': imagesZipUrl,
      'zipType': zipType.name,
      'status': status.name,
      'vehicleIds': vehicleIds,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to Map for updates (without id, createdAt, createdBy)
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'category': category,
      'categoryName': categoryName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'mode': mode.name,
      'checkBasePrice': checkBasePrice,
      'eventType': eventType.name,
      'eventId': eventId,
      'bidReportUrl': bidReportUrl,
      'imagesZipUrl': imagesZipUrl,
      'zipType': zipType.name,
      'status': status.name,
      'vehicleIds': vehicleIds,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // ============ Parse Helpers ============

  static AuctionMode _parseAuctionMode(String? value) {
    switch (value) {
      case 'openAuction':
      case 'open_auction':
        return AuctionMode.openAuction;
      case 'online':
      default:
        return AuctionMode.online;
    }
  }

  static EventType _parseEventType(String? value) {
    switch (value?.toLowerCase()) {
      case 'lnt':
        return EventType.lnt;
      case 'tcf':
        return EventType.tcf;
      case 'mnbaf':
        return EventType.mnbaf;
      case 'hdbf':
        return EventType.hdbf;
      case 'cwcf':
        return EventType.cwcf;
      case 'other':
      default:
        return EventType.other;
    }
  }

  static ZipType _parseZipType(String? value) {
    switch (value) {
      case 'rcNo':
      case 'rc_no':
        return ZipType.rcNo;
      case 'contractNo':
      case 'contract_no':
      default:
        return ZipType.contractNo;
    }
  }

  static AuctionStatus _parseAuctionStatus(String? value) {
    switch (value) {
      case 'live':
        return AuctionStatus.live;
      case 'ended':
        return AuctionStatus.ended;
      case 'cancelled':
        return AuctionStatus.cancelled;
      case 'upcoming':
      default:
        return AuctionStatus.upcoming;
    }
  }
}
