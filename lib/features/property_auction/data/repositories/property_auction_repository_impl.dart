import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/property_auction.dart';
import '../../domain/repositories/property_auction_repository.dart';
import '../models/property_auction_model.dart';

/// Firestore implementation of PropertyAuctionRepository
class PropertyAuctionRepositoryImpl implements PropertyAuctionRepository {
  final FirebaseFirestore _firestore;

  static const String _collection = 'property_auctions';

  PropertyAuctionRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _auctionsRef =>
      _firestore.collection(_collection);

  @override
  Stream<List<PropertyAuction>> watchAuctions({
    PropertyAuctionStatus? status,
    bool? isActive,
  }) {
    Query<Map<String, dynamic>> query = _auctionsRef;

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    query = query.orderBy('auctionStartDate', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyAuctionModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<PropertyAuction?> getAuctionById(String id) async {
    final doc = await _auctionsRef.doc(id).get();
    if (!doc.exists) return null;
    return PropertyAuctionModel.fromFirestore(doc);
  }

  @override
  Future<void> createAuctions(List<PropertyAuction> auctions) async {
    final batch = _firestore.batch();

    for (final auction in auctions) {
      final docRef = _auctionsRef.doc();
      final model = PropertyAuctionModel.fromEntity(
        auction.copyWith(id: docRef.id),
      );
      batch.set(docRef, model.toFirestore());
    }

    await batch.commit();
  }

  @override
  Future<void> updateAuction(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _auctionsRef.doc(id).update(data);
  }

  @override
  Future<void> updateAuctionDates({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Determine new status based on dates
    final now = DateTime.now();
    PropertyAuctionStatus status;
    if (now.isBefore(startDate)) {
      status = PropertyAuctionStatus.upcoming;
    } else if (now.isAfter(endDate)) {
      status = PropertyAuctionStatus.ended;
    } else {
      status = PropertyAuctionStatus.live;
    }

    await _auctionsRef.doc(id).update({
      'auctionStartDate': Timestamp.fromDate(startDate),
      'auctionEndDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteAuction(String id) async {
    await _auctionsRef.doc(id).delete();
  }

  @override
  Future<int> getTotalCount({bool? isActive}) async {
    Query<Map<String, dynamic>> query = _auctionsRef;
    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getCountByStatus(PropertyAuctionStatus status, {bool? isActive}) async {
    Query<Map<String, dynamic>> query = _auctionsRef
        .where('status', isEqualTo: status.name);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> updateAuctionStatuses() async {
    final now = DateTime.now();

    // Update upcoming to live
    final upcomingQuery = await _auctionsRef
        .where('status', isEqualTo: PropertyAuctionStatus.upcoming.name)
        .where('auctionStartDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    for (final doc in upcomingQuery.docs) {
      final data = doc.data();
      final endDate = (data['auctionEndDate'] as Timestamp).toDate();

      if (now.isAfter(endDate)) {
        await doc.reference.update({
          'status': PropertyAuctionStatus.ended.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await doc.reference.update({
          'status': PropertyAuctionStatus.live.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    // Update live to ended
    final liveQuery = await _auctionsRef
        .where('status', isEqualTo: PropertyAuctionStatus.live.name)
        .where('auctionEndDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    for (final doc in liveQuery.docs) {
      await doc.reference.update({
        'status': PropertyAuctionStatus.ended.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
