import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/referral_download.dart';

/// Firestore model for ReferralDownload
class ReferralDownloadModel extends ReferralDownload {
  const ReferralDownloadModel({
    required super.id,
    required super.referralLinkId,
    required super.referralCode,
    required super.deviceId,
    required super.platform,
    super.deviceModel,
    super.osVersion,
    super.userId,
    super.userName,
    super.userMobile,
    required super.isPremium,
    required super.downloadedAt,
    super.registeredAt,
  });

  /// Create from Firestore document
  factory ReferralDownloadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralDownloadModel(
      id: doc.id,
      referralLinkId: data['referralLinkId'] ?? '',
      referralCode: data['referralCode'] ?? '',
      deviceId: data['deviceId'] ?? '',
      platform: _platformFromString(data['platform']),
      deviceModel: data['deviceModel'],
      osVersion: data['osVersion'],
      userId: data['userId'],
      userName: data['userName'],
      userMobile: data['userMobile'],
      isPremium: data['isPremium'] ?? false,
      downloadedAt:
          (data['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registeredAt: (data['registeredAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create from entity
  factory ReferralDownloadModel.fromEntity(ReferralDownload entity) {
    return ReferralDownloadModel(
      id: entity.id,
      referralLinkId: entity.referralLinkId,
      referralCode: entity.referralCode,
      deviceId: entity.deviceId,
      platform: entity.platform,
      deviceModel: entity.deviceModel,
      osVersion: entity.osVersion,
      userId: entity.userId,
      userName: entity.userName,
      userMobile: entity.userMobile,
      isPremium: entity.isPremium,
      downloadedAt: entity.downloadedAt,
      registeredAt: entity.registeredAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'referralLinkId': referralLinkId,
      'referralCode': referralCode,
      'deviceId': deviceId,
      'platform': platform.name,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'userId': userId,
      'userName': userName,
      'userMobile': userMobile,
      'isPremium': isPremium,
      'downloadedAt': Timestamp.fromDate(downloadedAt),
      'registeredAt':
          registeredAt != null ? Timestamp.fromDate(registeredAt!) : null,
    };
  }

  /// Convert platform from string
  static DownloadPlatform _platformFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'android':
        return DownloadPlatform.android;
      case 'ios':
        return DownloadPlatform.ios;
      default:
        return DownloadPlatform.unknown;
    }
  }
}
