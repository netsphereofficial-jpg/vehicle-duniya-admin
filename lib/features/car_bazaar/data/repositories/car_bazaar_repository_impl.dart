import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/car_bazaar_shop.dart';
import '../../domain/repositories/car_bazaar_repository.dart';
import '../models/car_bazaar_shop_model.dart';

/// Firestore implementation of CarBazaarRepository
class CarBazaarRepositoryImpl implements CarBazaarRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const String _collection = 'car_bazaar_shops';
  static const String _storageFolder = 'car_bazaar_logos';

  CarBazaarRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference<Map<String, dynamic>> get _shopsRef =>
      _firestore.collection(_collection);

  @override
  Stream<List<CarBazaarShop>> watchShops() {
    return _shopsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CarBazaarShopModel.fromFirestore(doc))
            .toList());
  }

  @override
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
  }) async {
    // Generate shop ID
    final shopId = await getNextShopId();

    // Generate password
    final password = CarBazaarShopModel.generatePassword();
    final passwordHash = CarBazaarShopModel.hashPassword(password);

    // Upload logo if provided
    String? logoUrl;
    if (logoBytes != null && logoFileName != null) {
      logoUrl = await _uploadLogo(shopId, logoBytes, logoFileName);
    }

    final now = DateTime.now();
    final docRef = _shopsRef.doc();

    final shop = CarBazaarShopModel(
      id: docRef.id,
      shopId: shopId,
      shopName: shopName,
      ownerName: ownerName,
      phone: _normalizePhone(phone),
      email: email.toLowerCase().trim(),
      address: address,
      gstNumber: gstNumber?.trim().toUpperCase(),
      licenseNumber: licenseNumber?.trim(),
      businessType: businessType,
      logoUrl: logoUrl,
      password: passwordHash,
      isActive: true,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(shop.toFirestore());

    // Return with plain password for display
    return shop.copyWith(password: password);
  }

  @override
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
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (shopName != null) updates['shopName'] = shopName;
    if (ownerName != null) updates['ownerName'] = ownerName;
    if (phone != null) updates['phone'] = _normalizePhone(phone);
    if (email != null) updates['email'] = email.toLowerCase().trim();
    if (address != null) updates['address'] = address;
    if (gstNumber != null) {
      updates['gstNumber'] = gstNumber.trim().toUpperCase();
    }
    if (licenseNumber != null) updates['licenseNumber'] = licenseNumber.trim();
    if (businessType != null) updates['businessType'] = businessType.name;

    // Handle logo update
    if (removeLogo) {
      // Delete existing logo
      final doc = await _shopsRef.doc(id).get();
      final existingLogoUrl = doc.data()?['logoUrl'] as String?;
      if (existingLogoUrl != null) {
        await _deleteLogo(existingLogoUrl);
      }
      updates['logoUrl'] = null;
    } else if (logoBytes != null && logoFileName != null) {
      // Get shop ID for folder naming
      final doc = await _shopsRef.doc(id).get();
      final shopId = doc.data()?['shopId'] as String? ?? id;

      // Delete existing logo
      final existingLogoUrl = doc.data()?['logoUrl'] as String?;
      if (existingLogoUrl != null) {
        await _deleteLogo(existingLogoUrl);
      }

      // Upload new logo
      updates['logoUrl'] = await _uploadLogo(shopId, logoBytes, logoFileName);
    }

    await _shopsRef.doc(id).update(updates);
  }

  @override
  Future<void> toggleShopStatus({
    required String id,
    required bool isActive,
  }) async {
    await _shopsRef.doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> resetPassword(String id) async {
    final password = CarBazaarShopModel.generatePassword();
    final passwordHash = CarBazaarShopModel.hashPassword(password);

    await _shopsRef.doc(id).update({
      'passwordHash': passwordHash,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return password;
  }

  @override
  Future<void> deleteShop(String id) async {
    // Get shop data to delete logo
    final doc = await _shopsRef.doc(id).get();
    final logoUrl = doc.data()?['logoUrl'] as String?;

    // Delete logo from storage
    if (logoUrl != null) {
      await _deleteLogo(logoUrl);
    }

    // Delete document
    await _shopsRef.doc(id).delete();
  }

  @override
  Future<int> getTotalCount() async {
    final snapshot = await _shopsRef.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getActiveCount() async {
    final snapshot =
        await _shopsRef.where('isActive', isEqualTo: true).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<String> getNextShopId() async {
    final snapshot = await _shopsRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 'CB001';
    }

    final lastShopId = snapshot.docs.first.data()['shopId'] as String?;
    return CarBazaarShopModel.generateNextShopId(lastShopId);
  }

  /// Upload logo to Firebase Storage
  Future<String> _uploadLogo(
    String shopId,
    Uint8List bytes,
    String fileName,
  ) async {
    final extension = fileName.split('.').last.toLowerCase();
    final ref = _storage.ref().child('$_storageFolder/$shopId/logo.$extension');

    final metadata = SettableMetadata(
      contentType: 'image/$extension',
      customMetadata: {'shopId': shopId},
    );

    await ref.putData(bytes, metadata);
    return await ref.getDownloadURL();
  }

  /// Delete logo from Firebase Storage
  Future<void> _deleteLogo(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Ignore deletion errors (file may not exist)
    }
  }

  /// Normalize phone number to standard format
  String _normalizePhone(String phone) {
    // Remove all non-digits
    var digits = phone.replaceAll(RegExp(r'\D'), '');

    // Remove leading 91 or 0 if present
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return digits;
  }
}
