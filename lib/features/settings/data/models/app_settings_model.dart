import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_settings.dart';

/// AppSettings model with Firestore serialization
class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    super.officeAddress,
    super.phone,
    super.email,
    super.fax,
    super.aboutUs,
    super.biddingTerms,
    super.paymentPageEnabled,
    super.paymentQrCodeUrl,
    super.appVersion,
    super.minAppVersion,
    super.forceUpdate,
    super.socialLinks,
    super.updatedAt,
  });

  /// Create AppSettingsModel from Firestore document
  factory AppSettingsModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return const AppSettingsModel();

    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppSettingsModel.fromMap(data);
  }

  /// Create AppSettingsModel from Map
  factory AppSettingsModel.fromMap(Map<String, dynamic> data) {
    return AppSettingsModel(
      officeAddress: data['officeAddress'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      fax: data['fax'] as String? ?? '',
      aboutUs: data['aboutUs'] as String? ?? '',
      biddingTerms: data['biddingTerms'] as String? ?? '',
      paymentPageEnabled: data['paymentPageEnabled'] as bool? ?? false,
      paymentQrCodeUrl: data['paymentQrCodeUrl'] as String? ?? '',
      appVersion: data['appVersion'] as String? ?? '1.0.0',
      minAppVersion: data['minAppVersion'] as String? ?? '1.0.0',
      forceUpdate: data['forceUpdate'] as bool? ?? false,
      socialLinks: SocialLinksModel.fromMap(
        data['socialLinks'] as Map<String, dynamic>? ?? {},
      ),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  /// Create AppSettingsModel from AppSettings entity
  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      officeAddress: settings.officeAddress,
      phone: settings.phone,
      email: settings.email,
      fax: settings.fax,
      aboutUs: settings.aboutUs,
      biddingTerms: settings.biddingTerms,
      paymentPageEnabled: settings.paymentPageEnabled,
      paymentQrCodeUrl: settings.paymentQrCodeUrl,
      appVersion: settings.appVersion,
      minAppVersion: settings.minAppVersion,
      forceUpdate: settings.forceUpdate,
      socialLinks: settings.socialLinks,
      updatedAt: settings.updatedAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'officeAddress': officeAddress,
      'phone': phone,
      'email': email,
      'fax': fax,
      'aboutUs': aboutUs,
      'biddingTerms': biddingTerms,
      'paymentPageEnabled': paymentPageEnabled,
      'paymentQrCodeUrl': paymentQrCodeUrl,
      'appVersion': appVersion,
      'minAppVersion': minAppVersion,
      'forceUpdate': forceUpdate,
      'socialLinks': SocialLinksModel.fromEntity(socialLinks).toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

/// SocialLinks model with Firestore serialization
class SocialLinksModel extends SocialLinks {
  const SocialLinksModel({
    super.facebook,
    super.facebookEnabled,
    super.twitter,
    super.twitterEnabled,
    super.instagram,
    super.instagramEnabled,
    super.youtube,
    super.youtubeEnabled,
    super.linkedin,
    super.linkedinEnabled,
    super.whatsapp,
    super.whatsappEnabled,
  });

  /// Create SocialLinksModel from Map
  factory SocialLinksModel.fromMap(Map<String, dynamic> data) {
    return SocialLinksModel(
      facebook: data['facebook'] as String? ?? '',
      facebookEnabled: data['facebookEnabled'] as bool? ?? false,
      twitter: data['twitter'] as String? ?? '',
      twitterEnabled: data['twitterEnabled'] as bool? ?? false,
      instagram: data['instagram'] as String? ?? '',
      instagramEnabled: data['instagramEnabled'] as bool? ?? false,
      youtube: data['youtube'] as String? ?? '',
      youtubeEnabled: data['youtubeEnabled'] as bool? ?? false,
      linkedin: data['linkedin'] as String? ?? '',
      linkedinEnabled: data['linkedinEnabled'] as bool? ?? false,
      whatsapp: data['whatsapp'] as String? ?? '',
      whatsappEnabled: data['whatsappEnabled'] as bool? ?? false,
    );
  }

  /// Create SocialLinksModel from SocialLinks entity
  factory SocialLinksModel.fromEntity(SocialLinks links) {
    return SocialLinksModel(
      facebook: links.facebook,
      facebookEnabled: links.facebookEnabled,
      twitter: links.twitter,
      twitterEnabled: links.twitterEnabled,
      instagram: links.instagram,
      instagramEnabled: links.instagramEnabled,
      youtube: links.youtube,
      youtubeEnabled: links.youtubeEnabled,
      linkedin: links.linkedin,
      linkedinEnabled: links.linkedinEnabled,
      whatsapp: links.whatsapp,
      whatsappEnabled: links.whatsappEnabled,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'facebook': facebook,
      'facebookEnabled': facebookEnabled,
      'twitter': twitter,
      'twitterEnabled': twitterEnabled,
      'instagram': instagram,
      'instagramEnabled': instagramEnabled,
      'youtube': youtube,
      'youtubeEnabled': youtubeEnabled,
      'linkedin': linkedin,
      'linkedinEnabled': linkedinEnabled,
      'whatsapp': whatsapp,
      'whatsappEnabled': whatsappEnabled,
    };
  }
}
