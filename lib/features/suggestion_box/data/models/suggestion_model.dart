import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/suggestion.dart';

/// Firestore model for Suggestion
class SuggestionModel extends Suggestion {
  const SuggestionModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.fullName,
    required super.phone,
    super.email,
    required super.type,
    required super.subject,
    required super.message,
    required super.status,
    super.adminNotes,
    super.resolvedBy,
    required super.createdAt,
    required super.updatedAt,
    super.resolvedAt,
  });

  /// Create from Firestore document
  factory SuggestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SuggestionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      type: _typeFromString(data['type']),
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      status: _statusFromString(data['status']),
      adminNotes: data['adminNotes'],
      resolvedBy: data['resolvedBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create from entity
  factory SuggestionModel.fromEntity(Suggestion entity) {
    return SuggestionModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      fullName: entity.fullName,
      phone: entity.phone,
      email: entity.email,
      type: entity.type,
      subject: entity.subject,
      message: entity.message,
      status: entity.status,
      adminNotes: entity.adminNotes,
      resolvedBy: entity.resolvedBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      resolvedAt: entity.resolvedAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'type': type.name,
      'subject': subject,
      'message': message,
      'status': status.name,
      'adminNotes': adminNotes,
      'resolvedBy': resolvedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  /// Convert status from string
  static SuggestionStatus _statusFromString(String? value) {
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

  /// Convert type from string
  static SuggestionType _typeFromString(String? value) {
    switch (value) {
      case 'complaint':
        return SuggestionType.complaint;
      case 'feedback':
        return SuggestionType.feedback;
      case 'suggestion':
      default:
        return SuggestionType.suggestion;
    }
  }
}
