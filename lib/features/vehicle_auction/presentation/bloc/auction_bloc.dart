import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/app_logger.dart';
import '../../data/services/vehicle_excel_import_service.dart';
import '../../domain/repositories/auction_repository.dart';
import 'auction_event.dart';
import 'auction_state.dart';

/// BLoC for managing auction state and operations
class AuctionBloc extends Bloc<AuctionEvent, AuctionState> {
  static const _tag = 'AuctionBloc';
  final AuctionRepository _repository;
  final FirebaseAuth _auth;

  AuctionBloc({
    required AuctionRepository repository,
    FirebaseAuth? auth,
  })  : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance,
        super(const AuctionState.initial()) {
    // Category events
    on<LoadCategoriesRequested>(_onLoadCategories);

    // Auction events
    on<LoadAuctionsRequested>(_onLoadAuctions);
    on<LoadAuctionDetailRequested>(_onLoadAuctionDetail);
    on<CreateAuctionRequested>(_onCreateAuction);
    on<UpdateAuctionRequested>(_onUpdateAuction);
    on<DeleteAuctionRequested>(_onDeleteAuction);
    on<UpdateAuctionStatusRequested>(_onUpdateAuctionStatus);

    // File upload events
    on<UploadBidReportRequested>(_onUploadBidReport);
    on<UploadImagesZipRequested>(_onUploadImagesZip);

    // Vehicle events
    on<LoadAuctionVehiclesRequested>(_onLoadAuctionVehicles);
    on<AddVehicleToAuctionRequested>(_onAddVehicle);
    on<UpdateVehicleRequested>(_onUpdateVehicle);
    on<RemoveVehicleFromAuctionRequested>(_onRemoveVehicle);

    // UI state events
    on<ClearAuctionError>(_onClearError);
    on<ResetAuctionState>(_onResetState);
    on<SelectAuction>(_onSelectAuction);

    // Excel import events
    on<ImportVehiclesFromExcel>(_onImportVehiclesFromExcel);
    on<ClearImportedVehicles>(_onClearImportedVehicles);
  }

  // ============ Category Handlers ============

