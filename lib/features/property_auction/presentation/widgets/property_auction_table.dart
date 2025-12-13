import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/property_auction.dart';

/// Table displaying property auctions with search and filter
class PropertyAuctionTable extends StatefulWidget {
  final List<PropertyAuction> auctions;
  final bool isLoading;
  final PropertyAuctionStatus? filterStatus;
  final Function(String) onSearch;
  final Function(PropertyAuctionStatus?) onFilterChanged;
  final Function(PropertyAuction) onViewDetails;
  final Function(PropertyAuction) onEdit;
  final Function(String) onDelete;

  const PropertyAuctionTable({
    super.key,
    required this.auctions,
    required this.isLoading,
    this.filterStatus,
    required this.onSearch,
    required this.onFilterChanged,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PropertyAuctionTable> createState() => _PropertyAuctionTableState();
}

class _PropertyAuctionTableState extends State<PropertyAuctionTable> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Search and Filter Header
          _buildHeader(),
          const Divider(height: 1),
          // Table
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.auctions.isEmpty
                    ? _buildEmptyState()
                    : ModernDataTable<PropertyAuction>(
                        data: widget.auctions,
                        columns: _buildColumns(),
                        onRowTap: widget.onViewDetails,
                        showSearch: false,
                        rowHeight: 80, // Minimum height, rows grow dynamically
                        emptyIcon: Icons.gavel,
                        emptyMessage: 'No property auctions found',
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: 'Search by event no, bank, description...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch('');
                        },
                        icon: const Icon(Icons.close, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PropertyAuctionStatus?>(
                value: widget.filterStatus,
                hint: const Text('All Status'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Status'),
                  ),
                  DropdownMenuItem(
                    value: PropertyAuctionStatus.live,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Live'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: PropertyAuctionStatus.upcoming,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Upcoming'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: PropertyAuctionStatus.ended,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Ended'),
                      ],
                    ),
                  ),
                ],
                onChanged: widget.onFilterChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TableColumnDef<PropertyAuction>> _buildColumns() {
    return [
      // Index column
      TableColumnDef<PropertyAuction>(
        header: '#',
        width: 40,
        cellBuilder: (auction, index) => Text(
          '${index + 1}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),

      // Event No
      TableColumnDef<PropertyAuction>(
        header: 'Event No',
        width: 90,
        cellBuilder: (auction, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            auction.eventNo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),

      // Bank
      TableColumnDef<PropertyAuction>(
        header: 'Bank',
        width: 100,
        cellBuilder: (auction, index) => Text(
          auction.eventBank,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // Property Details (multiline)
      TableColumnDef<PropertyAuction>(
        header: 'Property Details',
        flex: 3,
        cellBuilder: (auction, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category badges
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      auction.propertyCategory,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (auction.propertySubCategory.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        auction.propertySubCategory,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Borrower name
              if (auction.borrowerName.isNotEmpty)
                Text(
                  'Borrower: ${auction.borrowerName}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              // Description
              Text(
                auction.propertyDescription,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),

      // Start Date
      TableColumnDef<PropertyAuction>(
        header: 'Start Date',
        width: 100,
        cellBuilder: (auction, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dateFormat.format(auction.auctionStartDate),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _timeFormat.format(auction.auctionStartDate),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      // End Date
      TableColumnDef<PropertyAuction>(
        header: 'End Date',
        width: 100,
        cellBuilder: (auction, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dateFormat.format(auction.auctionEndDate),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _timeFormat.format(auction.auctionEndDate),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      // Reserve Price
      TableColumnDef<PropertyAuction>(
        header: 'Reserve Price',
        width: 100,
        cellBuilder: (auction, index) => Text(
          '₹${auction.formattedReservePrice}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),

      // EMD
      TableColumnDef<PropertyAuction>(
        header: 'EMD',
        width: 100,
        cellBuilder: (auction, index) => Text(
          '₹${auction.formattedEmdAmount}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),

      // Status
      TableColumnDef<PropertyAuction>(
        header: 'Status',
        width: 90,
        cellBuilder: (auction, index) => _buildStatusBadge(auction.status),
      ),

      // Actions
      TableColumnDef<PropertyAuction>(
        header: '',
        width: 50,
        align: TextAlign.center,
        cellBuilder: (auction, index) => PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('Edit Dates'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                widget.onViewDetails(auction);
                break;
              case 'edit':
                widget.onEdit(auction);
                break;
              case 'delete':
                _confirmDelete(auction);
                break;
            }
          },
        ),
      ),
    ];
  }

  Widget _buildStatusBadge(PropertyAuctionStatus status) {
    Color color;
    String label;

    switch (status) {
      case PropertyAuctionStatus.live:
        color = AppColors.success;
        label = 'Live';
        break;
      case PropertyAuctionStatus.upcoming:
        color = AppColors.warning;
        label = 'Upcoming';
        break;
      case PropertyAuctionStatus.ended:
        color = AppColors.textSecondary;
        label = 'Ended';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gavel,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No property auctions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Create a new auction to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(PropertyAuction auction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Auction?'),
        content: Text(
          'This will permanently delete the auction for "${auction.eventTitle}". '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(auction.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
