import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/referral_link.dart';

/// Table widget displaying referral links
class ReferralLinkTable extends StatelessWidget {
  final List<ReferralLink> links;
  final bool isLoading;
  final bool? filterByActive;
  final ValueChanged<bool?> onFilterChanged;
  final ValueChanged<ReferralLink> onViewDownloads;
  final void Function(String linkId, bool isActive) onToggleStatus;
  final ValueChanged<String> onDelete;

  const ReferralLinkTable({
    super.key,
    required this.links,
    required this.isLoading,
    this.filterByActive,
    required this.onFilterChanged,
    required this.onViewDownloads,
    required this.onToggleStatus,
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
        child: ModernDataTable<ReferralLink>(
          data: links,
          isLoading: isLoading,
          emptyMessage: 'No referral codes yet',
          emptyIcon: Icons.qr_code_outlined,
          searchHint: 'Search by name, mobile, or code...',
          searchableText: (link) =>
              '${link.name} ${link.mobile} ${link.code}',
          headerActions: _buildFilterChips(),
          columns: [
            TableColumnDef<ReferralLink>(
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
            TableColumnDef<ReferralLink>(
              header: 'Name',
              flex: 3,
              cellBuilder: (item, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.formattedMobile,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            TableColumnDef<ReferralLink>(
              header: 'Code',
              flex: 3,
              cellBuilder: (item, _) => _CodeCell(code: item.code),
            ),
            TableColumnDef<ReferralLink>(
              header: 'Downloads',
              flex: 2,
              align: TextAlign.center,
              cellBuilder: (item, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.hasDownloads
                      ? AppColors.info.withValues(alpha: 0.1)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.downloadCount.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.hasDownloads
                        ? AppColors.info
                        : AppColors.textLight,
                  ),
                ),
              ),
            ),
            TableColumnDef<ReferralLink>(
              header: 'Premium',
              flex: 2,
              align: TextAlign.center,
              cellBuilder: (item, _) => Text(
                item.premiumConversions.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: item.premiumConversions > 0
                      ? AppColors.accent
                      : AppColors.textLight,
                ),
              ),
            ),
            TableColumnDef<ReferralLink>(
              header: 'Status',
              flex: 2,
              align: TextAlign.center,
              cellBuilder: (item, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isActive
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.textLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: item.isActive
                        ? AppColors.success
                        : AppColors.textLight,
                  ),
                ),
              ),
            ),
            TableColumnDef<ReferralLink>(
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
            TableColumnDef<ReferralLink>(
              header: 'Actions',
              flex: 2,
              align: TextAlign.center,
              cellBuilder: (item, _) => _ActionsCell(
                link: item,
                onViewDownloads: () => onViewDownloads(item),
                onToggleStatus: () => onToggleStatus(item.id, !item.isActive),
                onDelete: () => onDelete(item.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilterChip(
          label: 'All',
          isSelected: filterByActive == null,
          onSelected: () => onFilterChanged(null),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Active',
          isSelected: filterByActive == true,
          onSelected: () => onFilterChanged(true),
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Inactive',
          isSelected: filterByActive == false,
          onSelected: () => onFilterChanged(false),
          color: AppColors.textLight,
        ),
      ],
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary).withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary).withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Code cell with copy functionality
class _CodeCell extends StatefulWidget {
  final String code;

  const _CodeCell({required this.code});

  @override
  State<_CodeCell> createState() => _CodeCellState();
}

class _CodeCellState extends State<_CodeCell> {
  bool _showCopied = false;

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _showCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showCopied = false);
    });
  }

  String get _formattedCode {
    final code = widget.code;
    if (code.length >= 8 && code.startsWith('VD')) {
      return '${code.substring(0, 2)}-${code.substring(2)}';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formattedCode,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _copyCode,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showCopied
                ? const Icon(
                    Icons.check_rounded,
                    key: ValueKey('check'),
                    size: 16,
                    color: AppColors.success,
                  )
                : Icon(
                    Icons.copy_rounded,
                    key: const ValueKey('copy'),
                    size: 16,
                    color: AppColors.textLight,
                  ),
          ),
        ),
      ],
    );
  }
}

/// Actions cell with menu
class _ActionsCell extends StatelessWidget {
  final ReferralLink link;
  final VoidCallback onViewDownloads;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _ActionsCell({
    required this.link,
    required this.onViewDownloads,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // View downloads button
        Tooltip(
          message: link.hasDownloads
              ? 'View ${link.downloadCount} downloads'
              : 'No downloads yet',
          child: InkWell(
            onTap: onViewDownloads,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.visibility_rounded,
                size: 16,
                color: link.hasDownloads
                    ? AppColors.primary
                    : AppColors.textLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // More actions menu
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            size: 16,
            color: AppColors.textSecondary,
          ),
          splashRadius: 16,
          padding: EdgeInsets.zero,
          iconSize: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    link.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(link.isActive ? 'Deactivate' : 'Activate'),
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
              case 'toggle':
                onToggleStatus();
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
        title: const Text('Delete Referral Code?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete the referral code for ${link.name}?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (link.hasDownloads) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This code has ${link.downloadCount} downloads. All download records will also be deleted.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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
