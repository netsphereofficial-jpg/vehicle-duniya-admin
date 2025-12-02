import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/auction.dart';

/// A card widget to display auction information in a list
class AuctionListItem extends StatelessWidget {
  final Auction auction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AuctionListItem({
    super.key,
    required this.auction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor(AuctionStatus status) {
    switch (status) {
      case AuctionStatus.upcoming:
        return AppColors.warning;
      case AuctionStatus.live:
        return AppColors.success;
      case AuctionStatus.ended:
        return AppColors.textSecondary;
      case AuctionStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auction Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auction.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              auction.categoryName.isNotEmpty
                                  ? auction.categoryName
                                  : 'Uncategorized',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 16),

              // Details Row
              Wrap(
                spacing: 24,
                runSpacing: 8,
                children: [
                  _buildInfoItem(
                    Icons.calendar_today_outlined,
                    'Start',
                    dateFormatter.format(auction.startDate),
                  ),
                  _buildInfoItem(
                    Icons.event_outlined,
                    'End',
                    dateFormatter.format(auction.endDate),
                  ),
                  _buildInfoItem(
                    Icons.lan_outlined,
                    'Mode',
                    auction.mode.displayName,
                  ),
                  _buildInfoItem(
                    Icons.business_outlined,
                    'Event',
                    auction.eventType.displayName,
                  ),
                  _buildInfoItem(
                    Icons.directions_car_outlined,
                    'Vehicles',
                    '${auction.vehicleCount}',
                  ),
                ],
              ),

              // Actions Row
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(auction.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(auction.status).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        auction.status.displayName,
        style: TextStyle(
          color: _getStatusColor(auction.status),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
