import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/auction.dart';
import '../bloc/auction_bloc.dart';
import '../bloc/auction_event.dart';
import '../bloc/auction_state.dart';
import '../widgets/auction_list_item.dart';

/// Page displaying inactive auctions (ended + cancelled)
class InactiveAuctionsPage extends StatefulWidget {
  const InactiveAuctionsPage({super.key});

  @override
  State<InactiveAuctionsPage> createState() => _InactiveAuctionsPageState();
}

class _InactiveAuctionsPageState extends State<InactiveAuctionsPage> {
  String _searchQuery = '';
  AuctionStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadAuctions();
    // Trigger status sync on page load for instant updates
    context.read<AuctionBloc>().add(const SyncAuctionStatusesRequested());
  }

  void _loadAuctions() {
    context.read<AuctionBloc>().add(const LoadAuctionsRequested());
  }

  List<Auction> _filterAuctions(List<Auction> auctions) {
    // Use effectiveStatus for real-time accuracy
    var filtered = auctions.where((a) {
      final status = a.effectiveStatus;
      return status == AuctionStatus.ended || status == AuctionStatus.cancelled;
    }).toList();

    // Apply status filter using effectiveStatus
    if (_statusFilter != null) {
      filtered = filtered.where((a) => a.effectiveStatus == _statusFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((a) =>
          a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.categoryName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  void _showDeleteConfirmation(BuildContext context, Auction auction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Auction'),
        content: Text('Are you sure you want to delete "${auction.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuctionBloc>().add(DeleteAuctionRequested(auction.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuctionBloc, AuctionState>(
      listener: (context, state) {
        if (state.status == AuctionStateStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Auction deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.status == AuctionStateStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildFiltersBar(context, isMobile),
                  const SizedBox(height: 16),
                  _buildContent(context, state, isMobile),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inactive Auctions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ended and cancelled vehicle auctions',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFiltersBar(BuildContext context, bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isMobile
            ? Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatusFilter()),
                      const SizedBox(width: 12),
                      _buildRefreshButton(),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 2, child: _buildSearchField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatusFilter()),
                  const SizedBox(width: 16),
                  _buildRefreshButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search auctions...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<AuctionStatus?>(
      initialValue: _statusFilter,
      decoration: InputDecoration(
        hintText: 'Filter by status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        const DropdownMenuItem<AuctionStatus?>(
          value: null,
          child: Text('All Inactive'),
        ),
        DropdownMenuItem<AuctionStatus?>(
          value: AuctionStatus.ended,
          child: Text(AuctionStatus.ended.displayName),
        ),
        DropdownMenuItem<AuctionStatus?>(
          value: AuctionStatus.cancelled,
          child: Text(AuctionStatus.cancelled.displayName),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _statusFilter = value;
        });
      },
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: _loadAuctions,
      icon: const Icon(Icons.refresh),
      tooltip: 'Refresh',
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuctionState state, bool isMobile) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: LoadingIndicator(),
        ),
      );
    }

    final filteredAuctions = _filterAuctions(state.auctions);

    if (filteredAuctions.isEmpty) {
      return _buildEmptyState(context);
    }

    if (isMobile) {
      return _buildMobileList(context, filteredAuctions);
    }

    return _buildDesktopTable(context, filteredAuctions);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Inactive Auctions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ended and cancelled auctions will appear here',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Auction> auctions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        final auction = auctions[index];
        return AuctionListItem(
          auction: auction,
          onTap: () => context.go('/vehicle-auctions/${auction.id}'),
          onDelete: () => _showDeleteConfirmation(context, auction),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Auction> auctions) {
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            AppColors.primary.withValues(alpha: 0.05),
          ),
          columns: const [
            DataColumn(label: Text('Auction Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Start Date')),
            DataColumn(label: Text('End Date')),
            DataColumn(label: Text('Mode')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Vehicles')),
            DataColumn(label: Text('Actions')),
          ],
          rows: auctions.map((auction) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    auction.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(auction.categoryName.isNotEmpty
                    ? auction.categoryName
                    : 'Uncategorized')),
                DataCell(Text(dateFormatter.format(auction.startDate))),
                DataCell(Text(dateFormatter.format(auction.endDate))),
                DataCell(Text(auction.mode.displayName)),
                DataCell(_buildStatusChip(auction.effectiveStatus)),
                DataCell(Text('${auction.vehicleCount}')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/vehicle-auctions/${auction.id}'),
                        icon: const Icon(Icons.visibility_outlined),
                        iconSize: 20,
                        tooltip: 'View',
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context, auction),
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 20,
                        tooltip: 'Delete',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(AuctionStatus status) {
    Color color;
    switch (status) {
      case AuctionStatus.upcoming:
        color = AppColors.warning;
        break;
      case AuctionStatus.live:
        color = AppColors.success;
        break;
      case AuctionStatus.ended:
        color = AppColors.textSecondary;
        break;
      case AuctionStatus.cancelled:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
