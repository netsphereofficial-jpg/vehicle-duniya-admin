import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/property_auction.dart';
import '../bloc/property_auction_bloc.dart';
import '../bloc/property_auction_event.dart';
import '../bloc/property_auction_state.dart';
import '../widgets/property_stats_cards.dart';
import '../widgets/property_auction_table.dart';
import 'edit_auction_dates_dialog.dart';

/// Page displaying active property auctions (live + upcoming)
class ActivePropertyAuctionsPage extends StatefulWidget {
  const ActivePropertyAuctionsPage({super.key});

  @override
  State<ActivePropertyAuctionsPage> createState() =>
      _ActivePropertyAuctionsPageState();
}

class _ActivePropertyAuctionsPageState
    extends State<ActivePropertyAuctionsPage> {
  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  void _loadAuctions() {
    context.read<PropertyAuctionBloc>().add(const LoadAuctionsRequested());
    // Also update statuses based on current time
    context.read<PropertyAuctionBloc>().add(const UpdateStatusesRequested());
  }

  void _onSearch(String query) {
    context.read<PropertyAuctionBloc>().add(SearchAuctionsRequested(query));
  }

  void _onFilterChanged(PropertyAuctionStatus? status) {
    context.read<PropertyAuctionBloc>().add(FilterByStatusRequested(status));
  }

  void _onViewDetails(PropertyAuction auction) {
    context.go('/property-auction/detail/${auction.id}');
  }

  void _onEditAuction(PropertyAuction auction) {
    showDialog(
      context: context,
      builder: (context) => EditAuctionDatesDialog(
        auction: auction,
        onSave: (startDate, endDate) {
          context.read<PropertyAuctionBloc>().add(UpdateAuctionDatesRequested(
                auctionId: auction.id,
                startDate: startDate,
                endDate: endDate,
              ));
        },
      ),
    );
  }

  void _onDeleteAuction(String auctionId) {
    context.read<PropertyAuctionBloc>().add(DeleteAuctionRequested(auctionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyAuctionBloc, PropertyAuctionState>(
      listener: (context, state) {
        if (state.status == PropertyAuctionBlocStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Auction deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.status == PropertyAuctionBlocStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Auction updated'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.status == PropertyAuctionBlocStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Filter to show only active auctions (live + upcoming) using calculatedStatus for real-time accuracy
        final activeAuctions = state.filteredAuctions
            .where((a) =>
                a.calculatedStatus == PropertyAuctionStatus.live ||
                a.calculatedStatus == PropertyAuctionStatus.upcoming)
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;

            return Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isMobile),
                  const SizedBox(height: 24),
                  PropertyStatsCards(
                    totalAuctions: state.liveCount + state.upcomingCount,
                    liveAuctions: state.liveCount,
                    upcomingAuctions: state.upcomingCount,
                    endedAuctions: 0, // Don't show ended in active page
                    isLoading: state.isLoading,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: PropertyAuctionTable(
                      auctions: activeAuctions,
                      isLoading: state.isLoading,
                      filterStatus: state.filterStatus,
                      onSearch: _onSearch,
                      onFilterChanged: _onFilterChanged,
                      onViewDetails: _onViewDetails,
                      onEdit: _onEditAuction,
                      onDelete: _onDeleteAuction,
                    ),
                  ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Property Auctions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Live and upcoming property auctions',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _loadAuctions,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            if (!isMobile)
              CustomButton(
                text: 'Create Auction',
                type: ButtonType.primary,
                icon: Icons.add,
                onPressed: () => context.go('/property-auction/create'),
              ),
            if (isMobile)
              IconButton(
                onPressed: () => context.go('/property-auction/create'),
                icon: const Icon(Icons.add),
                tooltip: 'Create Auction',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
