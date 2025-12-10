import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/auction.dart';
import '../../domain/entities/vehicle_item.dart';
import '../bloc/auction_bloc.dart';
import '../bloc/auction_event.dart';
import '../bloc/auction_state.dart';

/// Auction Detail Page showing auction info and vehicle list
class AuctionDetailPage extends StatefulWidget {
  final String auctionId;

  const AuctionDetailPage({super.key, required this.auctionId});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAuctionData();
  }

  void _loadAuctionData() {
    context.read<AuctionBloc>()
      ..add(LoadAuctionDetailRequested(widget.auctionId))
      ..add(LoadAuctionVehiclesRequested(widget.auctionId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuctionBloc, AuctionState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final auction = state.selectedAuction;
        final isLoading = state.isLoading;

        return Scaffold(
          body: isLoading && auction == null
              ? const Center(child: CircularProgressIndicator())
              : auction == null
                  ? _buildNotFound()
                  : _buildContent(context, auction, state),
        );
      },
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Auction not found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Go Back',
            type: ButtonType.outline,
            onPressed: () => context.go('/vehicle-auctions/active'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Auction auction, AuctionState state) {
    return Column(
      children: [
        _buildHeader(context, auction),
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.info_outline),
              text: 'Auction Details',
            ),
            Tab(
              icon: const Icon(Icons.directions_car),
              text: 'Vehicles (${state.auctionVehicles.length})',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(auction),
              _buildVehiclesTab(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Auction auction) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/vehicle-auctions/active'),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusBadge(auction.status),
                    const SizedBox(width: 12),
                    Text(
                      auction.categoryName.isNotEmpty
                          ? auction.categoryName
                          : 'Category: ${auction.category}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${auction.vehicleCount} vehicles',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CustomButton(
            text: 'Edit',
            type: ButtonType.outline,
            icon: Icons.edit,
            onPressed: () => context.go('/vehicle-auctions/${auction.id}/edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AuctionStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case AuctionStatus.upcoming:
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      case AuctionStatus.live:
        color = Colors.green;
        icon = Icons.play_circle;
        break;
      case AuctionStatus.ended:
        color = Colors.grey;
        icon = Icons.stop_circle;
        break;
      case AuctionStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Auction auction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Auction Information', [
            _InfoRow('Name', auction.name),
            _InfoRow('Category', auction.categoryName.isNotEmpty
                ? auction.categoryName
                : auction.category),
            _InfoRow('Mode', auction.mode.displayName),
            _InfoRow('Event Type', auction.eventType.displayName),
            if (auction.eventId != null && auction.eventId!.isNotEmpty)
              _InfoRow('Event ID', auction.eventId!),
          ]),
          const SizedBox(height: 24),
          _buildInfoCard('Schedule', [
            _InfoRow('Start Date', _dateFormat.format(auction.startDate)),
            _InfoRow('End Date', _dateFormat.format(auction.endDate)),
            _InfoRow('Duration', _formatDuration(auction.duration)),
            _InfoRow('Status', auction.status.displayName),
          ]),
          const SizedBox(height: 24),
          _buildInfoCard('Configuration', [
            _InfoRow('Check Base Price', auction.checkBasePrice ? 'Yes' : 'No'),
            _InfoRow('Zip Type', auction.zipType.displayName),
            _InfoRow('Total Vehicles', auction.vehicleCount.toString()),
          ]),
          const SizedBox(height: 24),
          _buildInfoCard('Files', [
            _InfoRow(
              'Bid Report',
              auction.bidReportUrl != null && auction.bidReportUrl!.isNotEmpty
                  ? 'Uploaded'
                  : 'Not uploaded',
            ),
            _InfoRow(
              'Images Zip',
              auction.imagesZipUrl != null && auction.imagesZipUrl!.isNotEmpty
                  ? 'Uploaded'
                  : 'Not uploaded',
            ),
          ]),
          const SizedBox(height: 24),
          _buildInfoCard('Metadata', [
            _InfoRow('Created By', auction.createdBy),
            _InfoRow('Created At', _dateFormat.format(auction.createdAt)),
            _InfoRow('Updated At', _dateFormat.format(auction.updatedAt)),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<_InfoRow> rows) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...rows.map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''}, $hours hour${hours > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}, $minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  Widget _buildVehiclesTab(AuctionState state) {
    final vehicles = state.auctionVehicles;
    final isLoading = state.isLoading;

    return ModernDataTable<VehicleItem>(
      data: vehicles,
      isLoading: isLoading,
      emptyMessage: 'No vehicles in this auction',
      emptyIcon: Icons.directions_car_outlined,
      searchHint: 'Search vehicles...',
      searchableText: (vehicle) =>
          '${vehicle.contractNo} ${vehicle.rcNo} ${vehicle.make} ${vehicle.model} ${vehicle.yardName} ${vehicle.yardCity}',
      columns: [
        TableColumnDef<VehicleItem>(
          header: '#',
          width: 60,
          cellBuilder: (item, index) => Text(
            '${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Contract No',
          flex: 1,
          cellBuilder: (item, index) => Text(
            item.contractNo.isNotEmpty ? item.contractNo : '-',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'RC No',
          flex: 1,
          cellBuilder: (item, index) => Text(
            item.rcNo.isNotEmpty ? item.rcNo : '-',
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Vehicle',
          flex: 1.5,
          cellBuilder: (item, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${item.make} ${item.model}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (item.yom > 0)
                Text(
                  'YOM: ${item.yom}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Location',
          flex: 1.5,
          cellBuilder: (item, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.yardName.isNotEmpty ? item.yardName : '-',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                item.location,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Base Price',
          flex: 1,
          align: TextAlign.right,
          cellBuilder: (item, index) => Text(
            item.basePrice > 0 ? _currencyFormat.format(item.basePrice) : '-',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Bid Increment',
          flex: 0.8,
          align: TextAlign.right,
          cellBuilder: (item, index) => Text(
            item.bidIncrement > 0
                ? _currencyFormat.format(item.bidIncrement)
                : '-',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Images',
          width: 80,
          align: TextAlign.center,
          cellBuilder: (item, index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.hasImages
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${item.imageCount}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: item.hasImages ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Actions',
          width: 100,
          align: TextAlign.center,
          cellBuilder: (item, index) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                tooltip: 'View Details',
                onPressed: () => _showVehicleDetails(item),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVehicleDetails(VehicleItem vehicle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Identification', [
                        _DetailItem('Contract No', vehicle.contractNo),
                        _DetailItem('RC No', vehicle.rcNo),
                        _DetailItem('Engine No', vehicle.engineNo),
                        _DetailItem('Chassis No', vehicle.chassisNo),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Vehicle Details', [
                        _DetailItem('Make', vehicle.make),
                        _DetailItem('Model', vehicle.model),
                        _DetailItem('Year of Manufacture', vehicle.yom.toString()),
                        _DetailItem('Fuel Type', vehicle.fuelType),
                        _DetailItem('PPT', vehicle.ppt),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Location', [
                        _DetailItem('Yard Name', vehicle.yardName),
                        _DetailItem('City', vehicle.yardCity),
                        _DetailItem('State', vehicle.yardState),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Pricing', [
                        _DetailItem('Base Price', _currencyFormat.format(vehicle.basePrice)),
                        _DetailItem('Bid Increment', _currencyFormat.format(vehicle.bidIncrement)),
                        if (vehicle.multipleAmount > 0)
                          _DetailItem('Multiple Amount', _currencyFormat.format(vehicle.multipleAmount)),
                        if (vehicle.currentBid > 0)
                          _DetailItem('Current Bid', _currencyFormat.format(vehicle.currentBid)),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Additional Info', [
                        _DetailItem('RC Available', vehicle.rcAvailable ? 'Yes' : 'No'),
                        if (vehicle.repoDate != null)
                          _DetailItem('Repo Date', _dateFormat.format(vehicle.repoDate!)),
                        if (vehicle.contactPerson != null && vehicle.contactPerson!.isNotEmpty)
                          _DetailItem('Contact Person', vehicle.contactPerson!),
                        if (vehicle.contactNumber != null && vehicle.contactNumber!.isNotEmpty)
                          _DetailItem('Contact Number', vehicle.contactNumber!),
                        if (vehicle.remark != null && vehicle.remark!.isNotEmpty)
                          _DetailItem('Remark', vehicle.remark!),
                      ]),
                      if (vehicle.hasImages) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Images (${vehicle.imageCount})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: vehicle.images.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  vehicle.images[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<_DetailItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.where((item) => item.value.isNotEmpty && item.value != '0').map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    item.label,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}
