import 'package:equatable/equatable.dart';

/// Auction mode - open auction (physical) or online
enum AuctionMode {
  openAuction,
  online;

  String get displayName {
    switch (this) {
      case AuctionMode.openAuction:
        return 'Open Auction';
      case AuctionMode.online:
        return 'Online';
    }
  }
}

/// Event type / Organizer for the auction
enum EventType {
  lnt,
  tcf,
  mnbaf,
  hdbf,
  cwcf,
  other;

  String get displayName {
    switch (this) {
      case EventType.lnt:
        return 'LNT';
      case EventType.tcf:
        return 'TCF';
      case EventType.mnbaf:
        return 'MNBAF';
      case EventType.hdbf:
        return 'HDBF';
      case EventType.cwcf:
        return 'CWCF';
      case EventType.other:
        return 'Other';
    }
  }

  /// Check if this event type requires an event ID
  bool get requiresEventId => this != EventType.other;
}

/// Zip type for image matching
enum ZipType {
  contractNo,
  rcNo;

  String get displayName {
    switch (this) {
      case ZipType.contractNo:
        return 'Contract No';
      case ZipType.rcNo:
        return 'RC No';
    }
  }
}

/// Auction status
enum AuctionStatus {
  upcoming,
  live,
  ended,
  cancelled;

  String get displayName {
    switch (this) {
      case AuctionStatus.upcoming:
        return 'Upcoming';
      case AuctionStatus.live:
        return 'Live';
      case AuctionStatus.ended:
        return 'Ended';
      case AuctionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Auction entity representing a vehicle auction event
class Auction extends Equatable {
  final String id;
  final String name;
  final String category;
  final String categoryName;
  final DateTime startDate;
  final DateTime endDate;
  final AuctionMode mode;
  final bool checkBasePrice;
  final EventType eventType;
  final String? eventId;
  final String? bidReportUrl;
  final String? imagesZipUrl;
  final ZipType zipType;
  final AuctionStatus status;
  final List<String> vehicleIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Auction({
    required this.id,
    required this.name,
    required this.category,
    this.categoryName = '',
    required this.startDate,
    required this.endDate,
    required this.mode,
    required this.checkBasePrice,
    required this.eventType,
    this.eventId,
    this.bidReportUrl,
    this.imagesZipUrl,
    required this.zipType,
    required this.status,
    this.vehicleIds = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if event ID is required based on event type
  bool get requiresEventId => eventType.requiresEventId;

  /// Check if the auction is currently active
  bool get isActive =>
      status == AuctionStatus.upcoming || status == AuctionStatus.live;

  /// Get the number of vehicles in this auction
  int get vehicleCount => vehicleIds.length;

  /// Calculate auction duration
  Duration get duration => endDate.difference(startDate);

  /// Check if auction has started
  bool get hasStarted => DateTime.now().isAfter(startDate);

  /// Check if auction has ended
  bool get hasEnded => DateTime.now().isAfter(endDate);

  /// Copy with method for immutable updates
  Auction copyWith({
    String? id,
    String? name,
    String? category,
    String? categoryName,
    DateTime? startDate,
    DateTime? endDate,
    AuctionMode? mode,
    bool? checkBasePrice,
    EventType? eventType,
    String? eventId,
    String? bidReportUrl,
    String? imagesZipUrl,
    ZipType? zipType,
    AuctionStatus? status,
    List<String>? vehicleIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Auction(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      mode: mode ?? this.mode,
      checkBasePrice: checkBasePrice ?? this.checkBasePrice,
      eventType: eventType ?? this.eventType,
      eventId: eventId ?? this.eventId,
      bidReportUrl: bidReportUrl ?? this.bidReportUrl,
      imagesZipUrl: imagesZipUrl ?? this.imagesZipUrl,
      zipType: zipType ?? this.zipType,
      status: status ?? this.status,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        categoryName,
        startDate,
        endDate,
        mode,
        checkBasePrice,
        eventType,
        eventId,
        bidReportUrl,
        imagesZipUrl,
        zipType,
        status,
        vehicleIds,
        createdBy,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'Auction(id: $id, name: $name, status: $status)';
}
