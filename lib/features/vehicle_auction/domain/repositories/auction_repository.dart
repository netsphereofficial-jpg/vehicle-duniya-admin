import '../entities/auction.dart';
import '../entities/category.dart';
import '../entities/vehicle_item.dart';

/// Abstract repository interface for auction operations
abstract class AuctionRepository {
  // ============ Categories ============

  /// Get all active categories
  Future<List<Category>> getCategories();

  /// Stream of categories for real-time updates
  Stream<List<Category>> watchCategories();

  // ============ Auctions ============

  /// Get all auctions with optional status filter
  Future<List<Auction>> getAuctions({AuctionStatus? statusFilter});

  /// Get a single auction by ID
  Future<Auction> getAuctionById(String id);

  /// Create a new auction
  Future<Auction> createAuction({
    required String name,
    required String category,
    required DateTime startDate,
    required DateTime endDate,
    required AuctionMode mode,
    required bool checkBasePrice,
    required EventType eventType,
    String? eventId,
    required ZipType zipType,
    required String createdBy,
  });

  /// Update an existing auction
  Future<void> updateAuction(String id, Map<String, dynamic> updates);

  /// Delete an auction
  Future<void> deleteAuction(String id);

  /// Update auction status
  Future<void> updateAuctionStatus(String id, AuctionStatus status);

  // ============ File Uploads ============

  /// Upload bid report file
  Future<String> uploadBidReport(
    String auctionId,
    dynamic fileBytes,
    String fileName,
  );

  /// Upload images zip file
  Future<String> uploadImagesZip(
    String auctionId,
    dynamic fileBytes,
    String fileName,
  );

  // ============ Vehicles ============

  /// Get vehicles for a specific auction
  Future<List<VehicleItem>> getVehiclesByAuction(String auctionId);

  /// Get a single vehicle by ID
  Future<VehicleItem> getVehicleById(String id);

  /// Add a vehicle to an auction
  Future<VehicleItem> addVehicleToAuction(VehicleItem vehicle);

  /// Update a vehicle
  Future<void> updateVehicle(String vehicleId, Map<String, dynamic> updates);

  /// Remove a vehicle from an auction
  Future<void> removeVehicleFromAuction(String auctionId, String vehicleId);

  // ============ Streams for Real-time ============

  /// Stream of auctions for real-time updates
  Stream<List<Auction>> watchAuctions({AuctionStatus? statusFilter});

  /// Stream of a single auction
  Stream<Auction> watchAuctionById(String id);

  /// Stream of vehicles for a specific auction
  Stream<List<VehicleItem>> watchVehiclesByAuction(String auctionId);
}
