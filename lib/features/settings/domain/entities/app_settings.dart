import 'package:equatable/equatable.dart';

/// Unified app settings entity containing all configurable settings
/// Designed for reusability across admin panel and mobile app
class AppSettings extends Equatable {
  // Office/Contact Information
  final String officeAddress;
  final String phone;
  final String email;
  final String fax;

  // About & Content
  final String aboutUs;
  final String biddingTerms;

  // Payment Settings
  final bool paymentPageEnabled;
  final String paymentQrCodeUrl;

  // App Version
  final String appVersion;
  final String minAppVersion;
  final bool forceUpdate;

  // Social Links
  final SocialLinks socialLinks;

  // Metadata
  final DateTime? updatedAt;

  const AppSettings({
    this.officeAddress = '',
    this.phone = '',
    this.email = '',
    this.fax = '',
    this.aboutUs = '',
    this.biddingTerms = '',
    this.paymentPageEnabled = false,
    this.paymentQrCodeUrl = '',
    this.appVersion = '1.0.0',
    this.minAppVersion = '1.0.0',
    this.forceUpdate = false,
    this.socialLinks = const SocialLinks(),
    this.updatedAt,
  });

  /// Empty settings instance
  static const empty = AppSettings();

  /// Check if settings are empty/default
  bool get isEmpty => this == empty;

  /// Copy with method for immutable updates
  AppSettings copyWith({
    String? officeAddress,
    String? phone,
    String? email,
    String? fax,
    String? aboutUs,
    String? biddingTerms,
    bool? paymentPageEnabled,
    String? paymentQrCodeUrl,
    String? appVersion,
    String? minAppVersion,
    bool? forceUpdate,
    SocialLinks? socialLinks,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      officeAddress: officeAddress ?? this.officeAddress,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fax: fax ?? this.fax,
      aboutUs: aboutUs ?? this.aboutUs,
      biddingTerms: biddingTerms ?? this.biddingTerms,
      paymentPageEnabled: paymentPageEnabled ?? this.paymentPageEnabled,
      paymentQrCodeUrl: paymentQrCodeUrl ?? this.paymentQrCodeUrl,
      appVersion: appVersion ?? this.appVersion,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      socialLinks: socialLinks ?? this.socialLinks,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        officeAddress,
        phone,
        email,
        fax,
        aboutUs,
        biddingTerms,
        paymentPageEnabled,
        paymentQrCodeUrl,
        appVersion,
        minAppVersion,
        forceUpdate,
        socialLinks,
        updatedAt,
      ];

  @override
  String toString() => 'AppSettings(version: $appVersion, payment: $paymentPageEnabled)';
}

/// Social links configuration
class SocialLinks extends Equatable {
  final String facebook;
  final bool facebookEnabled;
  final String twitter;
  final bool twitterEnabled;
  final String instagram;
  final bool instagramEnabled;
  final String youtube;
  final bool youtubeEnabled;
  final String linkedin;
  final bool linkedinEnabled;
  final String whatsapp;
  final bool whatsappEnabled;

  const SocialLinks({
    this.facebook = '',
    this.facebookEnabled = false,
    this.twitter = '',
    this.twitterEnabled = false,
    this.instagram = '',
    this.instagramEnabled = false,
    this.youtube = '',
    this.youtubeEnabled = false,
    this.linkedin = '',
    this.linkedinEnabled = false,
    this.whatsapp = '',
    this.whatsappEnabled = false,
  });

  /// Get list of enabled social links for display
  List<SocialLinkItem> get enabledLinks {
    final links = <SocialLinkItem>[];
    if (facebookEnabled && facebook.isNotEmpty) {
      links.add(SocialLinkItem(type: SocialLinkType.facebook, url: facebook));
    }
    if (twitterEnabled && twitter.isNotEmpty) {
      links.add(SocialLinkItem(type: SocialLinkType.twitter, url: twitter));
    }
    if (instagramEnabled && instagram.isNotEmpty) {
      links.add(SocialLinkItem(type: SocialLinkType.instagram, url: instagram));
    }
    if (youtubeEnabled && youtube.isNotEmpty) {
      links.add(SocialLinkItem(type: SocialLinkType.youtube, url: youtube));
    }
    if (linkedinEnabled && linkedin.isNotEmpty) {
      links.add(SocialLinkItem(type: SocialLinkType.linkedin, url: linkedin));
    }
    if (whatsappEnabled && whatsapp.isNotEmpty) {
      links.add(SocialLinkItem(type: SocialLinkType.whatsapp, url: whatsapp));
    }
    return links;
  }

  SocialLinks copyWith({
    String? facebook,
    bool? facebookEnabled,
    String? twitter,
    bool? twitterEnabled,
    String? instagram,
    bool? instagramEnabled,
    String? youtube,
    bool? youtubeEnabled,
    String? linkedin,
    bool? linkedinEnabled,
    String? whatsapp,
    bool? whatsappEnabled,
  }) {
    return SocialLinks(
      facebook: facebook ?? this.facebook,
      facebookEnabled: facebookEnabled ?? this.facebookEnabled,
      twitter: twitter ?? this.twitter,
      twitterEnabled: twitterEnabled ?? this.twitterEnabled,
      instagram: instagram ?? this.instagram,
      instagramEnabled: instagramEnabled ?? this.instagramEnabled,
      youtube: youtube ?? this.youtube,
      youtubeEnabled: youtubeEnabled ?? this.youtubeEnabled,
      linkedin: linkedin ?? this.linkedin,
      linkedinEnabled: linkedinEnabled ?? this.linkedinEnabled,
      whatsapp: whatsapp ?? this.whatsapp,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
    );
  }

  @override
  List<Object?> get props => [
        facebook,
        facebookEnabled,
        twitter,
        twitterEnabled,
        instagram,
        instagramEnabled,
        youtube,
        youtubeEnabled,
        linkedin,
        linkedinEnabled,
        whatsapp,
        whatsappEnabled,
      ];
}

/// Social link types enum
enum SocialLinkType {
  facebook,
  twitter,
  instagram,
  youtube,
  linkedin,
  whatsapp,
}

/// Helper class for social link item
class SocialLinkItem {
  final SocialLinkType type;
  final String url;

  const SocialLinkItem({required this.type, required this.url});
}
