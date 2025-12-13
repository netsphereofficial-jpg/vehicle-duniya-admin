import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/car_bazaar_shop.dart';

/// Bottom sheet showing detailed shop information
class ShopDetailSheet extends StatelessWidget {
  final CarBazaarShop shop;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const ShopDetailSheet({
    super.key,
    required this.shop,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onResetPassword,
    required this.onDelete,
    required this.onClose,
  });

  /// Static method to show the detail sheet as a modal bottom sheet
  static void show(
    BuildContext context, {
    required CarBazaarShop shop,
    required VoidCallback onEdit,
    required VoidCallback onToggleStatus,
    required VoidCallback onResetPassword,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (bottomSheetContext) => ShopDetailSheet(
        shop: shop,
        onEdit: () {
          Navigator.pop(bottomSheetContext);
          onEdit();
        },
        onToggleStatus: () {
          Navigator.pop(bottomSheetContext);
          onToggleStatus();
        },
        onResetPassword: () {
          onResetPassword();
        },
        onDelete: () {
          Navigator.pop(bottomSheetContext);
          onDelete();
        },
        onClose: () => Navigator.pop(bottomSheetContext),
      ),
    );
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
          // Handle
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
          _buildHeader(context),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & Basic Info
                  _buildBasicInfo(),
                  const SizedBox(height: 24),

                  // Contact Info
                  _buildSection(
                    title: 'Contact Information',
                    icon: Icons.contact_phone_outlined,
                    children: [
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: shop.formattedPhone,
                        canCopy: true,
                      ),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: shop.email,
                        canCopy: true,
                      ),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: shop.address,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Business Details
                  _buildSection(
                    title: 'Business Details',
                    icon: Icons.business_outlined,
                    children: [
                      _buildInfoRow(
                        icon: Icons.category_outlined,
                        label: 'Business Type',
                        value: shop.businessType.label,
                      ),
                      if (shop.hasGst)
                        _buildInfoRow(
                          icon: Icons.receipt_outlined,
                          label: 'GST Number',
                          value: shop.gstNumber!,
                          canCopy: true,
                        ),
                      if (shop.hasLicense)
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'License Number',
                          value: shop.licenseNumber!,
                          canCopy: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Account Info
                  _buildSection(
                    title: 'Account Details',
                    icon: Icons.account_circle_outlined,
                    children: [
                      _buildInfoRow(
                        icon: Icons.tag,
                        label: 'Shop ID',
                        value: shop.shopId,
                        canCopy: true,
                        highlight: true,
                      ),
                      _buildInfoRow(
                        icon: shop.isActive
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        label: 'Status',
                        value: shop.isActive ? 'Active' : 'Inactive',
                        valueColor:
                            shop.isActive ? AppColors.success : AppColors.error,
                      ),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Created',
                        value: DateFormat('MMM dd, yyyy').format(shop.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Shop Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: shop.hasLogo
                ? CachedNetworkImage(
                    imageUrl: shop.logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.storefront,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                  )
                : const Icon(
                    Icons.storefront,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
          ),
          const SizedBox(width: 20),

          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.shopName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Owner: ${shop.ownerName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (shop.isActive ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    shop.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          shop.isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((entry) => Column(
                      children: [
                        entry.value,
                        if (entry.key < children.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool canCopy = false,
    bool highlight = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
                fontFamily: highlight ? 'monospace' : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          if (canCopy) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
              },
              child: Icon(
                Icons.copy,
                size: 16,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        // Primary Actions Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: AppColors.primary,
                onTap: onEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: shop.isActive
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                label: shop.isActive ? 'Deactivate' : 'Activate',
                color:
                    shop.isActive ? Colors.orange : AppColors.success,
                onTap: onToggleStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Secondary Actions Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.lock_reset_outlined,
                label: 'Reset Password',
                color: AppColors.textSecondary,
                onTap: () => _confirmResetPassword(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
                onTap: () => _confirmDelete(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmResetPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password?'),
        content: Text(
          'This will generate a new password for ${shop.shopName}. '
          'The old password will no longer work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onResetPassword();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Shop?'),
        content: Text(
          'This will permanently delete ${shop.shopName} and all its data. '
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
