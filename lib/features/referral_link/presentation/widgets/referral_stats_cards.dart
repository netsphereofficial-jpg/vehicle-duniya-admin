import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/referral_analytics.dart';

/// Stats cards widget displaying referral analytics
class ReferralStatsCards extends StatelessWidget {
  final ReferralStats? stats;
  final int totalLinks;
  final int activeLinks;
  final int totalDownloads;
  final int totalPremiumConversions;
  final VoidCallback? onRefresh;

  const ReferralStatsCards({
    super.key,
    this.stats,
    required this.totalLinks,
    required this.activeLinks,
    required this.totalDownloads,
    required this.totalPremiumConversions,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final conversionRate = totalDownloads > 0
        ? (totalPremiumConversions / totalDownloads) * 100
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive breakpoints
        int crossAxisCount;
        double childAspectRatio;

        if (width < 500) {
          crossAxisCount = 2;
          childAspectRatio = 1.3;
        } else if (width < 800) {
          crossAxisCount = 2;
          childAspectRatio = 2.2;
        } else if (width < 1100) {
          crossAxisCount = 4;
          childAspectRatio = 1.4;
        } else {
          crossAxisCount = 4;
          childAspectRatio = 1.8;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _StatCard(
              title: 'Total Codes',
              value: totalLinks.toString(),
              subtitle: '$activeLinks active',
              icon: Icons.qr_code_rounded,
              iconColor: AppColors.primary,
              trend: null,
            ),
            _StatCard(
              title: 'Downloads',
              value: _formatNumber(totalDownloads),
              subtitle: stats != null
                  ? '${stats!.todayDownloads} today'
                  : 'Loading...',
              icon: Icons.download_rounded,
              iconColor: AppColors.info,
              trend: stats?.isGrowthPositive == true
                  ? _TrendData(
                      value: stats!.formattedWeeklyGrowth,
                      isPositive: true,
                    )
                  : stats?.isGrowthPositive == false
                      ? _TrendData(
                          value: stats!.formattedWeeklyGrowth,
                          isPositive: false,
                        )
                      : null,
            ),
            _StatCard(
              title: 'Premium',
              value: _formatNumber(totalPremiumConversions),
              subtitle: 'conversions',
              icon: Icons.workspace_premium_rounded,
              iconColor: AppColors.accent,
              trend: null,
            ),
            _StatCard(
              title: 'Conversion',
              value: '${conversionRate.toStringAsFixed(1)}%',
              subtitle: 'premium rate',
              icon: Icons.trending_up_rounded,
              iconColor: AppColors.success,
              trend: null,
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final _TrendData? trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (trend != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: trend!.isPositive
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trend!.isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 10,
                          color: trend!.isPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            trend!.value,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: trend!.isPositive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Trend data for stat card
class _TrendData {
  final String value;
  final bool isPositive;

  const _TrendData({
    required this.value,
    required this.isPositive,
  });
}
