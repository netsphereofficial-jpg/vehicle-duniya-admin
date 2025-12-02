import 'package:equatable/equatable.dart';
import '../../domain/entities/auction.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/vehicle_item.dart';

/// Status enum for auction operations
enum AuctionStateStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
  uploading,
  uploaded,
  error,
}

/// State class for auction bloc
class AuctionState extends Equatable {
  final AuctionStateStatus status;
  final List<Category> categories;
  final List<Auction> auctions;
  final Auction? selectedAuction;
  final List<VehicleItem> auctionVehicles;
  final String? errorMessage;
  final String? successMessage;
  final double uploadProgress;
  final AuctionStatus? currentFilter;

  const AuctionState({
    this.status = AuctionStateStatus.initial,
    this.categories = const [],
    this.auctions = const [],
    this.selectedAuction,
    this.auctionVehicles = const [],
    this.errorMessage,
    this.successMessage,
    this.uploadProgress = 0,
    this.currentFilter,
  });

  /// Initial state
  const AuctionState.initial() : this();

  /// Loading state
  const AuctionState.loading()
      : this(status: AuctionStateStatus.loading);

  /// Copy with method for immutable updates
  AuctionState copyWith({
    AuctionStateStatus? status,
    List<Category>? categories,
    List<Auction>? auctions,
    Auction? selectedAuction,
    bool clearSelectedAuction = false,
    List<VehicleItem>? auctionVehicles,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    double? uploadProgress,
    AuctionStatus? currentFilter,
    bool clearFilter = false,
  }) {
    return AuctionState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      auctions: auctions ?? this.auctions,
      selectedAuction: clearSelectedAuction ? null : (selectedAuction ?? this.selectedAuction),
      auctionVehicles: auctionVehicles ?? this.auctionVehicles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      uploadProgress: uploadProgress ?? this.uploadProgress,
      currentFilter: clearFilter ? null : (currentFilter ?? this.currentFilter),
    );
  }

  // ============ Convenience Getters ============

  /// Check if currently loading
  bool get isLoading => status == AuctionStateStatus.loading;

  /// Check if currently creating
  bool get isCreating => status == AuctionStateStatus.creating;

  /// Check if currently updating
  bool get isUpdating => status == AuctionStateStatus.updating;

  /// Check if currently deleting
  bool get isDeleting => status == AuctionStateStatus.deleting;

  /// Check if currently uploading
  bool get isUploading => status == AuctionStateStatus.uploading;

  /// Check if there's an error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Check if there's a success message
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;

  /// Get active auctions (upcoming + live)
  List<Auction> get activeAuctions => auctions
      .where((a) =>
          a.status == AuctionStatus.upcoming ||
          a.status == AuctionStatus.live)
      .toList();

  /// Get inactive auctions (ended + cancelled)
  List<Auction> get inactiveAuctions => auctions
      .where((a) =>
          a.status == AuctionStatus.ended ||
          a.status == AuctionStatus.cancelled)
      .toList();

  /// Get upcoming auctions
  List<Auction> get upcomingAuctions =>
      auctions.where((a) => a.status == AuctionStatus.upcoming).toList();

  /// Get live auctions
  List<Auction> get liveAuctions =>
      auctions.where((a) => a.status == AuctionStatus.live).toList();

  /// Get ended auctions
  List<Auction> get endedAuctions =>
      auctions.where((a) => a.status == AuctionStatus.ended).toList();

  /// Get filtered auctions based on current filter
  List<Auction> get filteredAuctions {
    if (currentFilter == null) return auctions;
    return auctions.where((a) => a.status == currentFilter).toList();
  }

  /// Total auction count
  int get totalAuctionCount => auctions.length;

  /// Active auction count
  int get activeAuctionCount => activeAuctions.length;

  /// Total vehicle count in selected auction
  int get selectedAuctionVehicleCount => auctionVehicles.length;

  @override
  List<Object?> get props => [
        status,
        categories,
        auctions,
        selectedAuction,
        auctionVehicles,
        errorMessage,
        successMessage,
        uploadProgress,
        currentFilter,
      ];

  @override
  String toString() =>
      'AuctionState(status: $status, auctions: ${auctions.length}, categories: ${categories.length})';
}
