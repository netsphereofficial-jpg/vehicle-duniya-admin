import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/kyc_document.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../models/kyc_document_model.dart';

/// Implementation of KYC repository using Firestore
class KycRepositoryImpl implements KycRepository {
  final FirebaseFirestore _firestore;

  static const String _collection = 'kyc_documents';

  KycRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _kycCollection =>
      _firestore.collection(_collection);

  @override
  Stream<List<KycDocument>> watchKycDocuments() {
    return _kycCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KycDocumentModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<List<KycDocument>> getKycDocuments({
    int limit = 50,
    String? lastDocumentId,
  }) async {
    Query<Map<String, dynamic>> query =
        _kycCollection.orderBy('createdAt', descending: true).limit(limit);

    if (lastDocumentId != null) {
      final lastDoc = await _kycCollection.doc(lastDocumentId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => KycDocumentModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<KycDocument?> getKycDocumentById(String id) async {
    final doc = await _kycCollection.doc(id).get();
    if (!doc.exists) return null;
    return KycDocumentModel.fromFirestore(doc);
  }

  @override
  Future<KycDocument?> getKycDocumentByUserId(String userId) async {
    final snapshot = await _kycCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return KycDocumentModel.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<List<KycDocument>> searchKycDocuments(String query) async {
    final normalizedQuery = query.toLowerCase().trim();

    // Search across userName and userPhone
    // Firestore doesn't support full-text search, so we fetch and filter
    final snapshot = await _kycCollection
        .orderBy('createdAt', descending: true)
        .limit(500)
        .get();

    return snapshot.docs
        .map((doc) => KycDocumentModel.fromFirestore(doc))
        .where((doc) =>
            doc.userName.toLowerCase().contains(normalizedQuery) ||
            doc.userPhone.contains(normalizedQuery) ||
            (doc.panNumber?.toLowerCase().contains(normalizedQuery) ?? false) ||
            (doc.aadhaarNumber?.contains(normalizedQuery) ?? false))
        .toList();
  }

  @override
  Future<int> getTotalCount() async {
    final snapshot = await _kycCollection.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> deleteKycDocument(String id) async {
    await _kycCollection.doc(id).delete();
  }
}
