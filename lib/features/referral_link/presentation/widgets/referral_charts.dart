import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/referral_analytics.dart';

/// Charts section for referral analytics
class ReferralCharts extends StatelessWidget {
  final List<DailyDownloadData>? downloadTrend;
  final PlatformDistribution? platformDistribution;
  final List<TopPerformer>? topPerformers;
  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;

  const ReferralCharts({
    super.key,
    this.downloadTrend,
    this.platformDistribution,
    this.topPerformers,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Download Trend Line Chart
        _DownloadTrendChart(
          data: downloadTrend,
          selectedPeriod: selectedPeriod,
          onPeriodChanged: onPeriodChanged,
        ),
        const SizedBox(height: 24),
        // Platform Distribution and Top Performers
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return Column(
                children: [
                  _PlatformDistributionChart(data: platformDistribution),
                  const SizedBox(height: 24),
                  _TopPerformersChart(data: topPerformers),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _PlatformDistributionChart(data: platformDistribution),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: _TopPerformersChart(data: topPerformers),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Download trend line chart
class _DownloadTrendChart extends StatelessWidget {
  final List<DailyDownloadData>? data;
  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;

  const _DownloadTrendChart({
    this.data,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Download Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _PeriodSelector(
                selectedPeriod: selectedPeriod,
                onPeriodChanged: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: data == null || data!.isEmpty
                ? const Center(
                    child: Text(
                      'No download data available',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  )
                : LineChart(_buildLineChart()),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChart() {
    if (data == null || data!.isEmpty) {
      return LineChartData();
    }

    final maxY = data!.fold<int>(0, (max, d) => d.downloads > max ? d.downloads : max);
    final adjustedMaxY = maxY == 0 ? 10.0 : (maxY * 1.2);
    final horizontalIntervalValue = adjustedMaxY > 0 ? adjustedMaxY / 5 : 2.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: horizontalIntervalValue,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.borderLight,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _getInterval(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data!.length) return const SizedBox();
              final date = data![index].date;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  DateFormat('d MMM').format(date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: data!.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.downloads.toDouble());
          }).toList(),
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.surface,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.primaryDark,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= data!.length) return null;
              final date = data![index].date;
              return LineTooltipItem(
                '${DateFormat('MMM d').format(date)}\n${spot.y.toInt()} downloads',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  double _getInterval() {
    if (data == null || data!.isEmpty) return 1;
    if (data!.length <= 7) return 1;
    if (data!.length <= 14) return 2;
    if (data!.length <= 30) return 5;
    return 10;
  }
}

/// Period selector buttons
class _PeriodSelector extends StatelessWidget {
  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [7, 30, 90].map((period) {
          final isSelected = selectedPeriod == period;
          return GestureDetector(
            onTap: () => onPeriodChanged(period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${period}D',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Platform distribution pie chart
class _PlatformDistributionChart extends StatelessWidget {
  final PlatformDistribution? data;

  const _PlatformDistributionChart({this.data});

  @override
  Widget build(BuildContext context) {
    final hasData = data != null && data!.total > 0;

    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          const Text(
            'Platform Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: hasData
                ? Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: data!.androidCount.toDouble(),
                                title: '',
                                color: const Color(0xFF3DDC84),
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: data!.iosCount.toDouble(),
                                title: '',
                                color: AppColors.textPrimary,
                                radius: 50,
                              ),
                            ],
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendItem(
                            color: const Color(0xFF3DDC84),
                            label: 'Android',
                            value: data!.formattedAndroidPercentage,
                            count: data!.androidCount,
                          ),
                          const SizedBox(height: 16),
                          _LegendItem(
                            color: AppColors.textPrimary,
                            label: 'iOS',
                            value: data!.formattedIosPercentage,
                            count: data!.iosCount,
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'No platform data',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Legend item for pie chart
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$value ($count)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Top performers horizontal bar chart
class _TopPerformersChart extends StatelessWidget {
  final List<TopPerformer>? data;

  const _TopPerformersChart({this.data});

  @override
  Widget build(BuildContext context) {
    final hasData = data != null && data!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          const Text(
            'Top Performers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          if (!hasData)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No performer data',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
            )
          else
            Column(
              children: data!.asMap().entries.map((entry) {
                final index = entry.key;
                final performer = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Rank badge
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getRankColor(index),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name
                      Expanded(
                        child: Text(
                          performer.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Download count
                      Text(
                        '${performer.downloadCount}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getRankColor(index),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.accent;
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}
