import '../entities/app_settings.dart';

/// Abstract repository for app settings operations
abstract class SettingsRepository {
  /// Get current app settings
  Future<AppSettings> getSettings();

  /// Watch settings stream for real-time updates
  Stream<AppSettings> watchSettings();

  /// Update general settings (office address, contact info)
  Future<void> updateGeneralSettings({
    required String officeAddress,
    required String phone,
    required String email,
    required String fax,
  });

  /// Update about us content
  Future<void> updateAboutUs(String aboutUs);

  /// Update bidding terms and conditions
  Future<void> updateBiddingTerms(String biddingTerms);

  /// Update payment page settings
  Future<void> updatePaymentSettings({
    required bool paymentPageEnabled,
    required String paymentQrCodeUrl,
  });

  /// Update app version settings
  Future<void> updateAppVersion({
    required String appVersion,
    required String minAppVersion,
    required bool forceUpdate,
  });

  /// Update social links
  Future<void> updateSocialLinks(SocialLinks socialLinks);

  /// Upload payment QR code image and return URL
  Future<String> uploadPaymentQrCode(List<int> imageBytes, String fileName);

  /// Delete payment QR code image
  Future<void> deletePaymentQrCode(String imageUrl);
}
