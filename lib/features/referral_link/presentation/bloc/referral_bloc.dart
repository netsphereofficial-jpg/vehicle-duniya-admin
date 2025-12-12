import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/referral_repository.dart';
import 'referral_event.dart';
import 'referral_state.dart';

/// BLoC for referral link management
class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final ReferralRepository _repository;
  final FirebaseAuth _auth;
  StreamSubscription? _linksSubscription;
  StreamSubscription? _downloadsSubscription;

  ReferralBloc({
    required ReferralRepository repository,
    required FirebaseAuth auth,
  })  : _repository = repository,
        _auth = auth,
        super(const ReferralState()) {
    on<ReferralDataRequested>(_onDataRequested);
    on<ReferralLinksStreamUpdated>(_onLinksStreamUpdated);
    on<CreateReferralLinkRequested>(_onCreateLink);
    on<ToggleLinkStatusRequested>(_onToggleStatus);
    on<DeleteReferralLinkRequested>(_onDelete);
    on<LoadDownloadsRequested>(_onLoadDownloads);
    on<DownloadsStreamUpdated>(_onDownloadsStreamUpdated);
    on<CloseDownloadsView>(_onCloseDownloadsView);
    on<ChangeAnalyticsPeriodRequested>(_onChangePeriod);
    on<RefreshAnalyticsRequested>(_onRefreshAnalytics);
    on<ClearReferralMessage>(_onClearMessage);
    on<FilterByActiveStatusRequested>(_onFilterByActive);
  }

  /// Handle data requested - load links and analytics
  Future<void> _onDataRequested(
    ReferralDataRequested event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(status: ReferralLoadStatus.loading));

    try {
      // Subscribe to links stream
      await _linksSubscription?.cancel();
      _linksSubscription = _repository.watchReferralLinks().listen(
            (links) => add(ReferralLinksStreamUpdated(links)),
            onError: (error) => emit(state.copyWith(
              status: ReferralLoadStatus.error,
              errorMessage: 'Failed to load referral links: $error',
            )),
          );

      // Load analytics data
      await _loadAnalytics(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ReferralLoadStatus.error,
        errorMessage: 'Failed to load data: $e',
      ));
    }
  }

  /// Handle links stream updated
  void _onLinksStreamUpdated(
    ReferralLinksStreamUpdated event,
    Emitter<ReferralState> emit,
  ) {
    emit(state.copyWith(
      links: event.links,
      status: ReferralLoadStatus.loaded,
    ));
  }

  /// Handle create link
  Future<void> _onCreateLink(
    CreateReferralLinkRequested event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(status: ReferralLoadStatus.creating));

    try {
      final createdBy = _auth.currentUser?.uid ?? 'unknown';
      final link = await _repository.createReferralLink(
        name: event.name,
        mobile: event.mobile,
        createdBy: createdBy,
      );

      emit(state.copyWith(
        status: ReferralLoadStatus.loaded,
        successMessage: 'Referral code ${link.formattedCode} generated!',
        createdLink: link,
      ));

      // Refresh analytics
      await _loadAnalytics(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ReferralLoadStatus.loaded,
        errorMessage: 'Failed to create referral link: $e',
      ));
    }
  }

  /// Handle toggle status
  Future<void> _onToggleStatus(
    ToggleLinkStatusRequested event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(status: ReferralLoadStatus.updating));

    try {
      await _repository.toggleLinkStatus(
        linkId: event.linkId,
        isActive: event.isActive,
      );

      final statusText = event.isActive ? 'activated' : 'deactivated';
      emit(state.copyWith(
        status: ReferralLoadStatus.loaded,
        successMessage: 'Referral link $statusText',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReferralLoadStatus.loaded,
        errorMessage: 'Failed to update status: $e',
      ));
    }
  }

  /// Handle delete
  Future<void> _onDelete(
    DeleteReferralLinkRequested event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(status: ReferralLoadStatus.updating));

    try {
      await _repository.deleteReferralLink(event.linkId);

      emit(state.copyWith(
        status: ReferralLoadStatus.loaded,
        successMessage: 'Referral link deleted',
        clearSelectedLink: true,
      ));

      // Refresh analytics
      await _loadAnalytics(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ReferralLoadStatus.loaded,
        errorMessage: 'Failed to delete: $e',
      ));
    }
  }

  /// Handle load downloads for a link
  Future<void> _onLoadDownloads(
    LoadDownloadsRequested event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(
      selectedLinkId: event.linkId,
      selectedLinkDownloads: null,
    ));

    await _downloadsSubscription?.cancel();
    _downloadsSubscription =
        _repository.watchDownloadsForLink(event.linkId).listen(
              (downloads) => add(DownloadsStreamUpdated(downloads)),
              onError: (error) => emit(state.copyWith(
                errorMessage: 'Failed to load downloads: $error',
              )),
            );
  }

  /// Handle downloads stream updated
  void _onDownloadsStreamUpdated(
    DownloadsStreamUpdated event,
    Emitter<ReferralState> emit,
  ) {
    emit(state.copyWith(selectedLinkDownloads: event.downloads));
  }

  /// Handle close downloads view
  void _onCloseDownloadsView(
    CloseDownloadsView event,
    Emitter<ReferralState> emit,
  ) {
    _downloadsSubscription?.cancel();
    emit(state.copyWith(clearSelectedLink: true));
  }

  /// Handle change period
  Future<void> _onChangePeriod(
    ChangeAnalyticsPeriodRequested event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(analyticsPeriod: event.days));
    await _loadAnalytics(emit);
  }

  /// Handle refresh analytics
  Future<void> _onRefreshAnalytics(
    RefreshAnalyticsRequested event,
    Emitter<ReferralState> emit,
  ) async {
    await _loadAnalytics(emit);
  }

  /// Handle clear message
  void _onClearMessage(
    ClearReferralMessage event,
    Emitter<ReferralState> emit,
  ) {
    emit(state.copyWith(
      clearError: true,
      clearSuccess: true,
      clearCreatedLink: true,
    ));
  }

  /// Handle filter by active status
  void _onFilterByActive(
    FilterByActiveStatusRequested event,
    Emitter<ReferralState> emit,
  ) {
    if (event.isActive == null) {
      emit(state.copyWith(clearFilterByActive: true));
    } else {
      emit(state.copyWith(filterByActive: event.isActive));
    }
  }

  /// Load analytics data
  Future<void> _loadAnalytics(Emitter<ReferralState> emit) async {
    try {
      final results = await Future.wait([
        _repository.getOverallStats(),
        _repository.getDownloadTrend(state.analyticsPeriod),
        _repository.getPlatformDistribution(),
        _repository.getTopPerformingLinks(),
      ]);

      emit(state.copyWith(
        stats: results[0] as dynamic,
        downloadTrend: results[1] as dynamic,
        platformDistribution: results[2] as dynamic,
        topPerformers: results[3] as dynamic,
      ));
    } catch (e) {
      // Analytics loading failure shouldn't block main functionality
      // Just log the error
    }
  }

  @override
  Future<void> close() {
    _linksSubscription?.cancel();
    _downloadsSubscription?.cancel();
    return super.close();
  }
}
