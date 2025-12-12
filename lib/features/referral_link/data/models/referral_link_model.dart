import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/referral_link.dart';

/// Firestore model for ReferralLink
class ReferralLinkModel extends ReferralLink {
  const ReferralLinkModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.code,
    required super.downloadCount,
    required super.premiumConversions,
    required super.isActive,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore document
  factory ReferralLinkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralLinkModel(
      id: doc.id,
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      code: data['code'] ?? '',
      downloadCount: data['downloadCount'] ?? 0,
      premiumConversions: data['premiumConversions'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from entity
  factory ReferralLinkModel.fromEntity(ReferralLink entity) {
    return ReferralLinkModel(
      id: entity.id,
      name: entity.name,
      mobile: entity.mobile,
      code: entity.code,
      downloadCount: entity.downloadCount,
      premiumConversions: entity.premiumConversions,
      isActive: entity.isActive,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to Firestore map (for create)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'mobile': mobile,
      'code': code,
      'downloadCount': downloadCount,
      'premiumConversions': premiumConversions,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to Firestore map (for update - excludes createdAt)
  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'name': name,
      'mobile': mobile,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Generate unique referral code (VD + 6 alphanumeric chars)
  /// Format: VD-XXXXXX (e.g., VD-A3X7K2)
  static String generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final code = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    return 'VD$code';
  }
}
