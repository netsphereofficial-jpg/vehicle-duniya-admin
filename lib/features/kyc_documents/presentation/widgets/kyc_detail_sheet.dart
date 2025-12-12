import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/kyc_document.dart';

/// Bottom sheet showing KYC document details with image gallery
class KycDetailSheet extends StatefulWidget {
  final KycDocument document;
  final VoidCallback? onDelete;

  const KycDetailSheet({
    super.key,
    required this.document,
    this.onDelete,
  });

  /// Show as bottom sheet
  static Future<void> show(
    BuildContext context, {
    required KycDocument document,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KycDetailSheet(
        document: document,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<KycDetailSheet> createState() => _KycDetailSheetState();
}

class _KycDetailSheetState extends State<KycDetailSheet> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.document.allImages;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_shared_outlined,
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
                          widget.document.userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.document.formattedPhone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // User Info Section
                  _SectionCard(
                    title: 'User Information',
                    icon: Icons.person_outline,
                    children: [
                      _InfoRow(label: 'Name', value: widget.document.userName),
                      _InfoRow(
                        label: 'Phone',
                        value: widget.document.formattedPhone,
                      ),
                      if (widget.document.userAddress != null)
                        _InfoRow(
                          label: 'Address',
                          value: widget.document.userAddress!,
                        ),
                      _InfoRow(
                        label: 'Uploaded On',
                        value: DateFormat('d MMM yyyy, h:mm a')
                            .format(widget.document.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Aadhaar Section
                  if (widget.document.hasAadhaar) ...[
                    _SectionCard(
                      title: 'Aadhaar Card',
                      icon: Icons.credit_card_outlined,
                      color: AppColors.info,
                      children: [
                        _InfoRow(
                          label: 'Aadhaar Number',
                          value: widget.document.maskedAadhaar,
                          isMasked: true,
                        ),
                        if (widget.document.aadhaarFrontUrl != null ||
                            widget.document.aadhaarBackUrl != null)
                          _InfoRow(
                            label: 'Images',
                            value:
                                '${widget.document.aadhaarFrontUrl != null ? "Front" : ""}${widget.document.aadhaarFrontUrl != null && widget.document.aadhaarBackUrl != null ? " + " : ""}${widget.document.aadhaarBackUrl != null ? "Back" : ""}',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // PAN Section
                  if (widget.document.hasPan) ...[
                    _SectionCard(
                      title: 'PAN Card',
                      icon: Icons.badge_outlined,
                      color: AppColors.accent,
                      children: [
                        _InfoRow(
                          label: 'PAN Number',
                          value: widget.document.formattedPan,
                        ),
                        if (widget.document.panFrontUrl != null ||
                            widget.document.panBackUrl != null)
                          _InfoRow(
                            label: 'Images',
                            value:
                                '${widget.document.panFrontUrl != null ? "Front" : ""}${widget.document.panFrontUrl != null && widget.document.panBackUrl != null ? " + " : ""}${widget.document.panBackUrl != null ? "Back" : ""}',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Document Images Gallery
                  if (images.isNotEmpty) ...[
                    const Text(
                      'Document Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Main Image Viewer
                    GestureDetector(
                      onTap: () => _showFullScreenImage(
                        context,
                        images[_selectedImageIndex].url,
                        images[_selectedImageIndex].label,
                      ),
                      child: Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: images[_selectedImageIndex].url,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: AppColors.textLight,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Label overlay
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    images[_selectedImageIndex].label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // Expand icon
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Thumbnail selector
                    if (images.length > 1)
                      SizedBox(
                        height: 70,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedImageIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImageIndex = index),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.borderLight,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: images[index].url,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: AppColors.surfaceVariant,
                                          child: const Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: AppColors.surfaceVariant,
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            size: 20,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ),
                                      // Label at bottom
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          color: Colors.black54,
                                          child: Text(
                                            images[index].label,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                  const SizedBox(height: 24),

                  // Delete Button
                  if (widget.onDelete != null)
                    OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Document'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url, String label) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(
          imageUrl: url,
          label: label,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete KYC Document?'),
        content: Text(
          'Are you sure you want to delete the KYC documents for ${widget.document.userName}? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sheet
              widget.onDelete?.call();
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

/// Section card with title and content
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.color = AppColors.primary,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Information row with label and value
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMasked;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontFamily: isMasked ? 'monospace' : null,
                letterSpacing: isMasked ? 1 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen image viewer with zoom
class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _FullScreenImageView({
    required this.imageUrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(label),
        elevation: 0,
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(
              color: Colors.white,
            ),
            errorWidget: (context, url, error) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined, size: 64, color: Colors.white54),
                SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
