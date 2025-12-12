import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/referral_download.dart';
import '../../domain/entities/referral_link.dart';

/// Bottom sheet showing downloads for a specific referral link
class DownloadDetailsSheet extends StatefulWidget {
  final ReferralLink link;
  final List<ReferralDownload>? downloads;
  final VoidCallback onClose;

  const DownloadDetailsSheet({
    super.key,
    required this.link,
    this.downloads,
    required this.onClose,
  });

  @override
  State<DownloadDetailsSheet> createState() => _DownloadDetailsSheetState();
}

class _DownloadDetailsSheetState extends State<DownloadDetailsSheet> {
  _DownloadFilter _selectedFilter = _DownloadFilter.all;

  List<ReferralDownload> get _filteredDownloads {
    if (widget.downloads == null) return [];
    switch (_selectedFilter) {
      case _DownloadFilter.all:
        return widget.downloads!;
      case _DownloadFilter.registered:
        return widget.downloads!.where((d) => d.isRegistered).toList();
      case _DownloadFilter.premium:
        return widget.downloads!.where((d) => d.isPremium).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Downloads for ${widget.link.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.link.formattedCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.link.downloadCount} downloads',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Filter tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _DownloadFilter.values.map((filter) {
                final isSelected = _selectedFilter == filter;
                final count = _getFilterCount(filter);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    label: Text('${filter.label} ($count)'),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }).toList(),
            ),
          ),

          // Downloads list
          Flexible(
            child: widget.downloads == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _filteredDownloads.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredDownloads.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return _DownloadItem(download: _filteredDownloads[index]);
                        },
                      ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  int _getFilterCount(_DownloadFilter filter) {
    if (widget.downloads == null) return 0;
    switch (filter) {
      case _DownloadFilter.all:
        return widget.downloads!.length;
      case _DownloadFilter.registered:
        return widget.downloads!.where((d) => d.isRegistered).length;
      case _DownloadFilter.premium:
        return widget.downloads!.where((d) => d.isPremium).length;
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: AppColors.textLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == _DownloadFilter.all
                ? 'No downloads yet'
                : 'No ${_selectedFilter.label.toLowerCase()} downloads',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == _DownloadFilter.all
                ? 'Downloads will appear here when users use this code'
                : 'Try a different filter to see more results',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Individual download item
class _DownloadItem extends StatelessWidget {
  final ReferralDownload download;

  const _DownloadItem({required this.download});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Platform icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPlatformColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getPlatformIcon(),
              color: _getPlatformColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Device info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  download.truncatedDeviceId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  download.deviceInfo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // User info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  download.isRegistered ? download.userDisplayName : '-',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: download.isRegistered
                        ? AppColors.textPrimary
                        : AppColors.textLight,
                  ),
                ),
                if (download.isRegistered && download.userMobile != null)
                  Text(
                    download.userMobile!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),

          // Status badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (download.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 12,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMM, h:mm a').format(download.downloadedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon() {
    switch (download.platform) {
      case DownloadPlatform.android:
        return Icons.android_rounded;
      case DownloadPlatform.ios:
        return Icons.apple_rounded;
      case DownloadPlatform.unknown:
        return Icons.device_unknown_rounded;
    }
  }

  Color _getPlatformColor() {
    switch (download.platform) {
      case DownloadPlatform.android:
        return const Color(0xFF3DDC84);
      case DownloadPlatform.ios:
        return AppColors.textPrimary;
      case DownloadPlatform.unknown:
        return AppColors.textSecondary;
    }
  }
}

/// Download filter options
enum _DownloadFilter {
  all,
  registered,
  premium,
}

extension _DownloadFilterX on _DownloadFilter {
  String get label {
    switch (this) {
      case _DownloadFilter.all:
        return 'All';
      case _DownloadFilter.registered:
        return 'Registered';
      case _DownloadFilter.premium:
        return 'Premium';
    }
  }
}
