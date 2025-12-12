import 'package:equatable/equatable.dart';

/// Overall stats for referral links
class ReferralStats extends Equatable {
  final int totalLinks;
  final int activeLinks;
  final int totalDownloads;
  final int premiumConversions;
  final int todayDownloads;
  final int weekDownloads;
  final int previousWeekDownloads;

  const ReferralStats({
    required this.totalLinks,
    required this.activeLinks,
    required this.totalDownloads,
    required this.premiumConversions,
    required this.todayDownloads,
    required this.weekDownloads,
    required this.previousWeekDownloads,
  });

  /// Calculate overall conversion rate
  double get conversionRate {
    if (totalDownloads == 0) return 0;
    return (premiumConversions / totalDownloads) * 100;
  }

  /// Get formatted conversion rate
  String get formattedConversionRate => '${conversionRate.toStringAsFixed(1)}%';

  /// Calculate week-over-week growth percentage
  double get weeklyGrowth {
    if (previousWeekDownloads == 0) {
      return weekDownloads > 0 ? 100 : 0;
    }
    return ((weekDownloads - previousWeekDownloads) / previousWeekDownloads) * 100;
  }

  /// Get formatted weekly growth
  String get formattedWeeklyGrowth {
    final growth = weeklyGrowth;
    final prefix = growth >= 0 ? '+' : '';
    return '$prefix${growth.toStringAsFixed(1)}%';
  }

  /// Check if growth is positive
  bool get isGrowthPositive => weeklyGrowth >= 0;

  /// Empty stats
  static const empty = ReferralStats(
    totalLinks: 0,
    activeLinks: 0,
    totalDownloads: 0,
    premiumConversions: 0,
    todayDownloads: 0,
    weekDownloads: 0,
    previousWeekDownloads: 0,
  );

  @override
  List<Object?> get props => [
        totalLinks,
        activeLinks,
        totalDownloads,
        premiumConversions,
        todayDownloads,
        weekDownloads,
        previousWeekDownloads,
      ];
}

/// Daily download data for charts
class DailyDownloadData extends Equatable {
  final DateTime date;
  final int downloads;
  final int androidDownloads;
  final int iosDownloads;
  final int premiumConversions;

  const DailyDownloadData({
    required this.date,
    required this.downloads,
    required this.androidDownloads,
    required this.iosDownloads,
    required this.premiumConversions,
  });

  @override
  List<Object?> get props => [
        date,
        downloads,
        androidDownloads,
        iosDownloads,
        premiumConversions,
      ];
}

/// Platform distribution for pie chart
class PlatformDistribution extends Equatable {
  final int androidCount;
  final int iosCount;

  const PlatformDistribution({
    required this.androidCount,
    required this.iosCount,
  });

  /// Get total count
  int get total => androidCount + iosCount;

  /// Get Android percentage
  double get androidPercentage {
    if (total == 0) return 0;
    return (androidCount / total) * 100;
  }

  /// Get iOS percentage
  double get iosPercentage {
    if (total == 0) return 0;
    return (iosCount / total) * 100;
  }

  /// Get formatted Android percentage
  String get formattedAndroidPercentage =>
      '${androidPercentage.toStringAsFixed(1)}%';

  /// Get formatted iOS percentage
  String get formattedIosPercentage => '${iosPercentage.toStringAsFixed(1)}%';

  /// Empty distribution
  static const empty = PlatformDistribution(
    androidCount: 0,
    iosCount: 0,
  );

  @override
  List<Object?> get props => [androidCount, iosCount];
}

/// Top performing link for bar chart
class TopPerformer extends Equatable {
  final String linkId;
  final String name;
  final int downloadCount;
  final int premiumConversions;

  const TopPerformer({
    required this.linkId,
    required this.name,
    required this.downloadCount,
    required this.premiumConversions,
  });

  /// Get conversion rate
  double get conversionRate {
    if (downloadCount == 0) return 0;
    return (premiumConversions / downloadCount) * 100;
  }

  @override
  List<Object?> get props => [linkId, name, downloadCount, premiumConversions];
}
