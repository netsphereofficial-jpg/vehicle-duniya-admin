import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/permissions.dart';

/// Widget for selecting permissions grouped by category
class PermissionSelector extends StatelessWidget {
  final List<AppPermission> selectedPermissions;
  final ValueChanged<List<AppPermission>> onChanged;
  final bool enabled;

  const PermissionSelector({
    super.key,
    required this.selectedPermissions,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with select all/none
        _buildHeader(),
        const SizedBox(height: 16),
        // Permission groups
        ...permissionGroupOrder.map((group) => _buildPermissionGroup(group)),
      ],
    );
  }

  Widget _buildHeader() {
    final allSelected = selectedPermissions.length == AppPermission.values.length;
    final someSelected = selectedPermissions.isNotEmpty && !allSelected;

    return Row(
      children: [
        Text(
          'Permissions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: enabled
              ? () {
                  if (allSelected) {
                    onChanged([]);
                  } else {
                    onChanged(AppPermission.values.toList());
                  }
                }
              : null,
          icon: Icon(
            allSelected
                ? Icons.check_box
                : (someSelected ? Icons.indeterminate_check_box : Icons.check_box_outline_blank),
            size: 18,
          ),
          label: Text(allSelected ? 'Deselect All' : 'Select All'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionGroup(String group) {
    final groupPermissions = permissionsForGroup(group);
    if (groupPermissions.isEmpty) return const SizedBox.shrink();

    final allGroupSelected = groupPermissions.every((p) => selectedPermissions.contains(p));
    final someGroupSelected =
        groupPermissions.any((p) => selectedPermissions.contains(p)) && !allGroupSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          InkWell(
            onTap: enabled
                ? () {
                    final newPermissions = List<AppPermission>.from(selectedPermissions);
                    if (allGroupSelected) {
                      // Deselect all in group
                      for (final p in groupPermissions) {
                        newPermissions.remove(p);
                      }
                    } else {
                      // Select all in group
                      for (final p in groupPermissions) {
                        if (!newPermissions.contains(p)) {
                          newPermissions.add(p);
                        }
                      }
                    }
                    onChanged(newPermissions);
                  }
                : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Icon(
                    allGroupSelected
                        ? Icons.check_box
                        : (someGroupSelected ? Icons.indeterminate_check_box : Icons.check_box_outline_blank),
                    size: 20,
                    color: enabled
                        ? (allGroupSelected || someGroupSelected ? AppColors.primary : AppColors.textSecondary)
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    group,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${groupPermissions.where((p) => selectedPermissions.contains(p)).length}/${groupPermissions.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Permission checkboxes in a grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groupPermissions.map((permission) {
                final info = permissionInfo[permission]!;
                final isSelected = selectedPermissions.contains(permission);

                return _PermissionChip(
                  label: info.label,
                  isSelected: isSelected,
                  enabled: enabled,
                  onTap: () {
                    final newPermissions = List<AppPermission>.from(selectedPermissions);
                    if (isSelected) {
                      newPermissions.remove(permission);
                    } else {
                      newPermissions.add(permission);
                    }
                    onChanged(newPermissions);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual permission chip widget
class _PermissionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _PermissionChip({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: isSelected
                  ? AppColors.primary
                  : (enabled ? AppColors.textSecondary : AppColors.textSecondary.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : (enabled ? AppColors.textPrimary : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
