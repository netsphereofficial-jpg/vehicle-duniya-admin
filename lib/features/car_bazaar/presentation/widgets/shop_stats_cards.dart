import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Stats cards showing total, active, and inactive shops
class ShopStatsCards extends StatelessWidget {
  final int totalShops;
  final int activeShops;
  final int inactiveShops;
  final bool isLoading;

  const ShopStatsCards({
    super.key,
    required this.totalShops,
    required this.activeShops,
    required this.inactiveShops,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 500;

        if (isCompact) {
          return Column(
            children: [
              _buildCard(
                icon: Icons.storefront_outlined,
                iconColor: AppColors.primary,
                label: 'Total Shops',
                value: totalShops.toString(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      label: 'Active',
                      value: activeShops.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      icon: Icons.cancel_outlined,
                      iconColor: AppColors.textSecondary,
                      label: 'Inactive',
                      value: inactiveShops.toString(),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildCard(
                icon: Icons.storefront_outlined,
                iconColor: AppColors.primary,
                label: 'Total Shops',
                value: totalShops.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCard(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                label: 'Active',
                value: activeShops.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCard(
                icon: Icons.cancel_outlined,
                iconColor: AppColors.textSecondary,
                label: 'Inactive',
                value: inactiveShops.toString(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
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
                    ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
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
