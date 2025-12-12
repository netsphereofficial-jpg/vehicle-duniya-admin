import 'package:equatable/equatable.dart';

/// Referral link entity for tracking app downloads
class ReferralLink extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String code;
  final int downloadCount;
  final int premiumConversions;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReferralLink({
    required this.id,
    required this.name,
    required this.mobile,
    required this.code,
    required this.downloadCount,
    required this.premiumConversions,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get formatted code with hyphen (VD-XXXXXX)
  String get formattedCode {
    if (code.length >= 8 && code.startsWith('VD')) {
      return '${code.substring(0, 2)}-${code.substring(2)}';
    }
    return code;
  }

  /// Get formatted mobile with +91
  String get formattedMobile =>
      mobile.startsWith('+91') ? mobile : '+91 $mobile';

  /// Calculate conversion rate (premium/downloads)
  double get conversionRate {
    if (downloadCount == 0) return 0;
    return (premiumConversions / downloadCount) * 100;
  }

  /// Get formatted conversion rate
  String get formattedConversionRate => '${conversionRate.toStringAsFixed(1)}%';

  /// Check if link has downloads
  bool get hasDownloads => downloadCount > 0;

  /// Copy with method
  ReferralLink copyWith({
    String? id,
    String? name,
    String? mobile,
    String? code,
    int? downloadCount,
    int? premiumConversions,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReferralLink(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      code: code ?? this.code,
      downloadCount: downloadCount ?? this.downloadCount,
      premiumConversions: premiumConversions ?? this.premiumConversions,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        code,
        downloadCount,
        premiumConversions,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
