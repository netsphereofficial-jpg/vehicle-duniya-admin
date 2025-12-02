import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/auction.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/vehicle_item.dart';
import '../../domain/repositories/auction_repository.dart';
import '../models/auction_model.dart';
import '../models/category_model.dart';
import '../models/vehicle_item_model.dart';

/// Implementation of AuctionRepository using Firebase
class AuctionRepositoryImpl implements AuctionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // Collection names
  static const String _categoriesCollection = 'categories';
  static const String _auctionsCollection = 'auctions';
  static const String _vehiclesCollection = 'vehicles';

  // Storage paths
  static const String _auctionStoragePath = 'auctions';
  static const String _bidReportsPath = 'bid_reports';
  static const String _imagesZipPath = 'images_zip';

  AuctionRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ============ Helper Getters ============

  CollectionReference get _categoriesRef =>
      _firestore.collection(_categoriesCollection);

  CollectionReference get _auctionsRef =>
      _firestore.collection(_auctionsCollection);

  CollectionReference get _vehiclesRef =>
      _firestore.collection(_vehiclesCollection);

  // ============ Categories ============

  @override
  Future<List<Category>> getCategories() async {
    final snapshot = await _categoriesRef
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _categoriesRef
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // ============ Auctions ============

  @override
  Future<List<Auction>> getAuctions({AuctionStatus? statusFilter}) async {
    Query query = _auctionsRef.orderBy('createdAt', descending: true);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.name);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AuctionModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<Auction> getAuctionById(String id) async {
    final doc = await _auctionsRef.doc(id).get();

    if (!doc.exists) {
      throw Exception('Auction not found');
    }

    return AuctionModel.fromFirestore(doc);
  }

  @override
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
  }) async {
    final now = DateTime.now();

    // Determine initial status based on start date
    final status = startDate.isAfter(now)
        ? AuctionStatus.upcoming
        : AuctionStatus.live;

    // Get category name
    String categoryName = '';
    try {
      final categoryDoc = await _categoriesRef.doc(category).get();
      if (categoryDoc.exists) {
        final data = categoryDoc.data() as Map<String, dynamic>?;
        categoryName = data?['name'] ?? '';
      }
    } catch (_) {
      // Ignore error, use empty category name
    }

    final auctionData = {
      'name': name,
      'category': category,
      'categoryName': categoryName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'mode': mode.name,
      'checkBasePrice': checkBasePrice,
      'eventType': eventType.name,
      'eventId': eventId,
      'bidReportUrl': null,
      'imagesZipUrl': null,
      'zipType': zipType.name,
      'status': status.name,
      'vehicleIds': <String>[],
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    final docRef = await _auctionsRef.add(auctionData);
    final doc = await docRef.get();

    return AuctionModel.fromFirestore(doc);
  }

  @override
  Future<void> updateAuction(String id, Map<String, dynamic> updates) async {
    // Add updatedAt timestamp
    updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

    // Convert DateTime fields to Timestamp
    if (updates.containsKey('startDate') && updates['startDate'] is DateTime) {
      updates['startDate'] = Timestamp.fromDate(updates['startDate']);
    }
    if (updates.containsKey('endDate') && updates['endDate'] is DateTime) {
      updates['endDate'] = Timestamp.fromDate(updates['endDate']);
    }

    await _auctionsRef.doc(id).update(updates);
  }

  @override
  Future<void> deleteAuction(String id) async {
    // First, delete all vehicles in this auction
    final vehiclesSnapshot = await _vehiclesRef
        .where('auctionId', isEqualTo: id)
        .get();

    final batch = _firestore.batch();

    for (final doc in vehiclesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the auction
    batch.delete(_auctionsRef.doc(id));

    await batch.commit();

    // Delete associated files from storage
    try {
      final auctionStorageRef = _storage.ref().child(_auctionStoragePath).child(id);
      final listResult = await auctionStorageRef.listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (_) {
      // Ignore storage deletion errors
    }
  }

  @override
  Future<void> updateAuctionStatus(String id, AuctionStatus status) async {
    await _auctionsRef.doc(id).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ============ File Uploads ============

  @override
  Future<String> uploadBidReport(
    String auctionId,
    dynamic fileBytes,
    String fileName,
  ) async {
    final ref = _storage
        .ref()
        .child(_auctionStoragePath)
        .child(auctionId)
        .child(_bidReportsPath)
        .child(fileName);

    final uploadTask = await ref.putData(
      fileBytes is Uint8List ? fileBytes : Uint8List.fromList(fileBytes),
      SettableMetadata(contentType: _getContentType(fileName)),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Update auction with bid report URL
    await _auctionsRef.doc(auctionId).update({
      'bidReportUrl': downloadUrl,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return downloadUrl;
  }

  @override
  Future<String> uploadImagesZip(
    String auctionId,
    dynamic fileBytes,
    String fileName,
  ) async {
    final ref = _storage
        .ref()
        .child(_auctionStoragePath)
        .child(auctionId)
        .child(_imagesZipPath)
        .child(fileName);

    final uploadTask = await ref.putData(
      fileBytes is Uint8List ? fileBytes : Uint8List.fromList(fileBytes),
      SettableMetadata(contentType: 'application/zip'),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Update auction with images zip URL
    await _auctionsRef.doc(auctionId).update({
      'imagesZipUrl': downloadUrl,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return downloadUrl;
  }

  // ============ Vehicles ============

  @override
  Future<List<VehicleItem>> getVehiclesByAuction(String auctionId) async {
    final snapshot = await _vehiclesRef
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => VehicleItemModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<VehicleItem> getVehicleById(String id) async {
    final doc = await _vehiclesRef.doc(id).get();

    if (!doc.exists) {
      throw Exception('Vehicle not found');
    }

    return VehicleItemModel.fromFirestore(doc);
  }

  @override
  Future<VehicleItem> addVehicleToAuction(VehicleItem vehicle) async {
    final vehicleModel = VehicleItemModel.fromEntity(vehicle);
    final docRef = await _vehiclesRef.add(vehicleModel.toFirestore());

    // Update auction's vehicleIds
    await _auctionsRef.doc(vehicle.auctionId).update({
      'vehicleIds': FieldValue.arrayUnion([docRef.id]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    final doc = await docRef.get();
    return VehicleItemModel.fromFirestore(doc);
  }

  @override
  Future<void> updateVehicle(
    String vehicleId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _vehiclesRef.doc(vehicleId).update(updates);
  }

  @override
  Future<void> removeVehicleFromAuction(
    String auctionId,
    String vehicleId,
  ) async {
    // Delete the vehicle document
    await _vehiclesRef.doc(vehicleId).delete();

    // Remove from auction's vehicleIds
    await _auctionsRef.doc(auctionId).update({
      'vehicleIds': FieldValue.arrayRemove([vehicleId]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ============ Streams ============

  @override
  Stream<List<Auction>> watchAuctions({AuctionStatus? statusFilter}) {
    Query query = _auctionsRef.orderBy('createdAt', descending: true);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.name);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => AuctionModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<Auction> watchAuctionById(String id) {
    return _auctionsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Auction not found');
      }
      return AuctionModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<VehicleItem>> watchVehiclesByAuction(String auctionId) {
    return _vehiclesRef
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleItemModel.fromFirestore(doc))
            .toList());
  }

  // ============ Helpers ============

  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'xlsx':
      case 'xls':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
}
