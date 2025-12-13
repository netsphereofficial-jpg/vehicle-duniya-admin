import 'package:equatable/equatable.dart';

/// Entity representing a highest bid record from Meta Portal
class MetaHighestBid extends Equatable {
  final String auctionId;
  final String auctionName;
  final String auctionKey;
  final String organizer;
  final String organizerDisplayName;
  final String vehicleId;
  final String rcNo;
  final String contractNo;
  final String make;
  final double highestBidAmount;
  final DateTime auctionCloseDate;
  final String eventId;

  const MetaHighestBid({
    required this.auctionId,
    required this.auctionName,
    required this.auctionKey,
    required this.organizer,
    required this.organizerDisplayName,
    required this.vehicleId,
    required this.rcNo,
    required this.contractNo,
    required this.make,
    required this.highestBidAmount,
    required this.auctionCloseDate,
    required this.eventId,
  });

  /// Get display-friendly organizer name
  static String getOrganizerDisplayName(String organizer) {
    switch (organizer.toUpperCase()) {
      case 'LNT':
        return 'L&T Finance';
      case 'TCF':
        return 'Tata Capital Finance';
      case 'MNBAF':
        return 'Manba Finance';
      case 'HDBF':
        return 'HDB Finance';
      case 'CWCF':
        return 'Cholamandalam';
      default:
        return organizer;
    }
  }

  @override
  List<Object?> get props => [
        auctionId,
        auctionName,
        auctionKey,
        organizer,
        vehicleId,
        rcNo,
        contractNo,
        make,
        highestBidAmount,
        auctionCloseDate,
        eventId,
      ];
}
