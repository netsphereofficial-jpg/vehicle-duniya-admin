import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/kyc_document.dart';

/// Table widget displaying KYC documents
class KycTable extends StatelessWidget {
  final List<KycDocument> documents;
  final bool isLoading;
  final ValueChanged<KycDocument> onViewDetails;
  final ValueChanged<String> onDelete;

  const KycTable({
    super.key,
    required this.documents,
    required this.isLoading,
    required this.onViewDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ModernDataTable<KycDocument>(
          data: documents,
          isLoading: isLoading,
          emptyMessage: 'No KYC documents found',
          emptyIcon: Icons.folder_off_outlined,
          searchHint: 'Search by name, phone, PAN, or Aadhaar...',
          searchableText: (doc) =>
              '${doc.userName} ${doc.userPhone} ${doc.panNumber ?? ''} ${doc.aadhaarNumber ?? ''}',
          columns: [
            TableColumnDef<KycDocument>(
              header: '#',
              flex: 1,
              cellBuilder: (item, index) => Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TableColumnDef<KycDocument>(
              header: 'User',
              flex: 4,
              cellBuilder: (item, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.formattedPhone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            TableColumnDef<KycDocument>(
              header: 'Aadhaar',
              flex: 3,
              cellBuilder: (item, _) => item.hasAadhaar
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.maskedAadhaar,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.info,
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
            ),
            TableColumnDef<KycDocument>(
              header: 'PAN',
              flex: 3,
              cellBuilder: (item, _) => item.hasPan
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.formattedPan,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  : const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
            ),
            TableColumnDef<KycDocument>(
              header: 'Images',
              flex: 2,
              align: TextAlign.center,
              cellBuilder: (item, _) => _ImagesBadge(count: item.totalImages),
            ),
            TableColumnDef<KycDocument>(
              header: 'Date',
              flex: 2,
              cellBuilder: (item, _) => Text(
                DateFormat('d MMM yy').format(item.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TableColumnDef<KycDocument>(
              header: 'Actions',
              flex: 2,
              align: TextAlign.center,
              cellBuilder: (item, _) => _ActionsCell(
                document: item,
                onViewDetails: () => onViewDetails(item),
                onDelete: () => onDelete(item.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Images count badge
class _ImagesBadge extends StatelessWidget {
  final int count;

  const _ImagesBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: count > 0
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            count > 0 ? Icons.image : Icons.image_not_supported_outlined,
            size: 14,
            color: count > 0 ? AppColors.success : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: count > 0 ? AppColors.success : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Actions cell with view and delete buttons
class _ActionsCell extends StatelessWidget {
  final KycDocument document;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;

  const _ActionsCell({
    required this.document,
    required this.onViewDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'View details',
          child: InkWell(
            onTap: onViewDetails,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            size: 18,
            color: AppColors.textSecondary,
          ),
          splashRadius: 16,
          padding: EdgeInsets.zero,
          iconSize: 18,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  const Text('View Details'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                onViewDetails();
                break;
              case 'delete':
                _showDeleteConfirmation(context);
                break;
            }
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete KYC Document?'),
        content: Text(
          'Are you sure you want to delete the KYC documents for ${document.userName}? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
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
