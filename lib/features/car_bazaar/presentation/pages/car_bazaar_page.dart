import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/car_bazaar_shop.dart';
import '../bloc/car_bazaar_bloc.dart';
import '../bloc/car_bazaar_event.dart';
import '../bloc/car_bazaar_state.dart';
import '../widgets/shop_detail_sheet.dart';
import '../widgets/shop_form_dialog.dart';
import '../widgets/shop_stats_cards.dart';
import '../widgets/shop_table.dart';

/// Main page for Car Bazaar shop management
class CarBazaarPage extends StatefulWidget {
  const CarBazaarPage({super.key});

  @override
  State<CarBazaarPage> createState() => _CarBazaarPageState();
}

class _CarBazaarPageState extends State<CarBazaarPage> {
  @override
  void initState() {
    super.initState();
    // Subscribe to real-time updates
    context.read<CarBazaarBloc>().add(const LoadShopsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<CarBazaarBloc, CarBazaarState>(
        listener: (context, state) {
          // Show error snackbar
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }

          // Show success snackbar
          if (state.hasSuccess && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }

          // Show credentials dialog after shop creation
          if (state.createdShop != null) {
            _showCredentialsDialog(state.createdShop!);
            // Clear the created shop from state
            context.read<CarBazaarBloc>().add(const ClearCreatedShop());
          }

          // Show new password dialog after password reset
          if (state.newPassword != null && state.newPassword!.isNotEmpty) {
            _showNewPasswordDialog(state.newPassword!);
            // Clear the new password from state
            context.read<CarBazaarBloc>().add(const ClearNewPassword());
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),

                // Stats Cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: ShopStatsCards(
                      totalShops: state.totalShops,
                      activeShops: state.activeShops,
                      inactiveShops: state.inactiveShops,
                      isLoading: state.isLoading,
                    ),
                  ),
                ),

                // Table Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const Text(
                          'Shops',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${state.filteredShops.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Table
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 500,
                      child: ShopTable(
                        shops: state.filteredShops,
                        isLoading: state.isLoading,
                        filterByActive: state.filterByActive,
                        onSearch: (query) {
                          context
                              .read<CarBazaarBloc>()
                              .add(SearchShopsRequested(query));
                        },
                        onFilterChanged: (isActive) {
                          context
                              .read<CarBazaarBloc>()
                              .add(FilterByStatusRequested(isActive));
                        },
                        onViewDetails: (shop) {
                          ShopDetailSheet.show(
                            context,
                            shop: shop,
                            onEdit: () => _showEditDialog(shop),
                            onToggleStatus: () {
                              context.read<CarBazaarBloc>().add(
                                    ToggleShopStatusRequested(
                                      id: shop.id,
                                      isActive: !shop.isActive,
                                    ),
                                  );
                            },
                            onResetPassword: () {
                              context.read<CarBazaarBloc>().add(
                                    ResetPasswordRequested(
                                      id: shop.id,
                                      shopName: shop.shopName,
                                    ),
                                  );
                            },
                            onDelete: () {
                              context.read<CarBazaarBloc>().add(
                                    DeleteShopRequested(shop.id),
                                  );
                            },
                          );
                        },
                        onEdit: _showEditDialog,
                        onToggleStatus: (shopId, isActive) {
                          context.read<CarBazaarBloc>().add(
                                ToggleShopStatusRequested(
                                  id: shopId,
                                  isActive: isActive,
                                ),
                              );
                        },
                        onResetPassword: (shopId, shopName) {
                          context.read<CarBazaarBloc>().add(
                                ResetPasswordRequested(
                                  id: shopId,
                                  shopName: shopName,
                                ),
                              );
                        },
                        onDelete: (shopId) {
                          context.read<CarBazaarBloc>().add(
                                DeleteShopRequested(shopId),
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Car Bazaar Shops',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage Car Bazaar shop accounts and credentials',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Refresh button
          IconButton(
            onPressed: () {
              context.read<CarBazaarBloc>().add(const LoadShopsRequested());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          // Add shop button
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ShopFormDialog(
        isLoading: false,
        onSubmit: (
          String shopName,
          String ownerName,
          String phone,
          String email,
          String address,
          String? gstNumber,
          String? licenseNumber,
          BusinessType businessType,
          Uint8List? logoBytes,
          String? logoFileName,
        ) {
          Navigator.pop(dialogContext);
          context.read<CarBazaarBloc>().add(
                CreateShopRequested(
                  shopName: shopName,
                  ownerName: ownerName,
                  phone: phone,
                  email: email,
                  address: address,
                  gstNumber: gstNumber,
                  licenseNumber: licenseNumber,
                  businessType: businessType,
                  logoBytes: logoBytes,
                  logoFileName: logoFileName,
                ),
              );
        },
      ),
    );
  }

  void _showEditDialog(CarBazaarShop shop) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ShopFormDialog(
        shop: shop,
        isLoading: false,
        onSubmit: (
          String shopName,
          String ownerName,
          String phone,
          String email,
          String address,
          String? gstNumber,
          String? licenseNumber,
          BusinessType businessType,
          Uint8List? logoBytes,
          String? logoFileName,
        ) {
          Navigator.pop(dialogContext);
          context.read<CarBazaarBloc>().add(
                UpdateShopRequested(
                  id: shop.id,
                  shopName: shopName,
                  ownerName: ownerName,
                  phone: phone,
                  email: email,
                  address: address,
                  gstNumber: gstNumber,
                  licenseNumber: licenseNumber,
                  businessType: businessType,
                  logoBytes: logoBytes,
                  logoFileName: logoFileName,
                ),
              );
        },
      ),
    );
  }

  void _showCredentialsDialog(CarBazaarShop shop) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Shop Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share these credentials with the shop owner:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildCredentialRow('Shop ID', shop.shopId),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildCredentialRow('Password', shop.password ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The password cannot be retrieved later. Make sure to share it now!',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showNewPasswordDialog(String newPassword) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_reset,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Password Reset'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share the new password with the shop owner:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _buildCredentialRow('New Password', newPassword),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The password cannot be retrieved later. Make sure to share it now!',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label copied to clipboard'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copy',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
