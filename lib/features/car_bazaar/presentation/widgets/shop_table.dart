import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/car_bazaar_shop.dart';

/// Table displaying Car Bazaar shops with search and filter
class ShopTable extends StatefulWidget {
  final List<CarBazaarShop> shops;
  final bool isLoading;
  final bool? filterByActive;
  final Function(String) onSearch;
  final Function(bool?) onFilterChanged;
  final Function(CarBazaarShop) onViewDetails;
  final Function(CarBazaarShop) onEdit;
  final Function(String, bool) onToggleStatus;
  final Function(String, String) onResetPassword;
  final Function(String) onDelete;

  const ShopTable({
    super.key,
    required this.shops,
    required this.isLoading,
    this.filterByActive,
    required this.onSearch,
    required this.onFilterChanged,
    required this.onViewDetails,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onResetPassword,
    required this.onDelete,
  });

  @override
  State<ShopTable> createState() => _ShopTableState();
}

class _ShopTableState extends State<ShopTable> {
  final TextEditingController _searchController = TextEditingController();

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

          // Divider
          const Divider(height: 1),

          // Table
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.shops.isEmpty
                    ? _buildEmptyState()
                    : ModernDataTable<CarBazaarShop>(
                        data: widget.shops,
                        columns: _buildColumns(),
                        onRowTap: widget.onViewDetails,
                        showSearch: false,
                        emptyIcon: Icons.storefront_outlined,
                        emptyMessage: 'No shops found',
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
                hintText: 'Search by name, owner, ID, phone...',
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
              child: DropdownButton<bool?>(
                value: widget.filterByActive,
                hint: const Text('All Status'),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Status'),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        SizedBox(width: 8),
                        Text('Active'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Inactive'),
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

  List<TableColumnDef<CarBazaarShop>> _buildColumns() {
    return [
      // Index column
      TableColumnDef<CarBazaarShop>(
        header: '#',
        width: 40,
        cellBuilder: (shop, index) => Text(
          '${index + 1}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),

      // Shop Name with Logo
      TableColumnDef<CarBazaarShop>(
        header: 'Shop Name',
        flex: 1,
        cellBuilder: (shop, index) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: shop.hasLogo
                  ? CachedNetworkImage(
                      imageUrl: shop.logoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Icon(
                        Icons.storefront,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.storefront,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.storefront,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                shop.shopName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // Shop ID
      TableColumnDef<CarBazaarShop>(
        header: 'Shop ID',
        width: 80,
        cellBuilder: (shop, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            shop.shopId,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ),
      ),

      // Owner
      TableColumnDef<CarBazaarShop>(
        header: 'Owner Name',
        flex: 1,
        cellBuilder: (shop, index) => Text(
          shop.ownerName,
          style: const TextStyle(color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // Phone
      TableColumnDef<CarBazaarShop>(
        header: 'Phone',
        width: 115,
        cellBuilder: (shop, index) => Text(
          shop.formattedPhone,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),

      // Business Type
      TableColumnDef<CarBazaarShop>(
        header: 'Type',
        width: 100,
        cellBuilder: (shop, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            shop.businessType.label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),

      // Status
      TableColumnDef<CarBazaarShop>(
        header: 'Status',
        width: 90,
        cellBuilder: (shop, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (shop.isActive ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: shop.isActive ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                shop.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: shop.isActive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),

      // Actions
      TableColumnDef<CarBazaarShop>(
        header: '',
        width: 50,
        align: TextAlign.center,
        cellBuilder: (shop, index) => PopupMenuButton<String>(
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
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    shop.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(shop.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.lock_reset_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('Reset Password'),
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
                widget.onViewDetails(shop);
                break;
              case 'edit':
                widget.onEdit(shop);
                break;
              case 'toggle':
                widget.onToggleStatus(shop.id, !shop.isActive);
                break;
              case 'reset':
                _confirmResetPassword(shop);
                break;
              case 'delete':
                _confirmDelete(shop);
                break;
            }
          },
        ),
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No shops found',
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
                : 'Add a new shop to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetPassword(CarBazaarShop shop) {
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
              widget.onResetPassword(shop.id, shop.shopName);
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

  void _confirmDelete(CarBazaarShop shop) {
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
              widget.onDelete(shop.id);
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
