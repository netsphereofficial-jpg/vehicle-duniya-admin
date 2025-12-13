import 'package:equatable/equatable.dart';
import '../../domain/entities/meta_highest_bid.dart';

enum MetaHighestBidStatus {
  initial,
  loading,
  loadingMore,
  loaded,
  error,
}

class MetaHighestBidState extends Equatable {
  final MetaHighestBidStatus status;
  final List<MetaHighestBid> bids;
  final String? errorMessage;
  final String searchQuery;
  final String? organizerFilter;
  final bool hasReachedMax;
  final int currentPage;
  final int totalLoaded;
  final int successfulApiCalls;
  final int failedApiCalls;
  final String? lastAuctionId; // For cursor-based pagination

  const MetaHighestBidState({
    this.status = MetaHighestBidStatus.initial,
    this.bids = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.organizerFilter,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.totalLoaded = 0,
    this.successfulApiCalls = 0,
    this.failedApiCalls = 0,
    this.lastAuctionId,
  });

  const MetaHighestBidState.initial() : this();

  MetaHighestBidState copyWith({
    MetaHighestBidStatus? status,
    List<MetaHighestBid>? bids,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? organizerFilter,
    bool clearOrganizerFilter = false,
    bool? hasReachedMax,
    int? currentPage,
    int? totalLoaded,
    int? successfulApiCalls,
    int? failedApiCalls,
    String? lastAuctionId,
    bool clearLastAuctionId = false,
  }) {
    return MetaHighestBidState(
      status: status ?? this.status,
      bids: bids ?? this.bids,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      organizerFilter:
          clearOrganizerFilter ? null : (organizerFilter ?? this.organizerFilter),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalLoaded: totalLoaded ?? this.totalLoaded,
      successfulApiCalls: successfulApiCalls ?? this.successfulApiCalls,
      failedApiCalls: failedApiCalls ?? this.failedApiCalls,
      lastAuctionId:
          clearLastAuctionId ? null : (lastAuctionId ?? this.lastAuctionId),
    );
  }

  bool get isLoading => status == MetaHighestBidStatus.loading;
  bool get isLoadingMore => status == MetaHighestBidStatus.loadingMore;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isEmpty => bids.isEmpty && status == MetaHighestBidStatus.loaded;

  /// Get filtered bids based on search query
  List<MetaHighestBid> get filteredBids {
    if (searchQuery.isEmpty) return bids;

    final query = searchQuery.toLowerCase();
    return bids
        .where((b) =>
            b.auctionName.toLowerCase().contains(query) ||
            b.auctionKey.toLowerCase().contains(query) ||
            b.rcNo.toLowerCase().contains(query) ||
            b.contractNo.toLowerCase().contains(query) ||
            b.make.toLowerCase().contains(query))
        .toList();
  }

  /// Total highest bid amount
  double get totalBidAmount =>
      filteredBids.fold(0.0, (sum, b) => sum + b.highestBidAmount);

  @override
  List<Object?> get props => [
        status,
        bids,
        errorMessage,
        searchQuery,
        organizerFilter,
        hasReachedMax,
        currentPage,
        totalLoaded,
        successfulApiCalls,
        failedApiCalls,
        lastAuctionId,
      ];
}
