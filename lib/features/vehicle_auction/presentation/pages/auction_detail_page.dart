import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
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

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  int _selectedTabIndex = 0;
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    _loadAuctionData();
  }

  void _loadAuctionData() {
    context.read<AuctionBloc>()
      ..add(LoadAuctionDetailRequested(widget.auctionId))
      ..add(LoadAuctionVehiclesRequested(widget.auctionId));
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
          backgroundColor: AppColors.background,
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
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Auction not found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.go('/vehicle-auctions/active'),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Auction auction, AuctionState state) {
    return Column(
      children: [
        _buildHeader(context, auction, state),
        Expanded(
          child: _selectedTabIndex == 0
              ? _buildDetailsTab(auction)
              : _buildVehiclesTab(state),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Auction auction, AuctionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Back button, title, status, edit
          Row(
            children: [
              // Back button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => context.go('/vehicle-auctions/active'),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  tooltip: 'Back',
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 16),
              // Title and meta
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        auction.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(auction.status),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Meta info chips
              _buildMetaChip(
                icon: Icons.category_outlined,
                label: auction.categoryName.isNotEmpty
                    ? auction.categoryName
                    : auction.category,
              ),
              const SizedBox(width: 8),
              _buildMetaChip(
                icon: Icons.directions_car_outlined,
                label: '${state.auctionVehicles.length} vehicles',
              ),
              const SizedBox(width: 16),
              // Edit button
              FilledButton.icon(
                onPressed: () => context.go('/vehicle-auctions/${auction.id}/edit'),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tab bar
          _buildModernTabs(state),
        ],
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
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
        icon = Icons.play_circle_filled;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabs(AuctionState state) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            index: 0,
            icon: Icons.info_outline,
            label: 'Details',
          ),
          const SizedBox(width: 4),
          _buildTab(
            index: 1,
            icon: Icons.directions_car_outlined,
            label: 'Vehicles (${state.auctionVehicles.length})',
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(Auction auction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              children: [
                _buildInfoCard(
                  icon: Icons.gavel_outlined,
                  title: 'Auction Information',
                  rows: [
                    _InfoRow('Name', auction.name),
                    _InfoRow('Category', auction.categoryName.isNotEmpty
                        ? auction.categoryName
                        : auction.category),
                    _InfoRow('Mode', auction.mode.displayName),
                    _InfoRow('Event Type', auction.eventType.displayName),
                    if (auction.eventId != null && auction.eventId!.isNotEmpty)
                      _InfoRow('Event ID', auction.eventId!),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.settings_outlined,
                  title: 'Configuration',
                  rows: [
                    _InfoRow('Check Base Price', auction.checkBasePrice ? 'Yes' : 'No'),
                    _InfoRow('Zip Type', auction.zipType.displayName),
                    _InfoRow('Total Vehicles', auction.vehicleCount.toString()),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: 'Metadata',
                  rows: [
                    _InfoRow('Created By', auction.createdBy),
                    _InfoRow('Created At', _dateFormat.format(auction.createdAt)),
                    _InfoRow('Updated At', _dateFormat.format(auction.updatedAt)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right column
          Expanded(
            child: Column(
              children: [
                _buildInfoCard(
                  icon: Icons.schedule_outlined,
                  title: 'Schedule',
                  rows: [
                    _InfoRow('Start Date', _dateFormat.format(auction.startDate)),
                    _InfoRow('End Date', _dateFormat.format(auction.endDate)),
                    _InfoRow('Duration', _formatDuration(auction.duration)),
                    _InfoRow('Status', auction.status.displayName),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.folder_outlined,
                  title: 'Files',
                  rows: [
                    _InfoRow(
                      'Bid Report',
                      auction.bidReportUrl != null && auction.bidReportUrl!.isNotEmpty
                          ? 'Uploaded'
                          : 'Not uploaded',
                      valueColor: auction.bidReportUrl != null && auction.bidReportUrl!.isNotEmpty
                          ? Colors.green
                          : AppColors.textSecondary,
                    ),
                    _InfoRow(
                      'Images Zip',
                      auction.imagesZipUrl != null && auction.imagesZipUrl!.isNotEmpty
                          ? 'Uploaded'
                          : 'Not uploaded',
                      valueColor: auction.imagesZipUrl != null && auction.imagesZipUrl!.isNotEmpty
                          ? Colors.green
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final isLast = entry.key == rows.length - 1;
                final row = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          row.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: row.valueColor ?? AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
      return '$hours hour${hours > 1 ? 's' : ''}, $minutes min${minutes > 1 ? 's' : ''}';
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
          width: 50,
          cellBuilder: (item, index) => Text(
            '${index + 1}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Contract No',
          flex: 1,
          cellBuilder: (item, index) => Text(
            item.contractNo.isNotEmpty ? item.contractNo : '-',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'RC No',
          flex: 1,
          cellBuilder: (item, index) => Text(
            item.rcNo.isNotEmpty ? item.rcNo : '-',
            style: const TextStyle(fontSize: 13),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (item.yom > 0)
                Text(
                  'YOM: ${item.yom}',
                  style: TextStyle(
                    fontSize: 11,
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.location,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
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
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Increment',
          width: 100,
          align: TextAlign.right,
          cellBuilder: (item, index) => Text(
            item.bidIncrement > 0
                ? _currencyFormat.format(item.bidIncrement)
                : '-',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: 'Images',
          width: 70,
          align: TextAlign.center,
          cellBuilder: (item, index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: item.hasImages
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.imageCount}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: item.hasImages ? Colors.green : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        TableColumnDef<VehicleItem>(
          header: '',
          width: 50,
          align: TextAlign.center,
          cellBuilder: (item, index) => IconButton(
            icon: Icon(
              Icons.visibility_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            tooltip: 'View Details',
            onPressed: () => _showVehicleDetails(item),
            visualDensity: VisualDensity.compact,
            hoverColor: AppColors.primary.withValues(alpha: 0.1),
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
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (vehicle.yom > 0)
                            Text(
                              'Year: ${vehicle.yom}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
              // Dialog content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogSection('Identification', [
                        _DetailItem('Contract No', vehicle.contractNo),
                        _DetailItem('RC No', vehicle.rcNo),
                        _DetailItem('Engine No', vehicle.engineNo),
                        _DetailItem('Chassis No', vehicle.chassisNo),
                      ]),
                      _buildDialogSection('Vehicle Details', [
                        _DetailItem('Make', vehicle.make),
                        _DetailItem('Model', vehicle.model),
                        _DetailItem('Year of Manufacture', vehicle.yom > 0 ? vehicle.yom.toString() : '-'),
                        _DetailItem('Fuel Type', vehicle.fuelType),
                        if (vehicle.ppt.isNotEmpty) _DetailItem('PPT', vehicle.ppt),
                      ]),
                      _buildDialogSection('Location', [
                        _DetailItem('Yard Name', vehicle.yardName),
                        _DetailItem('City', vehicle.yardCity),
                        _DetailItem('State', vehicle.yardState),
                      ]),
                      _buildDialogSection('Pricing', [
                        _DetailItem('Base Price', _currencyFormat.format(vehicle.basePrice)),
                        _DetailItem('Bid Increment', _currencyFormat.format(vehicle.bidIncrement)),
                        if (vehicle.multipleAmount > 0)
                          _DetailItem('Multiple Amount', _currencyFormat.format(vehicle.multipleAmount)),
                        if (vehicle.currentBid > 0)
                          _DetailItem('Current Bid', _currencyFormat.format(vehicle.currentBid)),
                      ]),
                      _buildDialogSection('Additional Info', [
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.photo_library_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Images (${vehicle.imageCount})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: vehicle.images.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  vehicle.images[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.background,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.textSecondary,
                                    ),
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

  Widget _buildDialogSection(String title, List<_DetailItem> items) {
    final filteredItems = items.where(
      (item) => item.value.isNotEmpty && item.value != '0' && item.value != '-',
    ).toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...filteredItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final Color? valueColor;

  _InfoRow(this.label, this.value, {this.valueColor});
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}
