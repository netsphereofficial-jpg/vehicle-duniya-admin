import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/stats_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final padding = isMobile ? 16.0 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Responsive
                _buildHeader(context, isMobile),
                SizedBox(height: isMobile ? 20 : 32),

                // Stats Cards - Responsive Grid
                _buildStatsGrid(constraints.maxWidth),
                SizedBox(height: isMobile ? 20 : 32),

                // Quick Actions & Recent Activity - Responsive
                _buildMainContent(context, constraints.maxWidth),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    if (isMobile) {
      // Stack layout for mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppStrings.dashboard,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back! Here\'s an overview.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      );
    }

    // Desktop layout
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.dashboard,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back! Here\'s an overview of your platform.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatsGrid(double maxWidth) {
    // Determine grid columns based on width
    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    if (maxWidth > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 1.8;
      spacing = 24;
    } else if (maxWidth > 900) {
      crossAxisCount = 4;
      childAspectRatio = 1.5;
      spacing = 16;
    } else if (maxWidth > 600) {
      crossAxisCount = 2;
      childAspectRatio = 2.0;
      spacing = 16;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.4;
      spacing = 12;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: const [
        StatsCard(
          title: AppStrings.totalVehicles,
          value: '156',
          icon: Icons.directions_car,
          iconColor: AppColors.primary,
          trend: '+12%',
          trendUp: true,
        ),
        StatsCard(
          title: AppStrings.totalProperties,
          value: '48',
          icon: Icons.home_work,
          iconColor: AppColors.accent,
          trend: '+8%',
          trendUp: true,
        ),
        StatsCard(
          title: AppStrings.totalUsers,
          value: '2,450',
          icon: Icons.people,
          iconColor: AppColors.success,
          trend: '+24%',
          trendUp: true,
        ),
        StatsCard(
          title: AppStrings.activeAuctions,
          value: '23',
          icon: Icons.gavel,
          iconColor: AppColors.warning,
          trend: '-3%',
          trendUp: false,
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, double maxWidth) {
    if (maxWidth > 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildQuickActions(context),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: _buildRecentActivity(context, maxWidth),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildQuickActions(context),
        const SizedBox(height: 16),
        _buildRecentActivity(context, maxWidth),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.quickActions,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: AppStrings.addVehicle,
              color: AppColors.primary,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              context,
              icon: Icons.add_home_outlined,
              label: AppStrings.addProperty,
              color: AppColors.accent,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              context,
              icon: Icons.add_business_outlined,
              label: AppStrings.addListing,
              color: AppColors.success,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, double maxWidth) {
    final isMobile = maxWidth < 600;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.recentActivity,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              icon: Icons.gavel,
              iconColor: AppColors.success,
              title: 'New bid placed',
              subtitle: 'Honda City 2020 - ₹8,50,000',
              time: '2m ago',
              isMobile: isMobile,
            ),
            const Divider(height: 20),
            _buildActivityItem(
              context,
              icon: Icons.directions_car,
              iconColor: AppColors.primary,
              title: 'Vehicle added',
              subtitle: 'Toyota Fortuner 2022',
              time: '15m ago',
              isMobile: isMobile,
            ),
            const Divider(height: 20),
            _buildActivityItem(
              context,
              icon: Icons.person_add,
              iconColor: AppColors.accent,
              title: 'New user registered',
              subtitle: 'john.doe@example.com',
              time: '1h ago',
              isMobile: isMobile,
            ),
            const Divider(height: 20),
            _buildActivityItem(
              context,
              icon: Icons.home_work,
              iconColor: AppColors.warning,
              title: 'Auction ended',
              subtitle: '2 BHK Flat, Mumbai',
              time: '3h ago',
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isMobile,
  }) {
    if (isMobile) {
      // Stack layout for mobile
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textLight,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Desktop layout
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textLight,
              ),
        ),
      ],
    );
  }
}
