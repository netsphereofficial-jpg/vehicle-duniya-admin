import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/property_auction.dart';

/// Base class for Property Auction events
sealed class PropertyAuctionEvent extends Equatable {
  const PropertyAuctionEvent();

  @override
  List<Object?> get props => [];
}

/// Load auctions with optional filters
class LoadAuctionsRequested extends PropertyAuctionEvent {
  final PropertyAuctionStatus? status;
  final bool? isActive;

  const LoadAuctionsRequested({
    this.status,
    this.isActive,
  });

  @override
  List<Object?> get props => [status, isActive];
}

/// Internal event when auctions stream updates
class AuctionsStreamUpdated extends PropertyAuctionEvent {
  final List<PropertyAuction> auctions;

  const AuctionsStreamUpdated(this.auctions);

  @override
  List<Object?> get props => [auctions];
}

/// Create auctions from Excel file
class CreateAuctionsRequested extends PropertyAuctionEvent {
  final DateTime startDate;
  final DateTime endDate;
  final Uint8List excelBytes;
  final String fileName;

  const CreateAuctionsRequested({
    required this.startDate,
    required this.endDate,
    required this.excelBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [startDate, endDate, excelBytes, fileName];
}

/// Preview Excel import without saving
class PreviewImportRequested extends PropertyAuctionEvent {
  final DateTime startDate;
  final DateTime endDate;
  final Uint8List excelBytes;
  final String fileName;

  const PreviewImportRequested({
    required this.startDate,
    required this.endDate,
    required this.excelBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [startDate, endDate, excelBytes, fileName];
}

/// Clear import preview
class ClearImportPreview extends PropertyAuctionEvent {
  const ClearImportPreview();
}

/// Update auction dates
class UpdateAuctionDatesRequested extends PropertyAuctionEvent {
  final String auctionId;
  final DateTime startDate;
  final DateTime endDate;

  const UpdateAuctionDatesRequested({
    required this.auctionId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [auctionId, startDate, endDate];
}

/// Delete auction
class DeleteAuctionRequested extends PropertyAuctionEvent {
  final String auctionId;

  const DeleteAuctionRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Search auctions
class SearchAuctionsRequested extends PropertyAuctionEvent {
  final String query;

  const SearchAuctionsRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by status
class FilterByStatusRequested extends PropertyAuctionEvent {
  final PropertyAuctionStatus? status;

  const FilterByStatusRequested(this.status);

  @override
  List<Object?> get props => [status];
}

/// Select auction for detail view
class SelectAuctionRequested extends PropertyAuctionEvent {
  final String? auctionId;

  const SelectAuctionRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

/// Clear error message
class ClearError extends PropertyAuctionEvent {
  const ClearError();
}

/// Clear success message
class ClearSuccess extends PropertyAuctionEvent {
  const ClearSuccess();
}

/// Update auction statuses based on dates
class UpdateStatusesRequested extends PropertyAuctionEvent {
  const UpdateStatusesRequested();
}
