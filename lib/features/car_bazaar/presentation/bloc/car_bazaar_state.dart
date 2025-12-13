import 'package:equatable/equatable.dart';

import '../../domain/entities/car_bazaar_shop.dart';

/// Status enum for Car Bazaar operations
enum CarBazaarStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  error,
}

/// State for Car Bazaar BLoC
class CarBazaarState extends Equatable {
  final List<CarBazaarShop> shops;
  final CarBazaarShop? createdShop; // Holds credentials after creation
  final CarBazaarShop? selectedShop; // For detail view
  final String? newPassword; // For password reset display
  final String searchQuery;
  final bool? filterByActive;
  final CarBazaarStatus status;
  final String? errorMessage;
  final String? successMessage;

  const CarBazaarState({
    this.shops = const [],
    this.createdShop,
    this.selectedShop,
    this.newPassword,
    this.searchQuery = '',
    this.filterByActive,
    this.status = CarBazaarStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  /// Get filtered shops based on search and filter
  List<CarBazaarShop> get filteredShops {
    var result = shops;

    // Apply active filter
    if (filterByActive != null) {
      result = result.where((s) => s.isActive == filterByActive).toList();
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((s) {
        return s.shopId.toLowerCase().contains(query) ||
            s.shopName.toLowerCase().contains(query) ||
            s.ownerName.toLowerCase().contains(query) ||
            s.phone.contains(query) ||
            s.email.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  /// Total shops count
  int get totalShops => shops.length;

  /// Active shops count
  int get activeShops => shops.where((s) => s.isActive).length;

  /// Inactive shops count
  int get inactiveShops => shops.where((s) => !s.isActive).length;

  /// Check if loading
  bool get isLoading => status == CarBazaarStatus.loading;

  /// Check if creating
  bool get isCreating => status == CarBazaarStatus.creating;

  /// Check if updating
  bool get isUpdating => status == CarBazaarStatus.updating;

  /// Check if has error
  bool get hasError =>
      status == CarBazaarStatus.error && errorMessage != null;

  /// Check if has success message
  bool get hasSuccess => successMessage != null;

  /// Check if credentials dialog should be shown
  bool get showCredentials => createdShop != null;

  /// Check if password reset dialog should be shown
  bool get showNewPassword => newPassword != null;

  CarBazaarState copyWith({
    List<CarBazaarShop>? shops,
    CarBazaarShop? createdShop,
    CarBazaarShop? selectedShop,
    String? newPassword,
    String? searchQuery,
    bool? filterByActive,
    CarBazaarStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearCreatedShop = false,
    bool clearSelectedShop = false,
    bool clearNewPassword = false,
    bool clearFilterByActive = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CarBazaarState(
      shops: shops ?? this.shops,
      createdShop: clearCreatedShop ? null : (createdShop ?? this.createdShop),
      selectedShop:
          clearSelectedShop ? null : (selectedShop ?? this.selectedShop),
      newPassword: clearNewPassword ? null : (newPassword ?? this.newPassword),
      searchQuery: searchQuery ?? this.searchQuery,
      filterByActive:
          clearFilterByActive ? null : (filterByActive ?? this.filterByActive),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        shops,
        createdShop,
        selectedShop,
        newPassword,
        searchQuery,
        filterByActive,
        status,
        errorMessage,
        successMessage,
      ];
}
