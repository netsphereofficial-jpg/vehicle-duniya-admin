import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/property_auction.dart';
import '../bloc/property_auction_bloc.dart';
import '../bloc/property_auction_event.dart';
import '../bloc/property_auction_state.dart';
import '../widgets/property_auction_table.dart';

/// Page displaying inactive (ended) property auctions
class InactivePropertyAuctionsPage extends StatefulWidget {
  const InactivePropertyAuctionsPage({super.key});

  @override
  State<InactivePropertyAuctionsPage> createState() =>
      _InactivePropertyAuctionsPageState();
}

class _InactivePropertyAuctionsPageState
    extends State<InactivePropertyAuctionsPage> {
  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  void _loadAuctions() {
    context.read<PropertyAuctionBloc>().add(const LoadAuctionsRequested());
    // Update statuses based on current time
    context.read<PropertyAuctionBloc>().add(const UpdateStatusesRequested());
  }

  void _onSearch(String query) {
    context.read<PropertyAuctionBloc>().add(SearchAuctionsRequested(query));
  }

  void _onViewDetails(PropertyAuction auction) {
    context.go('/property-auction/detail/${auction.id}');
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
        // Filter to show only ended auctions using calculatedStatus for real-time accuracy
        final inactiveAuctions = state.filteredAuctions
            .where((a) => a.calculatedStatus == PropertyAuctionStatus.ended)
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;

            return Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, state),
                  const SizedBox(height: 24),
                  Expanded(
                    child: PropertyAuctionTable(
                      auctions: inactiveAuctions,
                      isLoading: state.isLoading,
                      filterStatus: null, // No filter for inactive page
                      onSearch: _onSearch,
                      onFilterChanged: (_) {}, // Disabled for inactive
                      onViewDetails: _onViewDetails,
                      onEdit: (_) {}, // Can't edit ended auctions
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

  Widget _buildHeader(BuildContext context, PropertyAuctionState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inactive Property Auctions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.endedCount} ended auctions',
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
          ],
        ),
      ],
    );
  }
}
