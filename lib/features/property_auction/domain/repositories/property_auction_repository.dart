import '../entities/property_auction.dart';

/// Repository interface for Property Auction management
abstract class PropertyAuctionRepository {
  /// Watch all auctions with real-time updates
  /// Optionally filter by status
  Stream<List<PropertyAuction>> watchAuctions({
    PropertyAuctionStatus? status,
    bool? isActive,
  });

  /// Get a single auction by ID
  Future<PropertyAuction?> getAuctionById(String id);

  /// Create multiple auctions from Excel import
  Future<void> createAuctions(List<PropertyAuction> auctions);

  /// Update an auction
  Future<void> updateAuction(String id, Map<String, dynamic> data);

  /// Update auction dates
  Future<void> updateAuctionDates({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Delete an auction
  Future<void> deleteAuction(String id);

  /// Get total count of auctions
  Future<int> getTotalCount({bool? isActive});

  /// Get count by status
  Future<int> getCountByStatus(PropertyAuctionStatus status, {bool? isActive});

  /// Update auction status based on dates
  Future<void> updateAuctionStatuses();
}
