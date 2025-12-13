import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/meta_highest_bid.dart';
import '../../data/services/meta_api_service.dart';
import '../bloc/meta_highest_bid_bloc.dart';
import '../bloc/meta_highest_bid_event.dart';
import '../bloc/meta_highest_bid_state.dart';

class MetaHighestBidPage extends StatelessWidget {
  const MetaHighestBidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MetaHighestBidBloc, MetaHighestBidState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context
              .read<MetaHighestBidBloc>()
              .add(const ClearMetaHighestBidError());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 20),
                _buildStatsCards(context, state),
                const SizedBox(height: 20),
                _buildFilters(context, state),
                const SizedBox(height: 16),
                Expanded(child: _buildDataTable(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, MetaHighestBidState state) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.trending_up, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meta Highest Bid',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'View highest bids from Meta Portal for all auctions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildRefreshButton(context, state),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context, MetaHighestBidState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton.icon(
        onPressed: state.isLoading
            ? null
            : () => context
                .read<MetaHighestBidBloc>()
                .add(const RefreshMetaHighestBidsRequested()),
        icon: state.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh_rounded, size: 20),
        label: Text(state.isLoading ? 'Loading...' : 'Refresh'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, MetaHighestBidState state) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 0);

    return Row(
      children: [
        _StatCard(
          icon: Icons.gavel_rounded,
          label: 'Total Bids',
          value: state.filteredBids.length.toString(),
          color: AppColors.primary,
          isLoading: state.isLoading,
        ),
        const SizedBox(width: 16),
        _StatCard(
          icon: Icons.currency_rupee_rounded,
          label: 'Total Amount',
          value: currencyFormat.format(state.totalBidAmount),
          color: AppColors.success,
          isLoading: state.isLoading,
        ),
        const SizedBox(width: 16),
        _StatCard(
          icon: Icons.check_circle_rounded,
          label: 'API Success',
          value: '${state.successfulApiCalls}',
          color: AppColors.info,
          isLoading: state.isLoading,
        ),
        const SizedBox(width: 16),
        _StatCard(
          icon: Icons.error_outline_rounded,
          label: 'API Failed',
          value: '${state.failedApiCalls}',
          color: state.failedApiCalls > 0 ? AppColors.error : AppColors.textLight,
          isLoading: state.isLoading,
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, MetaHighestBidState state) {
    return Row(
      children: [
        // Organizer Filter Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: state.organizerFilter,
              hint: Row(
                children: [
                  Icon(Icons.filter_list_rounded,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'All Organizers',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.business_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      const Text('All Organizers'),
                    ],
                  ),
                ),
                ...MetaApiService.supportedOrganizers.map((org) {
                  return DropdownMenuItem<String>(
                    value: org,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getOrganizerColor(org),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(MetaHighestBid.getOrganizerDisplayName(org)),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                context
                    .read<MetaHighestBidBloc>()
                    .add(OrganizerFilterChanged(value));
              },
            ),
          ),
        ),
        const Spacer(),
        // Load More button (if not reached max)
        if (!state.hasReachedMax && state.bids.isNotEmpty)
          OutlinedButton.icon(
            onPressed: state.isLoadingMore
                ? null
                : () => context
                    .read<MetaHighestBidBloc>()
                    .add(const LoadMoreMetaHighestBidsRequested()),
            icon: state.isLoadingMore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded, size: 18),
            label:
                Text(state.isLoadingMore ? 'Loading...' : 'Load More Auctions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, MetaHighestBidState state) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ModernDataTable<MetaHighestBid>(
        data: state.filteredBids,
        isLoading: state.isLoading,
        emptyMessage: state.status == MetaHighestBidStatus.initial
            ? 'Click Refresh to load highest bids'
            : 'No highest bids found',
        emptyIcon: Icons.trending_up_outlined,
        searchHint: 'Search by auction, vehicle, make...',
        searchableText: (bid) =>
            '${bid.auctionName} ${bid.auctionKey} ${bid.rcNo} ${bid.contractNo} ${bid.make} ${bid.organizerDisplayName}',
        columns: [
          TableColumnDef<MetaHighestBid>(
            header: 'S.No',
            width: 70,
            align: TextAlign.center,
            cellBuilder: (item, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          TableColumnDef<MetaHighestBid>(
            header: 'Auction',
            flex: 2,
            cellBuilder: (item, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.auctionName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.auctionKey,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          TableColumnDef<MetaHighestBid>(
            header: 'Organizer',
            width: 160,
            cellBuilder: (item, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getOrganizerColor(item.organizer).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getOrganizerColor(item.organizer).withValues(alpha:0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getOrganizerColor(item.organizer),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.organizerDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getOrganizerColor(item.organizer),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TableColumnDef<MetaHighestBid>(
            header: 'Vehicle No.',
            width: 140,
            cellBuilder: (item, index) => Text(
              item.rcNo.isNotEmpty ? item.rcNo : '-',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          TableColumnDef<MetaHighestBid>(
            header: 'Make',
            width: 130,
            cellBuilder: (item, index) => Text(
              item.make.isNotEmpty ? item.make : '-',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TableColumnDef<MetaHighestBid>(
            header: 'Highest Bid',
            width: 150,
            align: TextAlign.right,
            cellBuilder: (item, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                currencyFormat.format(item.highestBidAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          TableColumnDef<MetaHighestBid>(
            header: 'Close Date',
            width: 170,
            cellBuilder: (item, index) => Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(item.auctionCloseDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getOrganizerColor(String organizer) {
    switch (organizer.toUpperCase()) {
      case 'LNT':
        return const Color(0xFF2196F3); // Blue
      case 'TCF':
        return const Color(0xFFFF9800); // Orange
      case 'MNBAF':
        return const Color(0xFF9C27B0); // Purple
      case 'HDBF':
        return const Color(0xFF4CAF50); // Green
      case 'CWCF':
        return const Color(0xFFF44336); // Red
      default:
        return AppColors.primary;
    }
  }
}

/// Stat card widget with loading animation
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.03),
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
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  isLoading
                      ? SizedBox(
                          height: 20,
                          width: 60,
                          child: LinearProgressIndicator(
                            backgroundColor: color.withValues(alpha:0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Text(
                          value,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