  Future<void> _onLoadCategories(
    LoadCategoriesRequested event,
    Emitter<AuctionState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'LoadCategoriesRequested');
    try {
      final categories = await _repository.getCategories();
      AppLogger.info(_tag, 'Loaded ${categories.length} categories');
      emit(state.copyWith(categories: categories));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to load categories', e);
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to load categories: ${e.toString()}',
      ));
    }
  }

  // ============ Auction Handlers ============

  Future<void> _onLoadAuctions(
    LoadAuctionsRequested event,
    Emitter<AuctionState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'LoadAuctionsRequested');
    AppLogger.debug(_tag, 'Filter: ${event.statusFilter ?? "none"}');
    emit(state.copyWith(
      status: AuctionStateStatus.loading,
      currentFilter: event.statusFilter,
      clearFilter: event.statusFilter == null,
    ));

    try {
      final auctions = await _repository.getAuctions(
        statusFilter: event.statusFilter,
      );
      AppLogger.info(_tag, 'Loaded ${auctions.length} auctions');
      emit(state.copyWith(
        status: AuctionStateStatus.loaded,
        auctions: auctions,
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to load auctions', e);
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to load auctions: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadAuctionDetail(
    LoadAuctionDetailRequested event,
    Emitter<AuctionState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'LoadAuctionDetailRequested');
    AppLogger.debug(_tag, 'Auction ID: ${event.auctionId}');
    emit(state.copyWith(status: AuctionStateStatus.loading));

    try {
      final auction = await _repository.getAuctionById(event.auctionId);
      final vehicles = await _repository.getVehiclesByAuction(event.auctionId);
      AppLogger.info(_tag, 'Loaded auction: ${auction.name} with ${vehicles.length} vehicles');

      emit(state.copyWith(
        status: AuctionStateStatus.loaded,
        selectedAuction: auction,
        auctionVehicles: vehicles,
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to load auction details', e);
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to load auction details: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateAuction(
    CreateAuctionRequested event,
    Emitter<AuctionState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'CreateAuctionRequested');
    AppLogger.debug(_tag, 'Creating auction: ${event.name}');
    emit(state.copyWith(status: AuctionStateStatus.creating));

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        AppLogger.error(_tag, 'User not authenticated');
        throw Exception('User not authenticated');
      }

      final auction = await _repository.createAuction(
        name: event.name,
        category: event.category,
        startDate: event.startDate,
        endDate: event.endDate,
        mode: event.mode,
        checkBasePrice: event.checkBasePrice,
        eventType: event.eventType,
        eventId: event.eventId,
        zipType: event.zipType,
        createdBy: currentUser.uid,
      );

      AppLogger.info(_tag, 'Auction created: ${auction.id}');
      emit(state.copyWith(
        status: AuctionStateStatus.created,
        auctions: [auction, ...state.auctions],
        selectedAuction: auction,
        successMessage: 'Auction created successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to create auction', e);
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to create auction: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateAuction(
    UpdateAuctionRequested event,
    Emitter<AuctionState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdateAuctionRequested');
    AppLogger.debug(_tag, 'Updating auction: ${event.auctionId}');
    emit(state.copyWith(status: AuctionStateStatus.updating));

    try {
      await _repository.updateAuction(event.auctionId, event.updates);

      // Reload the auction to get updated data
      final updatedAuction = await _repository.getAuctionById(event.auctionId);

      // Update the auctions list
      final updatedAuctions = state.auctions.map((a) {
        return a.id == event.auctionId ? updatedAuction : a;
      }).toList();

      AppLogger.info(_tag, 'Auction updated: ${event.auctionId}');
      emit(state.copyWith(
        status: AuctionStateStatus.updated,
        auctions: updatedAuctions,
        selectedAuction: state.selectedAuction?.id == event.auctionId
            ? updatedAuction
            : state.selectedAuction,
        successMessage: 'Auction updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update auction', e);
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to update auction: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteAuction(
    DeleteAuctionRequested event,
    Emitter<AuctionState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'DeleteAuctionRequested');
    AppLogger.warning(_tag, 'Deleting auction: ${event.auctionId}');
    emit(state.copyWith(status: AuctionStateStatus.deleting));

    try {
      await _repository.deleteAuction(event.auctionId);

      // Remove from auctions list
      final updatedAuctions = state.auctions
          .where((a) => a.id != event.auctionId)
          .toList();

      AppLogger.info(_tag, 'Auction deleted: ${event.auctionId}');
      emit(state.copyWith(
        status: AuctionStateStatus.deleted,
        auctions: updatedAuctions,
        clearSelectedAuction: state.selectedAuction?.id == event.auctionId,
        successMessage: 'Auction deleted successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to delete auction', e);
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to delete auction: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateAuctionStatus(
    UpdateAuctionStatusRequested event,
    Emitter<AuctionState> emit,
  ) async {
    emit(state.copyWith(status: AuctionStateStatus.updating));

    try {
      await _repository.updateAuctionStatus(event.auctionId, event.status);

      // Update the auctions list
      final updatedAuctions = state.auctions.map((a) {
        if (a.id == event.auctionId) {
          return a.copyWith(status: event.status);
        }
        return a;
      }).toList();

      emit(state.copyWith(
        status: AuctionStateStatus.updated,
        auctions: updatedAuctions,
        successMessage: 'Auction status updated!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to update status: ${e.toString()}',
      ));
    }
  }

  // ============ File Upload Handlers ============

  Future<void> _onUploadBidReport(
    UploadBidReportRequested event,
    Emitter<AuctionState> emit,
  ) async {
    emit(state.copyWith(
      status: AuctionStateStatus.uploading,
      uploadProgress: 0,
    ));

    try {
      await _repository.uploadBidReport(
        event.auctionId,
        event.fileBytes,
        event.fileName,
      );

      emit(state.copyWith(
        status: AuctionStateStatus.uploaded,
        uploadProgress: 100,
        successMessage: 'Bid report uploaded successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to upload bid report: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUploadImagesZip(
    UploadImagesZipRequested event,
    Emitter<AuctionState> emit,
  ) async {
    emit(state.copyWith(
      status: AuctionStateStatus.uploading,
      uploadProgress: 0,
    ));

    try {
      await _repository.uploadImagesZip(
        event.auctionId,
        event.fileBytes,
        event.fileName,
      );

      emit(state.copyWith(
        status: AuctionStateStatus.uploaded,
        uploadProgress: 100,
        successMessage: 'Images zip uploaded successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to upload images: ${e.toString()}',
      ));
    }
  }

  // ============ Vehicle Handlers ============

  Future<void> _onLoadAuctionVehicles(
    LoadAuctionVehiclesRequested event,
    Emitter<AuctionState> emit,
  ) async {
    try {
      final vehicles = await _repository.getVehiclesByAuction(event.auctionId);
      emit(state.copyWith(auctionVehicles: vehicles));
    } catch (e) {
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to load vehicles: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicleToAuctionRequested event,
    Emitter<AuctionState> emit,
  ) async {
    emit(state.copyWith(status: AuctionStateStatus.creating));

    try {
      final vehicle = await _repository.addVehicleToAuction(event.vehicle);

      emit(state.copyWith(
        status: AuctionStateStatus.created,
        auctionVehicles: [...state.auctionVehicles, vehicle],
        successMessage: 'Vehicle added successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to add vehicle: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleRequested event,
    Emitter<AuctionState> emit,
  ) async {
    emit(state.copyWith(status: AuctionStateStatus.updating));

    try {
      await _repository.updateVehicle(event.vehicleId, event.updates);

      // Reload vehicles
      if (state.selectedAuction != null) {
        final vehicles = await _repository.getVehiclesByAuction(
          state.selectedAuction!.id,
        );
        emit(state.copyWith(
          status: AuctionStateStatus.updated,
          auctionVehicles: vehicles,
          successMessage: 'Vehicle updated successfully!',
        ));
      } else {
        emit(state.copyWith(
          status: AuctionStateStatus.updated,
          successMessage: 'Vehicle updated successfully!',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to update vehicle: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRemoveVehicle(
    RemoveVehicleFromAuctionRequested event,
    Emitter<AuctionState> emit,
  ) async {
    emit(state.copyWith(status: AuctionStateStatus.deleting));

    try {
      await _repository.removeVehicleFromAuction(
        event.auctionId,
        event.vehicleId,
      );

      // Remove from vehicles list
      final updatedVehicles = state.auctionVehicles
          .where((v) => v.id != event.vehicleId)
          .toList();

      emit(state.copyWith(
        status: AuctionStateStatus.deleted,
        auctionVehicles: updatedVehicles,
        successMessage: 'Vehicle removed successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to remove vehicle: ${e.toString()}',
      ));
    }
  }

  // ============ UI State Handlers ============

  void _onClearError(
    ClearAuctionError event,
    Emitter<AuctionState> emit,
  ) {
    emit(state.copyWith(
      status: AuctionStateStatus.loaded,
      clearError: true,
      clearSuccess: true,
    ));
  }

  void _onResetState(
    ResetAuctionState event,
    Emitter<AuctionState> emit,
  ) {
    emit(const AuctionState.initial());
  }

  void _onSelectAuction(
    SelectAuction event,
    Emitter<AuctionState> emit,
  ) {
    if (event.auction == null) {
      emit(state.copyWith(
        clearSelectedAuction: true,
        auctionVehicles: [],
      ));
    } else {
      emit(state.copyWith(selectedAuction: event.auction));
    }
  }

  // ============ Excel Import Handlers ============

  Future<void> _onImportVehiclesFromExcel(
    ImportVehiclesFromExcel event,
    Emitter<AuctionState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'ImportVehiclesFromExcel');
    AppLogger.debug(_tag, 'Importing vehicles for auction: ${event.auctionId}');
    emit(state.copyWith(
      status: AuctionStateStatus.importing,
      clearImportedVehicles: true,
      importErrors: [],
    ));

    try {
      final result = VehicleExcelImportService.parseExcelFile(
        event.fileBytes,
        event.auctionId,
      );

      AppLogger.info(
        _tag,
        'Import result: ${result.successfulRows}/${result.totalRows} vehicles',
      );

      if (result.errors.isNotEmpty) {
        AppLogger.warning(_tag, 'Import errors: ${result.errors.length}');
      }

      emit(state.copyWith(
        status: AuctionStateStatus.imported,
        importedVehicles: result.vehicles,
        importErrors: result.errors,
        importTotalRows: result.totalRows,
        importSuccessfulRows: result.successfulRows,
        successMessage: result.isSuccess
            ? '${result.successfulRows} vehicles imported successfully!'
            : '${result.successfulRows}/${result.totalRows} vehicles imported with ${result.errors.length} errors',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to import vehicles', e);
      emit(state.copyWith(
        status: AuctionStateStatus.error,
        errorMessage: 'Failed to import vehicles: ${e.toString()}',
      ));
    }
  }

  void _onClearImportedVehicles(
    ClearImportedVehicles event,
    Emitter<AuctionState> emit,
  ) {
    emit(state.copyWith(
      clearImportedVehicles: true,
      importErrors: [],
      importTotalRows: 0,
      importSuccessfulRows: 0,
    ));
  }
}
