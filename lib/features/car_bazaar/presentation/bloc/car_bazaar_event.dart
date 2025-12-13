import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/car_bazaar_shop.dart';

/// Base class for Car Bazaar events
sealed class CarBazaarEvent extends Equatable {
  const CarBazaarEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load/subscribe to shops
class LoadShopsRequested extends CarBazaarEvent {
  const LoadShopsRequested();
}

/// Internal event when shops stream updates
class ShopsStreamUpdated extends CarBazaarEvent {
  final List<CarBazaarShop> shops;

  const ShopsStreamUpdated(this.shops);

  @override
  List<Object?> get props => [shops];
}

/// Request to create a new shop
class CreateShopRequested extends CarBazaarEvent {
  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String address;
  final String? gstNumber;
  final String? licenseNumber;
  final BusinessType businessType;
  final Uint8List? logoBytes;
  final String? logoFileName;

  const CreateShopRequested({
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.address,
    this.gstNumber,
    this.licenseNumber,
    required this.businessType,
    this.logoBytes,
    this.logoFileName,
  });

  @override
  List<Object?> get props => [
        shopName,
        ownerName,
        phone,
        email,
        address,
        gstNumber,
        licenseNumber,
        businessType,
        logoBytes,
        logoFileName,
      ];
}

/// Request to update an existing shop
class UpdateShopRequested extends CarBazaarEvent {
  final String id;
  final String? shopName;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? licenseNumber;
  final BusinessType? businessType;
  final Uint8List? logoBytes;
  final String? logoFileName;
  final bool removeLogo;

  const UpdateShopRequested({
    required this.id,
    this.shopName,
    this.ownerName,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.licenseNumber,
    this.businessType,
    this.logoBytes,
    this.logoFileName,
    this.removeLogo = false,
  });

  @override
  List<Object?> get props => [
        id,
        shopName,
        ownerName,
        phone,
        email,
        address,
        gstNumber,
        licenseNumber,
        businessType,
        logoBytes,
        logoFileName,
        removeLogo,
      ];
}

/// Request to toggle shop active status
class ToggleShopStatusRequested extends CarBazaarEvent {
  final String id;
  final bool isActive;

  const ToggleShopStatusRequested({
    required this.id,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, isActive];
}

/// Request to reset shop password
class ResetPasswordRequested extends CarBazaarEvent {
  final String id;
  final String shopName;

  const ResetPasswordRequested({
    required this.id,
    required this.shopName,
  });

  @override
  List<Object?> get props => [id, shopName];
}

/// Request to delete a shop
class DeleteShopRequested extends CarBazaarEvent {
  final String id;

  const DeleteShopRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Request to search shops
class SearchShopsRequested extends CarBazaarEvent {
  final String query;

  const SearchShopsRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Request to filter shops by status
class FilterByStatusRequested extends CarBazaarEvent {
  final bool? isActive; // null = show all

  const FilterByStatusRequested(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

/// Request to clear messages
class ClearShopMessage extends CarBazaarEvent {
  const ClearShopMessage();
}

/// Request to clear created shop (after credentials shown)
class ClearCreatedShop extends CarBazaarEvent {
  const ClearCreatedShop();
}

/// Request to select a shop for detail view
class SelectShopRequested extends CarBazaarEvent {
  final String? id;

  const SelectShopRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Request to clear new password (after shown)
class ClearNewPassword extends CarBazaarEvent {
  const ClearNewPassword();
}
