import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/suggestion.dart';
import '../../domain/repositories/suggestion_repository.dart';
import '../models/suggestion_model.dart';

/// Firebase implementation of SuggestionRepository
class SuggestionRepositoryImpl implements SuggestionRepository {
  final FirebaseFirestore _firestore;

  SuggestionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('suggestions');

  @override
  Stream<List<Suggestion>> watchSuggestions() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SuggestionModel.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Future<Suggestion?> getSuggestionById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return SuggestionModel.fromFirestore(doc);
  }

  @override
  Future<void> updateStatus({
    required String suggestionId,
    required SuggestionStatus status,
    String? adminNotes,
    String? resolvedBy,
  }) async {
    final updateData = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (adminNotes != null) {
      updateData['adminNotes'] = adminNotes;
    }

    if (resolvedBy != null) {
      updateData['resolvedBy'] = resolvedBy;
    }

    // Set resolvedAt for resolved/closed statuses
    if (status == SuggestionStatus.resolved ||
        status == SuggestionStatus.closed) {
      updateData['resolvedAt'] = FieldValue.serverTimestamp();
    }

    await _collection.doc(suggestionId).update(updateData);
  }

  @override
  Future<void> addAdminNotes({
    required String suggestionId,
    required String notes,
  }) async {
    await _collection.doc(suggestionId).update({
      'adminNotes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteSuggestion(String suggestionId) async {
    await _collection.doc(suggestionId).delete();
  }

  @override
  Future<Map<SuggestionStatus, int>> getSuggestionsCountByStatus() async {
    final snapshot = await _collection.get();
    final counts = <SuggestionStatus, int>{
      SuggestionStatus.pending: 0,
      SuggestionStatus.inProgress: 0,
      SuggestionStatus.resolved: 0,
      SuggestionStatus.closed: 0,
    };

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final statusStr = data['status'] as String?;
      final status = _statusFromString(statusStr);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  /// Convert status from string
  SuggestionStatus _statusFromString(String? value) {
    switch (value) {
      case 'inProgress':
        return SuggestionStatus.inProgress;
      case 'resolved':
        return SuggestionStatus.resolved;
      case 'closed':
        return SuggestionStatus.closed;
      case 'pending':
      default:
        return SuggestionStatus.pending;
    }
  }
}
