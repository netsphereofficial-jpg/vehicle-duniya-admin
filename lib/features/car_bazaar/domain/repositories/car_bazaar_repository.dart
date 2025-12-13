import 'dart:typed_data';

import '../entities/car_bazaar_shop.dart';

/// Repository interface for Car Bazaar shop management
abstract class CarBazaarRepository {
  /// Watch all shops with real-time updates
  Stream<List<CarBazaarShop>> watchShops();

  /// Create a new shop with auto-generated ID and password
  /// Returns the created shop with password populated for display
  Future<CarBazaarShop> createShop({
    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    String? gstNumber,
    String? licenseNumber,
    required BusinessType businessType,
    Uint8List? logoBytes,
    String? logoFileName,
    required String createdBy,
  });

  /// Update an existing shop
  Future<void> updateShop({
    required String id,
    String? shopName,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
    String? licenseNumber,
    BusinessType? businessType,
    Uint8List? logoBytes,
    String? logoFileName,
    bool removeLogo = false,
  });

  /// Toggle shop active status
  Future<void> toggleShopStatus({
    required String id,
    required bool isActive,
  });

  /// Reset password for a shop
  /// Returns the new password for display
  Future<String> resetPassword(String id);

  /// Delete a shop and its logo
  Future<void> deleteShop(String id);

  /// Get total count of shops
  Future<int> getTotalCount();

  /// Get count of active shops
  Future<int> getActiveCount();

  /// Get the next available shop ID (CB001, CB002...)
  Future<String> getNextShopId();
}
