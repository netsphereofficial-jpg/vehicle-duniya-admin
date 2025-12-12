import '../entities/referral_analytics.dart';
import '../entities/referral_download.dart';
import '../entities/referral_link.dart';

/// Repository interface for referral link operations
abstract class ReferralRepository {
  // ============ Links CRUD ============

  /// Watch all referral links in real-time (sorted by download count)
  Stream<List<ReferralLink>> watchReferralLinks();

  /// Get referral link by ID
  Future<ReferralLink?> getReferralLinkById(String id);

  /// Get referral link by code
  Future<ReferralLink?> getReferralLinkByCode(String code);

  /// Create a new referral link
  Future<ReferralLink> createReferralLink({
    required String name,
    required String mobile,
    required String createdBy,
  });

  /// Update referral link details
  Future<void> updateReferralLink(ReferralLink link);

  /// Toggle link active status
  Future<void> toggleLinkStatus({
    required String linkId,
    required bool isActive,
  });

  /// Delete referral link (and all associated downloads)
  Future<void> deleteReferralLink(String linkId);

  // ============ Downloads ============

  /// Watch downloads for a specific link
  Stream<List<ReferralDownload>> watchDownloadsForLink(String linkId);

  /// Get all downloads for a link
  Future<List<ReferralDownload>> getDownloadsForLink(String linkId);

  /// Check if device is already tracked for a specific link
  Future<bool> isDeviceAlreadyTracked({
    required String linkId,
    required String deviceId,
  });

  // ============ Analytics ============

  /// Get overall stats
  Future<ReferralStats> getOverallStats();

  /// Get download trend for specified days (7, 30, 90)
  Future<List<DailyDownloadData>> getDownloadTrend(int days);

  /// Get platform distribution (Android vs iOS)
  Future<PlatformDistribution> getPlatformDistribution();

  /// Get top performing links
  Future<List<TopPerformer>> getTopPerformingLinks({int limit = 5});

  // ============ Code Generation ============

  /// Generate unique referral code
  Future<String> generateUniqueCode();

  /// Check if code already exists
  Future<bool> isCodeExists(String code);
}
