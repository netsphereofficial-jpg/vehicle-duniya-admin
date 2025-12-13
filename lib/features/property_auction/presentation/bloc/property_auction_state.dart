import 'package:equatable/equatable.dart';

import '../../data/services/property_excel_import_service.dart';
import '../../domain/entities/property_auction.dart';

/// Status enum for Property Auction operations
enum PropertyAuctionBlocStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
  importing,
  imported,
  error,
}

/// State for Property Auction BLoC
class PropertyAuctionState extends Equatable {
  final List<PropertyAuction> auctions;
  final PropertyAuction? selectedAuction;
  final PropertyAuctionBlocStatus status;
  final String searchQuery;
  final PropertyAuctionStatus? filterStatus;
  final bool? filterIsActive;
  final PropertyExcelImportResult? importResult;
  final String? errorMessage;
  final String? successMessage;

  const PropertyAuctionState({
    this.auctions = const [],
    this.selectedAuction,
    this.status = PropertyAuctionBlocStatus.initial,
    this.searchQuery = '',
    this.filterStatus,
    this.filterIsActive,
    this.importResult,
    this.errorMessage,
    this.successMessage,
  });

  /// Create a copy with optional field updates
  PropertyAuctionState copyWith({
    List<PropertyAuction>? auctions,
    PropertyAuction? selectedAuction,
    PropertyAuctionBlocStatus? status,
    String? searchQuery,
    PropertyAuctionStatus? filterStatus,
    bool? filterIsActive,
    PropertyExcelImportResult? importResult,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedAuction = false,
    bool clearFilterStatus = false,
    bool clearFilterIsActive = false,
    bool clearImportResult = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PropertyAuctionState(
      auctions: auctions ?? this.auctions,
      selectedAuction: clearSelectedAuction ? null : (selectedAuction ?? this.selectedAuction),
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      filterIsActive: clearFilterIsActive ? null : (filterIsActive ?? this.filterIsActive),
      importResult: clearImportResult ? null : (importResult ?? this.importResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  // Convenience getters
  bool get isLoading => status == PropertyAuctionBlocStatus.loading;
  bool get isCreating => status == PropertyAuctionBlocStatus.creating;
  bool get isUpdating => status == PropertyAuctionBlocStatus.updating;
  bool get isDeleting => status == PropertyAuctionBlocStatus.deleting;
  bool get isImporting => status == PropertyAuctionBlocStatus.importing;
  bool get hasError => status == PropertyAuctionBlocStatus.error && errorMessage != null;
  bool get hasSuccess => successMessage != null;

  /// Filtered auctions based on search query
  List<PropertyAuction> get filteredAuctions {
    var result = auctions;

    // Apply status filter
    if (filterStatus != null) {
      result = result.where((a) => a.status == filterStatus).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((auction) {
        return auction.eventNo.toLowerCase().contains(query) ||
            auction.eventTitle.toLowerCase().contains(query) ||
            auction.eventBank.toLowerCase().contains(query) ||
            auction.propertyDescription.toLowerCase().contains(query) ||
            auction.borrowerName.toLowerCase().contains(query) ||
            auction.propertyCategory.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  /// Get auctions by status
  List<PropertyAuction> get liveAuctions =>
      auctions.where((a) => a.status == PropertyAuctionStatus.live).toList();

  List<PropertyAuction> get upcomingAuctions =>
      auctions.where((a) => a.status == PropertyAuctionStatus.upcoming).toList();

  List<PropertyAuction> get endedAuctions =>
      auctions.where((a) => a.status == PropertyAuctionStatus.ended).toList();

  List<PropertyAuction> get activeAuctions =>
      auctions.where((a) => a.isActive).toList();

  List<PropertyAuction> get inactiveAuctions =>
      auctions.where((a) => !a.isActive || a.status == PropertyAuctionStatus.ended).toList();

  /// Counts
  int get totalCount => auctions.length;
  int get liveCount => liveAuctions.length;
  int get upcomingCount => upcomingAuctions.length;
  int get endedCount => endedAuctions.length;
  int get activeCount => activeAuctions.length;
  int get inactiveCount => inactiveAuctions.length;

  @override
  List<Object?> get props => [
        auctions,
        selectedAuction,
        status,
        searchQuery,
        filterStatus,
        filterIsActive,
        importResult,
        errorMessage,
        successMessage,
      ];
}
