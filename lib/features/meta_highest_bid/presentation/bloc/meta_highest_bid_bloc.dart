import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entities/meta_highest_bid.dart';
import '../../data/services/meta_api_service.dart';
import 'meta_highest_bid_event.dart';
import 'meta_highest_bid_state.dart';

class MetaHighestBidBloc
    extends Bloc<MetaHighestBidEvent, MetaHighestBidState> {
  final FirebaseFirestore _firestore;
  final MetaApiService _metaApiService;

  // Batch size for parallel API calls
  static const int _apiBatchSize = 10;
  // Page size for Firestore pagination
  static const int _firestorePageSize = 20;

  MetaHighestBidBloc({
    FirebaseFirestore? firestore,
    MetaApiService? metaApiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _metaApiService = metaApiService ?? MetaApiService(),
        super(const MetaHighestBidState.initial()) {
    on<LoadMetaHighestBidsRequested>(
      _onLoadMetaHighestBids,
      transformer: restartable(),
    );
    on<LoadMoreMetaHighestBidsRequested>(
      _onLoadMoreMetaHighestBids,
      transformer: droppable(),
    );
    on<RefreshMetaHighestBidsRequested>(_onRefreshMetaHighestBids);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<OrganizerFilterChanged>(_onOrganizerFilterChanged);
    on<ClearMetaHighestBidError>(_onClearError);
    on<CancelMetaHighestBidRequests>(_onCancelRequests);
  }

  /// Debounce transformer for search
  EventTransformer<E> debounce<E>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  /// Restartable transformer - cancels previous if new event comes
  EventTransformer<E> restartable<E>() {
    return (events, mapper) => events.switchMap(mapper);
  }

  /// Droppable transformer - drops new if previous is processing
  EventTransformer<E> droppable<E>() {
    return (events, mapper) => events.exhaustMap(mapper);
  }

  Future<void> _onLoadMetaHighestBids(
    LoadMetaHighestBidsRequested event,
    Emitter<MetaHighestBidState> emit,
  ) async {
    emit(state.copyWith(
      status: MetaHighestBidStatus.loading,
      bids: [],
      hasReachedMax: false,
      currentPage: 0,
      totalLoaded: 0,
      successfulApiCalls: 0,
      failedApiCalls: 0,
      clearLastAuctionId: true,
      organizerFilter: event.organizerFilter,
    ));

    try {
      final result = await _fetchBidsPage(
        organizerFilter: event.organizerFilter,
        lastAuctionId: null,
        emit: emit,
      );

      emit(state.copyWith(
        status: MetaHighestBidStatus.loaded,
        bids: result.bids,
        hasReachedMax: result.hasReachedMax,
        lastAuctionId: result.lastAuctionId,
        currentPage: 1,
        totalLoaded: result.bids.length,
        successfulApiCalls: result.successCount,
        failedApiCalls: result.failCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MetaHighestBidStatus.error,
        errorMessage: 'Failed to load bids: $e',
      ));
    }
  }

  Future<void> _onLoadMoreMetaHighestBids(
    LoadMoreMetaHighestBidsRequested event,
    Emitter<MetaHighestBidState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: MetaHighestBidStatus.loadingMore));

    try {
      final result = await _fetchBidsPage(
        organizerFilter: state.organizerFilter,
        lastAuctionId: state.lastAuctionId,
        emit: emit,
      );

      final allBids = [...state.bids, ...result.bids];

      emit(state.copyWith(
        status: MetaHighestBidStatus.loaded,
        bids: allBids,
        hasReachedMax: result.hasReachedMax,
        lastAuctionId: result.lastAuctionId,
        currentPage: state.currentPage + 1,
        totalLoaded: allBids.length,
        successfulApiCalls: state.successfulApiCalls + result.successCount,
        failedApiCalls: state.failedApiCalls + result.failCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MetaHighestBidStatus.error,
        errorMessage: 'Failed to load more: $e',
      ));
    }
  }

  Future<void> _onRefreshMetaHighestBids(
    RefreshMetaHighestBidsRequested event,
    Emitter<MetaHighestBidState> emit,
  ) async {
    add(LoadMetaHighestBidsRequested(
      organizerFilter: state.organizerFilter,
    ));
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<MetaHighestBidState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onOrganizerFilterChanged(
    OrganizerFilterChanged event,
    Emitter<MetaHighestBidState> emit,
  ) {
    // Reload with new filter
    add(LoadMetaHighestBidsRequested(organizerFilter: event.organizer));
  }

  void _onClearError(
    ClearMetaHighestBidError event,
    Emitter<MetaHighestBidState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  void _onCancelRequests(
    CancelMetaHighestBidRequests event,
    Emitter<MetaHighestBidState> emit,
  ) {
    // The restartable transformer handles cancellation
    emit(state.copyWith(status: MetaHighestBidStatus.loaded));
  }

  /// Fetch a page of bids with optimized parallel API calls
  Future<_FetchResult> _fetchBidsPage({
    String? organizerFilter,
    String? lastAuctionId,
    required Emitter<MetaHighestBidState> emit,
  }) async {
    final List<MetaHighestBid> bids = [];
    int successCount = 0;
    int failCount = 0;

    // Get organizers to query (stored as lowercase in Firestore)
    final organizers = organizerFilter != null
        ? [organizerFilter.toLowerCase()]
        : MetaApiService.supportedOrganizers
            .map((o) => o.toLowerCase())
            .toList();

    developer.log('[MetaHighestBid] Querying auctions with eventTypes: $organizers');

    // Build Firestore query with cursor pagination
    Query query = _firestore
        .collection('auctions')
        .where('eventType', whereIn: organizers)
        .orderBy(FieldPath.documentId)
        .limit(_firestorePageSize);

    if (lastAuctionId != null) {
      final lastDoc =
          await _firestore.collection('auctions').doc(lastAuctionId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final auctionsSnapshot = await query.get();
    developer.log('[MetaHighestBid] Found ${auctionsSnapshot.docs.length} auctions');

    if (auctionsSnapshot.docs.isEmpty) {
      developer.log('[MetaHighestBid] No auctions found with Meta event types');
      return _FetchResult(
        bids: [],
        hasReachedMax: true,
        lastAuctionId: lastAuctionId,
        successCount: 0,
        failCount: 0,
      );
    }

    // Collect all vehicle requests
    final List<_VehicleRequest> vehicleRequests = [];

    for (final auctionDoc in auctionsSnapshot.docs) {
      final auctionData = auctionDoc.data() as Map<String, dynamic>;
      final auctionId = auctionDoc.id;
      final eventType =
          (auctionData['eventType'] ?? '').toString().toUpperCase();
      final eventId = auctionData['eventId']?.toString() ?? '';
      final auctionName = auctionData['name']?.toString() ?? 'Unknown';

      developer.log('[MetaHighestBid] Processing auction: $auctionName (eventType: $eventType, eventId: $eventId)');

      if (eventId.isEmpty) {
        developer.log('[MetaHighestBid] Skipping $auctionName - no eventId');
        continue;
      }
      if (!MetaApiService.isMetaOrganizer(eventType)) {
        developer.log('[MetaHighestBid] Skipping $auctionName - eventType $eventType not a Meta organizer');
        continue;
      }

      // Get vehicles for this auction
      final vehiclesSnapshot = await _firestore
          .collection('vehicles')
          .where('auctionId', isEqualTo: auctionId)
          .get();

      developer.log('[MetaHighestBid] Found ${vehiclesSnapshot.docs.length} vehicles for auction $auctionName');

      for (final vehicleDoc in vehiclesSnapshot.docs) {
        final vehicleData = vehicleDoc.data();
        final contractNo = vehicleData['contractNo']?.toString() ?? '';

        if (contractNo.isEmpty) {
          developer.log('[MetaHighestBid] Skipping vehicle ${vehicleDoc.id} - no contractNo');
          continue;
        }

        vehicleRequests.add(_VehicleRequest(
          auctionId: auctionId,
          auctionName: auctionData['name']?.toString() ?? 'Unknown Auction',
          auctionKey: 'AUC${auctionId.substring(0, 8).toUpperCase()}',
          organizer: eventType,
          endDate: (auctionData['endDate'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          vehicleId: vehicleDoc.id,
          rcNo: vehicleData['rcNo']?.toString() ?? '',
          contractNo: contractNo,
          make: vehicleData['make']?.toString() ?? '',
          eventId: eventId,
        ));
      }
    }

    developer.log('[MetaHighestBid] Total vehicles to fetch bids for: ${vehicleRequests.length}');

    // Process API calls in parallel batches
    for (var i = 0; i < vehicleRequests.length; i += _apiBatchSize) {
      final batch = vehicleRequests.skip(i).take(_apiBatchSize).toList();

      final results = await Future.wait(
        batch.map((req) => _fetchSingleBid(req)),
        eagerError: false,
      );

      for (final result in results) {
        if (result != null) {
          bids.add(result);
          successCount++;
        } else {
          failCount++;
        }
      }

      // Small delay between batches to avoid rate limiting
      if (i + _apiBatchSize < vehicleRequests.length) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    developer.log('[MetaHighestBid] API calls completed - success: $successCount, failed: $failCount, bids with amount: ${bids.length}');

    // Sort by highest bid amount descending
    bids.sort((a, b) => b.highestBidAmount.compareTo(a.highestBidAmount));

    final newLastAuctionId = auctionsSnapshot.docs.isNotEmpty
        ? auctionsSnapshot.docs.last.id
        : lastAuctionId;

    return _FetchResult(
      bids: bids,
      hasReachedMax: auctionsSnapshot.docs.length < _firestorePageSize,
      lastAuctionId: newLastAuctionId,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Fetch a single bid from Meta API
  Future<MetaHighestBid?> _fetchSingleBid(_VehicleRequest req) async {
    try {
      final result = await _metaApiService.getHighestBid(
        organizer: req.organizer,
        eventId: req.eventId,
        contractNo: req.contractNo,
      );

      if (result.success && result.amount != null && result.amount! > 0) {
        return MetaHighestBid(
          auctionId: req.auctionId,
          auctionName: req.auctionName,
          auctionKey: req.auctionKey,
          organizer: req.organizer,
          organizerDisplayName:
              MetaHighestBid.getOrganizerDisplayName(req.organizer),
          vehicleId: req.vehicleId,
          rcNo: req.rcNo,
          contractNo: req.contractNo,
          make: req.make,
          highestBidAmount: result.amount!,
          auctionCloseDate: req.endDate,
          eventId: req.eventId,
        );
      }
    } catch (_) {
      // Silently fail individual requests
    }
    return null;
  }
}

/// Internal class to hold fetch result
class _FetchResult {
  final List<MetaHighestBid> bids;
  final bool hasReachedMax;
  final String? lastAuctionId;
  final int successCount;
  final int failCount;

  _FetchResult({
    required this.bids,
    required this.hasReachedMax,
    this.lastAuctionId,
    required this.successCount,
    required this.failCount,
  });
}

/// Internal class to hold vehicle request data
class _VehicleRequest {
  final String auctionId;
  final String auctionName;
  final String auctionKey;
  final String organizer;
  final DateTime endDate;
  final String vehicleId;
  final String rcNo;
  final String contractNo;
  final String make;
  final String eventId;

  _VehicleRequest({
    required this.auctionId,
    required this.auctionName,
    required this.auctionKey,
    required this.organizer,
    required this.endDate,
    required this.vehicleId,
    required this.rcNo,
    required this.contractNo,
    required this.make,
    required this.eventId,
  });
}
