import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/car_bazaar_repository.dart';
import 'car_bazaar_event.dart';
import 'car_bazaar_state.dart';

/// BLoC for Car Bazaar shop management
class CarBazaarBloc extends Bloc<CarBazaarEvent, CarBazaarState> {
  final CarBazaarRepository _repository;
  final FirebaseAuth _auth;
  StreamSubscription? _shopsSubscription;

  CarBazaarBloc({
    required CarBazaarRepository repository,
    required FirebaseAuth auth,
  })  : _repository = repository,
        _auth = auth,
        super(const CarBazaarState()) {
    on<LoadShopsRequested>(_onLoadShops);
    on<ShopsStreamUpdated>(_onShopsStreamUpdated);
    on<CreateShopRequested>(_onCreateShop);
    on<UpdateShopRequested>(_onUpdateShop);
    on<ToggleShopStatusRequested>(_onToggleStatus);
    on<ResetPasswordRequested>(_onResetPassword);
    on<DeleteShopRequested>(_onDeleteShop);
    on<SearchShopsRequested>(_onSearch);
    on<FilterByStatusRequested>(_onFilterByStatus);
    on<ClearShopMessage>(_onClearMessage);
    on<ClearCreatedShop>(_onClearCreatedShop);
    on<ClearNewPassword>(_onClearNewPassword);
    on<SelectShopRequested>(_onSelectShop);
  }

  /// Handle load shops request
  Future<void> _onLoadShops(
    LoadShopsRequested event,
    Emitter<CarBazaarState> emit,
  ) async {
    emit(state.copyWith(status: CarBazaarStatus.loading));

    await _shopsSubscription?.cancel();
    _shopsSubscription = _repository.watchShops().listen(
          (shops) => add(ShopsStreamUpdated(shops)),
          onError: (error) => emit(state.copyWith(
            status: CarBazaarStatus.error,
            errorMessage: 'Failed to load shops: $error',
          )),
        );
  }

  /// Handle shops stream update
  void _onShopsStreamUpdated(
    ShopsStreamUpdated event,
    Emitter<CarBazaarState> emit,
  ) {
    emit(state.copyWith(
      shops: event.shops,
      status: CarBazaarStatus.loaded,
      clearError: true,
    ));
  }

  /// Handle create shop request
  Future<void> _onCreateShop(
    CreateShopRequested event,
    Emitter<CarBazaarState> emit,
  ) async {
    emit(state.copyWith(status: CarBazaarStatus.creating));

    try {
      final createdBy = _auth.currentUser?.uid ?? 'unknown';
      final shop = await _repository.createShop(
        shopName: event.shopName,
        ownerName: event.ownerName,
        phone: event.phone,
        email: event.email,
        address: event.address,
        gstNumber: event.gstNumber,
        licenseNumber: event.licenseNumber,
        businessType: event.businessType,
        logoBytes: event.logoBytes,
        logoFileName: event.logoFileName,
        createdBy: createdBy,
      );

      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        createdShop: shop, // Has password for display
        successMessage: 'Shop ${shop.shopId} created successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        errorMessage: 'Failed to create shop: $e',
      ));
    }
  }

  /// Handle update shop request
  Future<void> _onUpdateShop(
    UpdateShopRequested event,
    Emitter<CarBazaarState> emit,
  ) async {
    emit(state.copyWith(status: CarBazaarStatus.updating));

    try {
      await _repository.updateShop(
        id: event.id,
        shopName: event.shopName,
        ownerName: event.ownerName,
        phone: event.phone,
        email: event.email,
        address: event.address,
        gstNumber: event.gstNumber,
        licenseNumber: event.licenseNumber,
        businessType: event.businessType,
        logoBytes: event.logoBytes,
        logoFileName: event.logoFileName,
        removeLogo: event.removeLogo,
      );

      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        successMessage: 'Shop updated successfully!',
        clearSelectedShop: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        errorMessage: 'Failed to update shop: $e',
      ));
    }
  }

  /// Handle toggle status request
  Future<void> _onToggleStatus(
    ToggleShopStatusRequested event,
    Emitter<CarBazaarState> emit,
  ) async {
    emit(state.copyWith(status: CarBazaarStatus.updating));

    try {
      await _repository.toggleShopStatus(
        id: event.id,
        isActive: event.isActive,
      );

      final statusText = event.isActive ? 'activated' : 'deactivated';
      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        successMessage: 'Shop $statusText successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        errorMessage: 'Failed to update status: $e',
      ));
    }
  }

  /// Handle reset password request
  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<CarBazaarState> emit,
  ) async {
    emit(state.copyWith(status: CarBazaarStatus.updating));

    try {
      final newPassword = await _repository.resetPassword(event.id);

      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        newPassword: newPassword,
        successMessage: 'Password reset for ${event.shopName}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        errorMessage: 'Failed to reset password: $e',
      ));
    }
  }

  /// Handle delete shop request
  Future<void> _onDeleteShop(
    DeleteShopRequested event,
    Emitter<CarBazaarState> emit,
  ) async {
    emit(state.copyWith(status: CarBazaarStatus.updating));

    try {
      await _repository.deleteShop(event.id);

      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        successMessage: 'Shop deleted successfully!',
        clearSelectedShop: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        errorMessage: 'Failed to delete shop: $e',
      ));
    }
  }

  /// Handle search request
  void _onSearch(
    SearchShopsRequested event,
    Emitter<CarBazaarState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  /// Handle filter by status request
  void _onFilterByStatus(
    FilterByStatusRequested event,
    Emitter<CarBazaarState> emit,
  ) {
    if (event.isActive == null) {
      emit(state.copyWith(clearFilterByActive: true));
    } else {
      emit(state.copyWith(filterByActive: event.isActive));
    }
  }

  /// Handle clear message request
  void _onClearMessage(
    ClearShopMessage event,
    Emitter<CarBazaarState> emit,
  ) {
    emit(state.copyWith(
      clearError: true,
      clearSuccess: true,
    ));
  }

  /// Handle clear created shop request
  void _onClearCreatedShop(
    ClearCreatedShop event,
    Emitter<CarBazaarState> emit,
  ) {
    emit(state.copyWith(
      clearCreatedShop: true,
    ));
  }

  /// Handle clear new password request
  void _onClearNewPassword(
    ClearNewPassword event,
    Emitter<CarBazaarState> emit,
  ) {
    emit(state.copyWith(
      clearNewPassword: true,
    ));
  }

  /// Handle select shop request
  void _onSelectShop(
    SelectShopRequested event,
    Emitter<CarBazaarState> emit,
  ) {
    if (event.id == null) {
      emit(state.copyWith(clearSelectedShop: true));
      return;
    }

    final shop = state.shops.firstWhere(
      (s) => s.id == event.id,
      orElse: () => state.shops.first,
    );

    emit(state.copyWith(selectedShop: shop));
  }

  @override
  Future<void> close() {
    _shopsSubscription?.cancel();
    return super.close();
  }
}
