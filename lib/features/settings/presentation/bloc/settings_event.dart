import 'package:equatable/equatable.dart';

import '../../domain/entities/app_settings.dart';

/// Base class for all settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings (starts real-time stream)
class LoadSettingsRequested extends SettingsEvent {
  const LoadSettingsRequested();
}

/// Internal event for real-time updates from Firestore stream
class SettingsUpdated extends SettingsEvent {
  final AppSettings settings;

  const SettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Update general/contact settings
class UpdateGeneralSettingsRequested extends SettingsEvent {
  final String officeAddress;
  final String phone;
  final String email;
  final String fax;

  const UpdateGeneralSettingsRequested({
    required this.officeAddress,
    required this.phone,
    required this.email,
    required this.fax,
  });

  @override
  List<Object?> get props => [officeAddress, phone, email, fax];
}

/// Update about us content
class UpdateAboutUsRequested extends SettingsEvent {
  final String aboutUs;

  const UpdateAboutUsRequested(this.aboutUs);

  @override
  List<Object?> get props => [aboutUs];
}

/// Update bidding terms and conditions
class UpdateBiddingTermsRequested extends SettingsEvent {
  final String biddingTerms;

  const UpdateBiddingTermsRequested(this.biddingTerms);

  @override
  List<Object?> get props => [biddingTerms];
}

/// Update payment page settings
class UpdatePaymentSettingsRequested extends SettingsEvent {
  final bool paymentPageEnabled;
  final String paymentQrCodeUrl;

  const UpdatePaymentSettingsRequested({
    required this.paymentPageEnabled,
    required this.paymentQrCodeUrl,
  });

  @override
  List<Object?> get props => [paymentPageEnabled, paymentQrCodeUrl];
}

/// Upload payment QR code image
class UploadPaymentQrCodeRequested extends SettingsEvent {
  final List<int> imageBytes;
  final String fileName;
  final bool paymentPageEnabled;

  const UploadPaymentQrCodeRequested({
    required this.imageBytes,
    required this.fileName,
    required this.paymentPageEnabled,
  });

  @override
  List<Object?> get props => [imageBytes, fileName, paymentPageEnabled];
}

/// Update app version settings
class UpdateAppVersionRequested extends SettingsEvent {
  final String appVersion;
  final String minAppVersion;
  final bool forceUpdate;

  const UpdateAppVersionRequested({
    required this.appVersion,
    required this.minAppVersion,
    required this.forceUpdate,
  });

  @override
  List<Object?> get props => [appVersion, minAppVersion, forceUpdate];
}

/// Update social links
class UpdateSocialLinksRequested extends SettingsEvent {
  final SocialLinks socialLinks;

  const UpdateSocialLinksRequested(this.socialLinks);

  @override
  List<Object?> get props => [socialLinks];
}

/// Clear any error message
class ClearSettingsError extends SettingsEvent {
  const ClearSettingsError();
}

/// Clear success message
class ClearSettingsSuccess extends SettingsEvent {
  const ClearSettingsSuccess();
}
