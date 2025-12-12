import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/referral_analytics.dart';
import '../../domain/entities/referral_download.dart';
import '../../domain/entities/referral_link.dart';
import '../../domain/repositories/referral_repository.dart';
import '../models/referral_download_model.dart';
import '../models/referral_link_model.dart';

/// Firebase implementation of ReferralRepository
class ReferralRepositoryImpl implements ReferralRepository {
  final FirebaseFirestore _firestore;

  ReferralRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Referral links collection
  CollectionReference<Map<String, dynamic>> get _linksCollection =>
      _firestore.collection('referral_links');

  /// Referral downloads collection
  CollectionReference<Map<String, dynamic>> get _downloadsCollection =>
      _firestore.collection('referral_downloads');

  // ============ Links CRUD ============

  @override
  Stream<List<ReferralLink>> watchReferralLinks() {
    return _linksCollection
        .orderBy('downloadCount', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReferralLinkModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<ReferralLink?> getReferralLinkById(String id) async {
    final doc = await _linksCollection.doc(id).get();
    if (!doc.exists) return null;
    return ReferralLinkModel.fromFirestore(doc);
  }

  @override
  Future<ReferralLink?> getReferralLinkByCode(String code) async {
    final query = await _linksCollection.where('code', isEqualTo: code).get();
    if (query.docs.isEmpty) return null;
    return ReferralLinkModel.fromFirestore(query.docs.first);
  }

  @override
  Future<ReferralLink> createReferralLink({
    required String name,
    required String mobile,
    required String createdBy,
  }) async {
    // Generate unique code
    final code = await generateUniqueCode();
    final now = DateTime.now();

    final model = ReferralLinkModel(
      id: '', // Will be set after creation
      name: name,
      mobile: mobile,
      code: code,
      downloadCount: 0,
      premiumConversions: 0,
      isActive: true,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _linksCollection.add(model.toFirestore());
    return model.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateReferralLink(ReferralLink link) async {
    final model = ReferralLinkModel.fromEntity(link);
    await _linksCollection.doc(link.id).update(model.toFirestoreUpdate());
  }

  @override
  Future<void> toggleLinkStatus({
    required String linkId,
    required bool isActive,
  }) async {
    await _linksCollection.doc(linkId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteReferralLink(String linkId) async {
    // Delete all associated downloads first
    final downloads = await _downloadsCollection
        .where('referralLinkId', isEqualTo: linkId)
        .get();

    final batch = _firestore.batch();
    for (final doc in downloads.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_linksCollection.doc(linkId));
    await batch.commit();
  }

  // ============ Downloads ============

  @override
  Stream<List<ReferralDownload>> watchDownloadsForLink(String linkId) {
    return _downloadsCollection
        .where('referralLinkId', isEqualTo: linkId)
        .orderBy('downloadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReferralDownloadModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<List<ReferralDownload>> getDownloadsForLink(String linkId) async {
    final query = await _downloadsCollection
        .where('referralLinkId', isEqualTo: linkId)
        .orderBy('downloadedAt', descending: true)
        .get();
    return query.docs
        .map((doc) => ReferralDownloadModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<bool> isDeviceAlreadyTracked({
    required String linkId,
    required String deviceId,
  }) async {
    final query = await _downloadsCollection
        .where('referralLinkId', isEqualTo: linkId)
        .where('deviceId', isEqualTo: deviceId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // ============ Analytics ============

  @override
  Future<ReferralStats> getOverallStats() async {
    final linksSnapshot = await _linksCollection.get();
    final links = linksSnapshot.docs
        .map((doc) => ReferralLinkModel.fromFirestore(doc))
        .toList();

    // Calculate basic stats from links
    int totalLinks = links.length;
    int activeLinks = links.where((l) => l.isActive).length;
    int totalDownloads = links.fold(0, (acc, l) => acc + l.downloadCount);
    int premiumConversions =
        links.fold(0, (acc, l) => acc + l.premiumConversions);

    // Get downloads for time-based stats
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));
    final previousWeekStart = weekStart.subtract(const Duration(days: 7));

    final downloadsSnapshot = await _downloadsCollection
        .where('downloadedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(previousWeekStart))
        .get();

    int todayDownloads = 0;
    int weekDownloads = 0;
    int previousWeekDownloads = 0;

    for (final doc in downloadsSnapshot.docs) {
      final data = doc.data();
      final downloadedAt =
          (data['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (downloadedAt.isAfter(todayStart)) {
        todayDownloads++;
      }
      if (downloadedAt.isAfter(weekStart)) {
        weekDownloads++;
      } else if (downloadedAt.isAfter(previousWeekStart)) {
        previousWeekDownloads++;
      }
    }

    return ReferralStats(
      totalLinks: totalLinks,
      activeLinks: activeLinks,
      totalDownloads: totalDownloads,
      premiumConversions: premiumConversions,
      todayDownloads: todayDownloads,
      weekDownloads: weekDownloads,
      previousWeekDownloads: previousWeekDownloads,
    );
  }

  @override
  Future<List<DailyDownloadData>> getDownloadTrend(int days) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final snapshot = await _downloadsCollection
        .where('downloadedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('downloadedAt')
        .get();

    // Group downloads by date
    final downloadsByDate = <DateTime, List<Map<String, dynamic>>>{};
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      downloadsByDate[DateTime(date.year, date.month, date.day)] = [];
    }

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final downloadedAt =
          (data['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dateKey =
          DateTime(downloadedAt.year, downloadedAt.month, downloadedAt.day);
      downloadsByDate[dateKey]?.add(data);
    }

    // Convert to DailyDownloadData
    return downloadsByDate.entries.map((entry) {
      final downloads = entry.value;
      int androidDownloads = 0;
      int iosDownloads = 0;
      int premiumCount = 0;

      for (final download in downloads) {
        final platform = download['platform'] as String?;
        if (platform?.toLowerCase() == 'android') {
          androidDownloads++;
        } else if (platform?.toLowerCase() == 'ios') {
          iosDownloads++;
        }
        if (download['isPremium'] == true) {
          premiumCount++;
        }
      }

      return DailyDownloadData(
        date: entry.key,
        downloads: downloads.length,
        androidDownloads: androidDownloads,
        iosDownloads: iosDownloads,
        premiumConversions: premiumCount,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<PlatformDistribution> getPlatformDistribution() async {
    final snapshot = await _downloadsCollection.get();

    int androidCount = 0;
    int iosCount = 0;

    for (final doc in snapshot.docs) {
      final platform = doc.data()['platform'] as String?;
      if (platform?.toLowerCase() == 'android') {
        androidCount++;
      } else if (platform?.toLowerCase() == 'ios') {
        iosCount++;
      }
    }

    return PlatformDistribution(
      androidCount: androidCount,
      iosCount: iosCount,
    );
  }

  @override
  Future<List<TopPerformer>> getTopPerformingLinks({int limit = 5}) async {
    final snapshot = await _linksCollection
        .orderBy('downloadCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TopPerformer(
        linkId: doc.id,
        name: data['name'] ?? '',
        downloadCount: data['downloadCount'] ?? 0,
        premiumConversions: data['premiumConversions'] ?? 0,
      );
    }).toList();
  }

  // ============ Code Generation ============

  @override
  Future<String> generateUniqueCode() async {
    String code;
    bool exists;

    do {
      code = ReferralLinkModel.generateCode();
      exists = await isCodeExists(code);
    } while (exists);

    return code;
  }

  @override
  Future<bool> isCodeExists(String code) async {
    final query = await _linksCollection.where('code', isEqualTo: code).get();
    return query.docs.isNotEmpty;
  }
}
