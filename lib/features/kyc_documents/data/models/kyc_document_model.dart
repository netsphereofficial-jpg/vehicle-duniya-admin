import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/kyc_document.dart';

/// Data model for KYC Document with Firestore serialization
class KycDocumentModel extends KycDocument {
  const KycDocumentModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userPhone,
    super.userAddress,
    super.aadhaarNumber,
    super.aadhaarFrontUrl,
    super.aadhaarBackUrl,
    super.panNumber,
    super.panFrontUrl,
    super.panBackUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore document
  factory KycDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KycDocumentModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userPhone: data['userPhone'] as String? ?? '',
      userAddress: data['userAddress'] as String?,
      aadhaarNumber: data['aadhaarNumber'] as String?,
      aadhaarFrontUrl: data['aadhaarFrontUrl'] as String?,
      aadhaarBackUrl: data['aadhaarBackUrl'] as String?,
      panNumber: data['panNumber'] as String?,
      panFrontUrl: data['panFrontUrl'] as String?,
      panBackUrl: data['panBackUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'aadhaarNumber': aadhaarNumber,
      'aadhaarFrontUrl': aadhaarFrontUrl,
      'aadhaarBackUrl': aadhaarBackUrl,
      'panNumber': panNumber,
      'panFrontUrl': panFrontUrl,
      'panBackUrl': panBackUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from entity
  factory KycDocumentModel.fromEntity(KycDocument entity) {
    return KycDocumentModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userPhone: entity.userPhone,
      userAddress: entity.userAddress,
      aadhaarNumber: entity.aadhaarNumber,
      aadhaarFrontUrl: entity.aadhaarFrontUrl,
      aadhaarBackUrl: entity.aadhaarBackUrl,
      panNumber: entity.panNumber,
      panFrontUrl: entity.panFrontUrl,
      panBackUrl: entity.panBackUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Copy with new values
  KycDocumentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? userAddress,
    String? aadhaarNumber,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
    String? panNumber,
    String? panFrontUrl,
    String? panBackUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KycDocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userAddress: userAddress ?? this.userAddress,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      aadhaarFrontUrl: aadhaarFrontUrl ?? this.aadhaarFrontUrl,
      aadhaarBackUrl: aadhaarBackUrl ?? this.aadhaarBackUrl,
      panNumber: panNumber ?? this.panNumber,
      panFrontUrl: panFrontUrl ?? this.panFrontUrl,
      panBackUrl: panBackUrl ?? this.panBackUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
