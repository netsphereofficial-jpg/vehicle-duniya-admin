import 'package:equatable/equatable.dart';

import '../../domain/entities/referral_analytics.dart';
import '../../domain/entities/referral_download.dart';
import '../../domain/entities/referral_link.dart';

/// Status of referral operations
enum ReferralLoadStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  error,
}

/// State for referral bloc
class ReferralState extends Equatable {
  final List<ReferralLink> links;
  final ReferralStats? stats;
  final List<DailyDownloadData>? downloadTrend;
  final PlatformDistribution? platformDistribution;
  final List<TopPerformer>? topPerformers;
  final List<ReferralDownload>? selectedLinkDownloads;
  final String? selectedLinkId;
  final int analyticsPeriod;
  final ReferralLoadStatus status;
  final String? errorMessage;
  final String? successMessage;
  final bool? filterByActive;
  final ReferralLink? createdLink;

  const ReferralState({
    this.links = const [],
    this.stats,
    this.downloadTrend,
    this.platformDistribution,
    this.topPerformers,
    this.selectedLinkDownloads,
    this.selectedLinkId,
    this.analyticsPeriod = 7,
    this.status = ReferralLoadStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.filterByActive,
    this.createdLink,
  });

  /// Get filtered links
  List<ReferralLink> get filteredLinks {
    if (filterByActive == null) return links;
    return links.where((l) => l.isActive == filterByActive).toList();
  }

  /// Get total links count
  int get totalLinks => links.length;

  /// Get active links count
  int get activeLinks => links.where((l) => l.isActive).length;

  /// Get total downloads
  int get totalDownloads => links.fold(0, (sum, l) => sum + l.downloadCount);

  /// Get total premium conversions
  int get totalPremiumConversions =>
      links.fold(0, (sum, l) => sum + l.premiumConversions);

  /// Get overall conversion rate
  double get overallConversionRate {
    if (totalDownloads == 0) return 0;
    return (totalPremiumConversions / totalDownloads) * 100;
  }

  /// Check if loading
  bool get isLoading => status == ReferralLoadStatus.loading;

  /// Check if creating
  bool get isCreating => status == ReferralLoadStatus.creating;

  /// Check if updating
  bool get isUpdating => status == ReferralLoadStatus.updating;

  /// Check if has error
  bool get hasError => errorMessage != null;

  /// Check if has success
  bool get hasSuccess => successMessage != null;

  /// Check if downloads view is open
  bool get isDownloadsViewOpen => selectedLinkId != null;

  /// Get selected link
  ReferralLink? get selectedLink {
    if (selectedLinkId == null) return null;
    try {
      return links.firstWhere((l) => l.id == selectedLinkId);
    } catch (_) {
      return null;
    }
  }

  /// Copy with method
  ReferralState copyWith({
    List<ReferralLink>? links,
    ReferralStats? stats,
    List<DailyDownloadData>? downloadTrend,
    PlatformDistribution? platformDistribution,
    List<TopPerformer>? topPerformers,
    List<ReferralDownload>? selectedLinkDownloads,
    String? selectedLinkId,
    int? analyticsPeriod,
    ReferralLoadStatus? status,
    String? errorMessage,
    String? successMessage,
    bool? filterByActive,
    ReferralLink? createdLink,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedLink = false,
    bool clearFilterByActive = false,
    bool clearCreatedLink = false,
  }) {
    return ReferralState(
      links: links ?? this.links,
      stats: stats ?? this.stats,
      downloadTrend: downloadTrend ?? this.downloadTrend,
      platformDistribution: platformDistribution ?? this.platformDistribution,
      topPerformers: topPerformers ?? this.topPerformers,
      selectedLinkDownloads: clearSelectedLink
          ? null
          : (selectedLinkDownloads ?? this.selectedLinkDownloads),
      selectedLinkId:
          clearSelectedLink ? null : (selectedLinkId ?? this.selectedLinkId),
      analyticsPeriod: analyticsPeriod ?? this.analyticsPeriod,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      filterByActive:
          clearFilterByActive ? null : (filterByActive ?? this.filterByActive),
      createdLink: clearCreatedLink ? null : (createdLink ?? this.createdLink),
    );
  }

  @override
  List<Object?> get props => [
        links,
        stats,
        downloadTrend,
        platformDistribution,
        topPerformers,
        selectedLinkDownloads,
        selectedLinkId,
        analyticsPeriod,
        status,
        errorMessage,
        successMessage,
        filterByActive,
        createdLink,
      ];
}
