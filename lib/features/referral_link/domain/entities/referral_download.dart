import 'package:equatable/equatable.dart';

/// Platform type for downloads
enum DownloadPlatform {
  android,
  ios,
  unknown,
}

/// Extension for DownloadPlatform
extension DownloadPlatformX on DownloadPlatform {
  String get label {
    switch (this) {
      case DownloadPlatform.android:
        return 'Android';
      case DownloadPlatform.ios:
        return 'iOS';
      case DownloadPlatform.unknown:
        return 'Unknown';
    }
  }

  String get icon {
    switch (this) {
      case DownloadPlatform.android:
        return 'android';
      case DownloadPlatform.ios:
        return 'apple';
      case DownloadPlatform.unknown:
        return 'device_unknown';
    }
  }
}

/// Referral download entity - tracks individual app downloads
class ReferralDownload extends Equatable {
  final String id;
  final String referralLinkId;
  final String referralCode;
  final String deviceId;
  final DownloadPlatform platform;
  final String? deviceModel;
  final String? osVersion;
  final String? userId;
  final String? userName;
  final String? userMobile;
  final bool isPremium;
  final DateTime downloadedAt;
  final DateTime? registeredAt;

  const ReferralDownload({
    required this.id,
    required this.referralLinkId,
    required this.referralCode,
    required this.deviceId,
    required this.platform,
    this.deviceModel,
    this.osVersion,
    this.userId,
    this.userName,
    this.userMobile,
    required this.isPremium,
    required this.downloadedAt,
    this.registeredAt,
  });

  /// Check if user has registered
  bool get isRegistered => userId != null && userId!.isNotEmpty;

  /// Get truncated device ID for display
  String get truncatedDeviceId {
    if (deviceId.length <= 12) return deviceId;
    return '${deviceId.substring(0, 8)}...${deviceId.substring(deviceId.length - 4)}';
  }

  /// Get device info summary
  String get deviceInfo {
    final parts = <String>[];
    if (deviceModel != null) parts.add(deviceModel!);
    if (osVersion != null) parts.add(osVersion!);
    return parts.isEmpty ? 'Unknown Device' : parts.join(' - ');
  }

  /// Get user display name
  String get userDisplayName {
    if (userName != null && userName!.isNotEmpty) return userName!;
    if (userMobile != null && userMobile!.isNotEmpty) return userMobile!;
    return 'Anonymous';
  }

  /// Copy with method
  ReferralDownload copyWith({
    String? id,
    String? referralLinkId,
    String? referralCode,
    String? deviceId,
    DownloadPlatform? platform,
    String? deviceModel,
    String? osVersion,
    String? userId,
    String? userName,
    String? userMobile,
    bool? isPremium,
    DateTime? downloadedAt,
    DateTime? registeredAt,
  }) {
    return ReferralDownload(
      id: id ?? this.id,
      referralLinkId: referralLinkId ?? this.referralLinkId,
      referralCode: referralCode ?? this.referralCode,
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userMobile: userMobile ?? this.userMobile,
      isPremium: isPremium ?? this.isPremium,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        referralLinkId,
        referralCode,
        deviceId,
        platform,
        deviceModel,
        osVersion,
        userId,
        userName,
        userMobile,
        isPremium,
        downloadedAt,
        registeredAt,
      ];
}
