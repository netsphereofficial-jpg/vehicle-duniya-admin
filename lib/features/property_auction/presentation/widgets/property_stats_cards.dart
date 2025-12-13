import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Stats cards showing property auction counts
class PropertyStatsCards extends StatelessWidget {
  final int totalAuctions;
  final int liveAuctions;
  final int upcomingAuctions;
  final int endedAuctions;
  final bool isLoading;

  const PropertyStatsCards({
    super.key,
    required this.totalAuctions,
    required this.liveAuctions,
    required this.upcomingAuctions,
    required this.endedAuctions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: totalAuctions,
            icon: Icons.gavel,
            color: AppColors.primary,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Live',
            value: liveAuctions,
            icon: Icons.play_circle_outline,
            color: AppColors.success,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Upcoming',
            value: upcomingAuctions,
            icon: Icons.schedule,
            color: AppColors.warning,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Ended',
            value: endedAuctions,
            icon: Icons.check_circle_outline,
            color: AppColors.textSecondary,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? SizedBox(
                        width: 40,
                        height: 28,
                        child: LinearProgressIndicator(
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      )
                    : Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
