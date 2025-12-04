import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/auction.dart';
import '../bloc/auction_bloc.dart';
import '../bloc/auction_event.dart';
import '../bloc/auction_state.dart';
import '../widgets/auction_list_item.dart';

/// Page displaying active auctions (upcoming + live) with pagination and search debounce
class ActiveAuctionsPage extends StatefulWidget {
  const ActiveAuctionsPage({super.key});

  @override
  State<ActiveAuctionsPage> createState() => _ActiveAuctionsPageState();
}

class _ActiveAuctionsPageState extends State<ActiveAuctionsPage> {
  String _searchQuery = '';
  AuctionStatus? _statusFilter;

  // Pagination
  static const int _pageSize = 20;
  int _currentPage = 1;

  // Search debounce
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadAuctions() {
    context.read<AuctionBloc>().add(const LoadAuctionsRequested());
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() => _isSearching = true);

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _searchQuery = value;
          _currentPage = 1; // Reset to first page on search
          _isSearching = false;
        });
      }
    });
  }

  List<Auction> _filterAuctions(List<Auction> auctions) {
    // Single-pass optimized filtering
    return auctions.where((a) {
      // Status must be active (upcoming or live)
      if (a.status != AuctionStatus.upcoming && a.status != AuctionStatus.live) {
        return false;
      }
      // Apply additional status filter
      if (_statusFilter != null && a.status != _statusFilter) {
        return false;
      }
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!a.name.toLowerCase().contains(query) &&
            !a.categoryName.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<Auction> _paginateAuctions(List<Auction> auctions) {
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= auctions.length) return [];

    final endIndex = startIndex + _pageSize;
    return auctions.sublist(
      startIndex,
      endIndex > auctions.length ? auctions.length : endIndex,
    );
  }

  int _getTotalPages(int totalItems) {
    return (totalItems / _pageSize).ceil();
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
              HapticFeedback.mediumImpact();
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
                  _buildHeader(context, isMobile),
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

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Auctions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upcoming and live vehicle auctions',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        if (!isMobile)
          CustomButton(
            text: 'Create Auction',
            type: ButtonType.primary,
            icon: Icons.add,
            onPressed: () => context.go('/vehicle-auctions/create'),
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Create Auction',
                      type: ButtonType.primary,
                      icon: Icons.add,
                      onPressed: () => context.go('/vehicle-auctions/create'),
                    ),
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
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search auctions...',
        prefixIcon: _isSearching
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: _onSearchChanged,
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
          child: Text('All Active'),
        ),
        DropdownMenuItem<AuctionStatus?>(
          value: AuctionStatus.upcoming,
          child: Text(AuctionStatus.upcoming.displayName),
        ),
        DropdownMenuItem<AuctionStatus?>(
          value: AuctionStatus.live,
          child: Text(AuctionStatus.live.displayName),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _statusFilter = value;
          _currentPage = 1; // Reset to first page on filter change
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
        backgroundColor: AppColors.primary.withAlpha(25),
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuctionState state, bool isMobile) {
    // Loading state
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: LoadingIndicator(),
        ),
      );
    }

    // Error state with retry
    if (state.hasError && state.auctions.isEmpty) {
      return _buildErrorState(context, state.errorMessage ?? 'An error occurred');
    }

    final filteredAuctions = _filterAuctions(state.auctions);
    final totalPages = _getTotalPages(filteredAuctions.length);
    final paginatedAuctions = _paginateAuctions(filteredAuctions);

    // Empty state
    if (filteredAuctions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${paginatedAuctions.length} of ${filteredAuctions.length} auctions',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              if (totalPages > 1)
                Text(
                  'Page $_currentPage of $totalPages',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
            ],
          ),
        ),

        // Content
        if (isMobile)
          _buildMobileList(context, paginatedAuctions)
        else
          _buildDesktopTable(context, paginatedAuctions),

        // Pagination controls
        if (totalPages > 1)
          _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Try Again',
              type: ButtonType.primary,
              icon: Icons.refresh,
              onPressed: _loadAuctions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final hasFilters = _searchQuery.isNotEmpty || _statusFilter != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.gavel_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No Results Found' : 'No Active Auctions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Create your first auction to get started',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            if (hasFilters)
              CustomButton(
                text: 'Clear Filters',
                type: ButtonType.outline,
                icon: Icons.clear_all,
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _statusFilter = null;
                    _currentPage = 1;
                  });
                },
              )
            else
              CustomButton(
                text: 'Create Auction',
                type: ButtonType.primary,
                icon: Icons.add,
                onPressed: () => context.go('/vehicle-auctions/create'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage = 1)
                : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'First page',
          ),
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),

          // Page numbers
          ...List.generate(
            totalPages > 5 ? 5 : totalPages,
            (index) {
              int pageNum;
              if (totalPages <= 5) {
                pageNum = index + 1;
              } else if (_currentPage <= 3) {
                pageNum = index + 1;
              } else if (_currentPage >= totalPages - 2) {
                pageNum = totalPages - 4 + index;
              } else {
                pageNum = _currentPage - 2 + index;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => _currentPage = pageNum),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _currentPage == pageNum
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: _currentPage != pageNum
                          ? Border.all(color: AppColors.border)
                          : null,
                    ),
                    child: Text(
                      '$pageNum',
                      style: TextStyle(
                        color: _currentPage == pageNum
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          IconButton(
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
          IconButton(
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage = totalPages)
                : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Last page',
          ),
        ],
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
          onEdit: () => context.go('/vehicle-auctions/${auction.id}/edit'),
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
            AppColors.primary.withAlpha(12),
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
                DataCell(_buildStatusChip(auction.status)),
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
                        onPressed: () => context.go('/vehicle-auctions/${auction.id}/edit'),
                        icon: const Icon(Icons.edit_outlined),
                        iconSize: 20,
                        tooltip: 'Edit',
                        color: AppColors.primary,
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
        color: color.withAlpha(25),
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
