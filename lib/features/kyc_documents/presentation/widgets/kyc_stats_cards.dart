import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Stats cards for KYC documents overview
class KycStatsCards extends StatelessWidget {
  final int totalDocuments;
  final int documentsWithAadhaar;
  final int documentsWithPan;
  final int documentsWithBoth;
  final bool isLoading;

  const KycStatsCards({
    super.key,
    required this.totalDocuments,
    required this.documentsWithAadhaar,
    required this.documentsWithPan,
    required this.documentsWithBoth,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isMedium = constraints.maxWidth < 900;

        if (isCompact) {
          // 2x2 grid for compact screens
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Documents',
                      value: totalDocuments,
                      icon: Icons.folder_outlined,
                      color: AppColors.primary,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'With Aadhaar',
                      value: documentsWithAadhaar,
                      icon: Icons.credit_card_outlined,
                      color: AppColors.info,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'With PAN',
                      value: documentsWithPan,
                      icon: Icons.badge_outlined,
                      color: AppColors.accent,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Complete KYC',
                      value: documentsWithBoth,
                      icon: Icons.verified_outlined,
                      color: AppColors.success,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Single row for larger screens
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Documents',
                value: totalDocuments,
                icon: Icons.folder_outlined,
                color: AppColors.primary,
                isLoading: isLoading,
                isCompact: isMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'With Aadhaar',
                value: documentsWithAadhaar,
                icon: Icons.credit_card_outlined,
                color: AppColors.info,
                isLoading: isLoading,
                isCompact: isMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'With PAN',
                value: documentsWithPan,
                icon: Icons.badge_outlined,
                color: AppColors.accent,
                isLoading: isLoading,
                isCompact: isMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Complete KYC',
                value: documentsWithBoth,
                icon: Icons.verified_outlined,
                color: AppColors.success,
                isLoading: isLoading,
                isCompact: isMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool isCompact;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isCompact ? 22 : 26,
            ),
          ),
          SizedBox(width: isCompact ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? SizedBox(
                        height: isCompact ? 24 : 32,
                        width: 60,
                        child: LinearProgressIndicator(
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(color),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: isCompact ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
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
