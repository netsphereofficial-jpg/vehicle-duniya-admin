import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/car_bazaar_shop.dart';

/// Model for Firestore serialization of CarBazaarShop
class CarBazaarShopModel extends CarBazaarShop {
  const CarBazaarShopModel({
    required super.id,
    required super.shopId,
    required super.shopName,
    required super.ownerName,
    required super.phone,
    required super.email,
    required super.address,
    super.gstNumber,
    super.licenseNumber,
    required super.businessType,
    super.logoUrl,
    super.password,
    required super.isActive,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from Firestore document
  factory CarBazaarShopModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarBazaarShopModel(
      id: doc.id,
      shopId: data['shopId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      address: data['address'] as String? ?? '',
      gstNumber: data['gstNumber'] as String?,
      licenseNumber: data['licenseNumber'] as String?,
      businessType: BusinessType.fromString(
        data['businessType'] as String? ?? 'Dealer',
      ),
      logoUrl: data['logoUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create model from entity
  factory CarBazaarShopModel.fromEntity(CarBazaarShop entity) {
    return CarBazaarShopModel(
      id: entity.id,
      shopId: entity.shopId,
      shopName: entity.shopName,
      ownerName: entity.ownerName,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      gstNumber: entity.gstNumber,
      licenseNumber: entity.licenseNumber,
      businessType: entity.businessType,
      logoUrl: entity.logoUrl,
      password: entity.password,
      isActive: entity.isActive,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
      'gstNumber': gstNumber,
      'licenseNumber': licenseNumber,
      'businessType': businessType.name,
      'logoUrl': logoUrl,
      'passwordHash': password, // Store hashed password
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Generate a secure random password
  /// Uses alphanumeric characters excluding ambiguous ones (0, O, l, 1, I)
  static String generatePassword({int length = 8}) {
    const chars = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Generate next shop ID based on last shop ID
  /// Format: CB001, CB002, CB003...
  static String generateNextShopId(String? lastShopId) {
    if (lastShopId == null || lastShopId.isEmpty) {
      return 'CB001';
    }

    // Extract number from shopId (e.g., "CB042" -> 42)
    final numberPart = lastShopId.substring(2);
    final lastNumber = int.tryParse(numberPart) ?? 0;
    final nextNumber = lastNumber + 1;

    // Pad with zeros to maintain 3-digit format (expandable)
    return 'CB${nextNumber.toString().padLeft(3, '0')}';
  }

  /// Simple hash function for password storage
  /// In production, use a proper hashing library like bcrypt
  static String hashPassword(String password) {
    // Simple hash for demo - in production use bcrypt or similar
    var hash = 0;
    for (var i = 0; i < password.length; i++) {
      final char = password.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
