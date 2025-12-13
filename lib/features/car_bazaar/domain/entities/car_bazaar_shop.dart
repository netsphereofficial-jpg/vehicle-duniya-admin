import 'package:equatable/equatable.dart';

/// Business types for Car Bazaar shops
enum BusinessType {
  dealer('Dealer'),
  showroom('Showroom'),
  individual('Individual'),
  multiShowroom('Multi-Brand Showroom'),
  usedCarDealer('Used Car Dealer');

  final String label;
  const BusinessType(this.label);

  static BusinessType fromString(String value) {
    return BusinessType.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => BusinessType.dealer,
    );
  }
}

/// Entity representing a Car Bazaar shop account
class CarBazaarShop extends Equatable {
  final String id;
  final String shopId; // CB001, CB002...
  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String address;
  final String? gstNumber;
  final String? licenseNumber;
  final BusinessType businessType;
  final String? logoUrl;
  final String? password; // Only populated after creation for display
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CarBazaarShop({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.address,
    this.gstNumber,
    this.licenseNumber,
    required this.businessType,
    this.logoUrl,
    this.password,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with optional field updates
  CarBazaarShop copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
    String? licenseNumber,
    BusinessType? businessType,
    String? logoUrl,
    String? password,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearGstNumber = false,
    bool clearLicenseNumber = false,
    bool clearLogoUrl = false,
    bool clearPassword = false,
  }) {
    return CarBazaarShop(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstNumber: clearGstNumber ? null : (gstNumber ?? this.gstNumber),
      licenseNumber:
          clearLicenseNumber ? null : (licenseNumber ?? this.licenseNumber),
      businessType: businessType ?? this.businessType,
      logoUrl: clearLogoUrl ? null : (logoUrl ?? this.logoUrl),
      password: clearPassword ? null : (password ?? this.password),
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formatted phone for display (+91 prefix)
  String get formattedPhone {
    if (phone.startsWith('+91')) return phone;
    if (phone.startsWith('91') && phone.length == 12) {
      return '+$phone';
    }
    return '+91 $phone';
  }

  /// Check if shop has GST registration
  bool get hasGst => gstNumber != null && gstNumber!.isNotEmpty;

  /// Check if shop has trade license
  bool get hasLicense => licenseNumber != null && licenseNumber!.isNotEmpty;

  /// Check if shop has logo
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        shopId,
        shopName,
        ownerName,
        phone,
        email,
        address,
        gstNumber,
        licenseNumber,
        businessType,
        logoUrl,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
