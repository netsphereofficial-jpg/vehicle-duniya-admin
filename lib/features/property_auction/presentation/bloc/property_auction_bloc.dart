import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/property_excel_import_service.dart';
import '../../domain/repositories/property_auction_repository.dart';
import 'property_auction_event.dart';
import 'property_auction_state.dart';

/// BLoC for Property Auction management
class PropertyAuctionBloc extends Bloc<PropertyAuctionEvent, PropertyAuctionState> {
  final PropertyAuctionRepository _repository;
  final FirebaseAuth _auth;
  StreamSubscription? _auctionsSubscription;

  PropertyAuctionBloc({
    required PropertyAuctionRepository repository,
    required FirebaseAuth auth,
  })  : _repository = repository,
        _auth = auth,
        super(const PropertyAuctionState()) {
    on<LoadAuctionsRequested>(_onLoadAuctions);
    on<AuctionsStreamUpdated>(_onAuctionsStreamUpdated);
    on<CreateAuctionsRequested>(_onCreateAuctions);
    on<PreviewImportRequested>(_onPreviewImport);
    on<ClearImportPreview>(_onClearImportPreview);
    on<UpdateAuctionDatesRequested>(_onUpdateAuctionDates);
    on<DeleteAuctionRequested>(_onDeleteAuction);
    on<SearchAuctionsRequested>(_onSearch);
    on<FilterByStatusRequested>(_onFilterByStatus);
    on<SelectAuctionRequested>(_onSelectAuction);
    on<ClearError>(_onClearError);
    on<ClearSuccess>(_onClearSuccess);
    on<UpdateStatusesRequested>(_onUpdateStatuses);
  }

  /// Handle load auctions request
  Future<void> _onLoadAuctions(
    LoadAuctionsRequested event,
    Emitter<PropertyAuctionState> emit,
  ) async {
    emit(state.copyWith(
      status: PropertyAuctionBlocStatus.loading,
      filterStatus: event.status,
      filterIsActive: event.isActive,
    ));

    await _auctionsSubscription?.cancel();
    _auctionsSubscription = _repository
        .watchAuctions(status: event.status, isActive: event.isActive)
        .listen(
          (auctions) => add(AuctionsStreamUpdated(auctions)),
          onError: (error) => emit(state.copyWith(
            status: PropertyAuctionBlocStatus.error,
            errorMessage: 'Failed to load auctions: $error',
          )),
        );
  }

  /// Handle auctions stream update
  void _onAuctionsStreamUpdated(
    AuctionsStreamUpdated event,
    Emitter<PropertyAuctionState> emit,
  ) {
    emit(state.copyWith(
      auctions: event.auctions,
      status: PropertyAuctionBlocStatus.loaded,
      clearError: true,
    ));
  }

  /// Handle create auctions from Excel
  Future<void> _onCreateAuctions(
    CreateAuctionsRequested event,
    Emitter<PropertyAuctionState> emit,
  ) async {
    emit(state.copyWith(status: PropertyAuctionBlocStatus.creating));

    try {
      final createdBy = _auth.currentUser?.uid ?? 'unknown';

      // Parse Excel file
      final result = PropertyExcelImportService.parseExcelFile(
        bytes: event.excelBytes,
        startDate: event.startDate,
        endDate: event.endDate,
        createdBy: createdBy,
      );

      if (result.auctions.isEmpty) {
        emit(state.copyWith(
          status: PropertyAuctionBlocStatus.error,
          errorMessage: result.errors.isNotEmpty
              ? result.errors.first
              : 'No valid properties found in Excel file',
          importResult: result,
        ));
        return;
      }

      // Create auctions in Firestore
      await _repository.createAuctions(result.auctions);

      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.created,
        importResult: result,
        successMessage: '${result.successfulRows} properties imported successfully!',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.error,
        errorMessage: 'Failed to create auctions: $e',
      ));
    }
  }

  /// Handle preview import (parse without saving)
  Future<void> _onPreviewImport(
    PreviewImportRequested event,
    Emitter<PropertyAuctionState> emit,
  ) async {
    emit(state.copyWith(status: PropertyAuctionBlocStatus.importing));

    try {
      final createdBy = _auth.currentUser?.uid ?? 'unknown';

      final result = PropertyExcelImportService.parseExcelFile(
        bytes: event.excelBytes,
        startDate: event.startDate,
        endDate: event.endDate,
        createdBy: createdBy,
      );

      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.imported,
        importResult: result,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.error,
        errorMessage: 'Failed to parse Excel file: $e',
      ));
    }
  }

  /// Clear import preview
  void _onClearImportPreview(
    ClearImportPreview event,
    Emitter<PropertyAuctionState> emit,
  ) {
    emit(state.copyWith(
      clearImportResult: true,
      status: PropertyAuctionBlocStatus.loaded,
    ));
  }

  /// Handle update auction dates
  Future<void> _onUpdateAuctionDates(
    UpdateAuctionDatesRequested event,
    Emitter<PropertyAuctionState> emit,
  ) async {
    emit(state.copyWith(status: PropertyAuctionBlocStatus.updating));

    try {
      await _repository.updateAuctionDates(
        id: event.auctionId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.updated,
        successMessage: 'Auction dates updated successfully!',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.error,
        errorMessage: 'Failed to update auction: $e',
      ));
    }
  }

  /// Handle delete auction
  Future<void> _onDeleteAuction(
    DeleteAuctionRequested event,
    Emitter<PropertyAuctionState> emit,
  ) async {
    emit(state.copyWith(status: PropertyAuctionBlocStatus.deleting));

    try {
      await _repository.deleteAuction(event.auctionId);

      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.deleted,
        successMessage: 'Auction deleted successfully!',
        clearSelectedAuction: true,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertyAuctionBlocStatus.error,
        errorMessage: 'Failed to delete auction: $e',
      ));
    }
  }

  /// Handle search
  void _onSearch(
    SearchAuctionsRequested event,
    Emitter<PropertyAuctionState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  /// Handle filter by status
  void _onFilterByStatus(
    FilterByStatusRequested event,
    Emitter<PropertyAuctionState> emit,
  ) {
    if (event.status == null) {
      emit(state.copyWith(clearFilterStatus: true));
    } else {
      emit(state.copyWith(filterStatus: event.status));
    }
  }

  /// Handle select auction
  void _onSelectAuction(
    SelectAuctionRequested event,
    Emitter<PropertyAuctionState> emit,
  ) {
    if (event.auctionId == null) {
      emit(state.copyWith(clearSelectedAuction: true));
      return;
    }

    final auction = state.auctions.firstWhere(
      (a) => a.id == event.auctionId,
      orElse: () => state.auctions.first,
    );

    emit(state.copyWith(selectedAuction: auction));
  }

  /// Handle clear error
  void _onClearError(
    ClearError event,
    Emitter<PropertyAuctionState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  /// Handle clear success
  void _onClearSuccess(
    ClearSuccess event,
    Emitter<PropertyAuctionState> emit,
  ) {
    emit(state.copyWith(clearSuccess: true));
  }

  /// Update auction statuses based on dates
  Future<void> _onUpdateStatuses(
    UpdateStatusesRequested event,
    Emitter<PropertyAuctionState> emit,
  ) async {
    try {
      await _repository.updateAuctionStatuses();
    } catch (e) {
      // Silently fail - this is a background operation
    }
  }

  @override
  Future<void> close() {
    _auctionsSubscription?.cancel();
    return super.close();
  }
}
