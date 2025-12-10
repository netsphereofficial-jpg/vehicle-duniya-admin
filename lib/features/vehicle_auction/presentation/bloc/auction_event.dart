import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auction.dart';
import '../../domain/entities/vehicle_item.dart';

/// Base class for all auction events
abstract class AuctionEvent extends Equatable {
  const AuctionEvent();

  @override
  List<Object?> get props => [];
}

// ============ Category Events ============

/// Load all categories
class LoadCategoriesRequested extends AuctionEvent {
  const LoadCategoriesRequested();
}

// ============ Auction Events ============

/// Load auctions with optional status filter
class LoadAuctionsRequested extends AuctionEvent {
  final AuctionStatus? statusFilter;

  const LoadAuctionsRequested({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

/// Load a single auction by ID
class LoadAuctionDetailRequested extends AuctionEvent {
  final String auctionId;

  const LoadAuctionDetailRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Create a new auction
class CreateAuctionRequested extends AuctionEvent {
  final String name;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final AuctionMode mode;
  final bool checkBasePrice;
  final EventType eventType;
  final String? eventId;
  final ZipType zipType;

  const CreateAuctionRequested({
    required this.name,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.mode,
    required this.checkBasePrice,
    required this.eventType,
    this.eventId,
    required this.zipType,
  });

  @override
  List<Object?> get props => [
        name,
        category,
        startDate,
        endDate,
        mode,
        checkBasePrice,
        eventType,
        eventId,
        zipType,
      ];
}

/// Update an existing auction
class UpdateAuctionRequested extends AuctionEvent {
  final String auctionId;
  final Map<String, dynamic> updates;

  const UpdateAuctionRequested({
    required this.auctionId,
    required this.updates,
  });

  @override
  List<Object?> get props => [auctionId, updates];
}

/// Delete an auction
class DeleteAuctionRequested extends AuctionEvent {
  final String auctionId;

  const DeleteAuctionRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Update auction status
class UpdateAuctionStatusRequested extends AuctionEvent {
  final String auctionId;
  final AuctionStatus status;

  const UpdateAuctionStatusRequested({
    required this.auctionId,
    required this.status,
  });

  @override
  List<Object?> get props => [auctionId, status];
}

// ============ File Upload Events ============

/// Upload bid report file
class UploadBidReportRequested extends AuctionEvent {
  final String auctionId;
  final dynamic fileBytes;
  final String fileName;

  const UploadBidReportRequested({
    required this.auctionId,
    required this.fileBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [auctionId, fileName];
}

/// Upload images zip file
class UploadImagesZipRequested extends AuctionEvent {
  final String auctionId;
  final dynamic fileBytes;
  final String fileName;

  const UploadImagesZipRequested({
    required this.auctionId,
    required this.fileBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [auctionId, fileName];
}

// ============ Vehicle Events ============

/// Load vehicles for an auction
class LoadAuctionVehiclesRequested extends AuctionEvent {
  final String auctionId;

  const LoadAuctionVehiclesRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Add a vehicle to an auction
class AddVehicleToAuctionRequested extends AuctionEvent {
  final VehicleItem vehicle;

  const AddVehicleToAuctionRequested(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

/// Update a vehicle
class UpdateVehicleRequested extends AuctionEvent {
  final String vehicleId;
  final Map<String, dynamic> updates;

  const UpdateVehicleRequested({
    required this.vehicleId,
    required this.updates,
  });

  @override
  List<Object?> get props => [vehicleId, updates];
}

/// Remove a vehicle from an auction
class RemoveVehicleFromAuctionRequested extends AuctionEvent {
  final String auctionId;
  final String vehicleId;

  const RemoveVehicleFromAuctionRequested({
    required this.auctionId,
    required this.vehicleId,
  });

  @override
  List<Object?> get props => [auctionId, vehicleId];
}

// ============ UI State Events ============

/// Clear any error message
class ClearAuctionError extends AuctionEvent {
  const ClearAuctionError();
}

/// Reset the auction state
class ResetAuctionState extends AuctionEvent {
  const ResetAuctionState();
}

/// Set the selected auction
class SelectAuction extends AuctionEvent {
  final Auction? auction;

  const SelectAuction(this.auction);

  @override
  List<Object?> get props => [auction];
}

// ============ Excel Import Events ============

/// Import vehicles from Excel file
class ImportVehiclesFromExcel extends AuctionEvent {
  final Uint8List fileBytes;
  final String auctionId;

  const ImportVehiclesFromExcel({
    required this.fileBytes,
    required this.auctionId,
  });

  @override
  List<Object?> get props => [auctionId];
}

/// Clear imported vehicles (reset import state)
class ClearImportedVehicles extends AuctionEvent {
  const ClearImportedVehicles();
}
