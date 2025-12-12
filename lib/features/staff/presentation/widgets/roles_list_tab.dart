import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/staff_role.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'role_form_dialog.dart';

/// Tab widget for displaying roles list
class RolesListTab extends StatelessWidget {
  const RolesListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        return ModernDataTable<StaffRole>(
          data: state.roles,
          isLoading: state.status == StaffStatus.loading,
          emptyMessage: 'No roles found',
          emptyIcon: Icons.security_outlined,
          searchHint: 'Search by role name...',
          searchableText: (role) => role.name,
          columns: [
            TableColumnDef(
              header: '#',
              width: 60,
              cellBuilder: (item, index) => Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TableColumnDef(
              header: 'Role Name',
              flex: 1,
              cellBuilder: (item, index) => _RoleNameCell(role: item),
            ),
            TableColumnDef(
              header: 'Permissions',
              flex: 2,
              cellBuilder: (item, index) => _PermissionsCell(role: item),
            ),
            TableColumnDef(
              header: 'Staff',
              width: 80,
              align: TextAlign.center,
              cellBuilder: (item, index) {
                final count = state.countStaffWithRole(item.id);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: count > 0
                        ? AppColors.info.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: count > 0 ? AppColors.info : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
            TableColumnDef(
              header: 'Created',
              width: 120,
              cellBuilder: (item, index) => Text(
                DateFormat('dd MMM yyyy').format(item.createdAt),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            TableColumnDef(
              header: 'Actions',
              width: 80,
              align: TextAlign.center,
              cellBuilder: (item, index) => _ActionButtons(
                role: item,
                staffCount: state.countStaffWithRole(item.id),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Role name cell with icon
class _RoleNameCell extends StatelessWidget {
  final StaffRole role;

  const _RoleNameCell({required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                role.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (role.isSystemRole)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'System Role',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Permissions cell - clickable to show all permissions
class _PermissionsCell extends StatelessWidget {
  final StaffRole role;

  const _PermissionsCell({required this.role});

  @override
  Widget build(BuildContext context) {
    // Group permissions by category
    final groups = <String, int>{};
    for (final permission in role.permissions) {
      final info = permissionInfo[permission];
      if (info != null) {
        groups[info.group] = (groups[info.group] ?? 0) + 1;
      }
    }

    if (groups.isEmpty) {
      return Text(
        'No permissions',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Take first 3 groups
    final displayGroups = groups.entries.take(3).toList();
    final remainingCount = groups.length - 3;

    return InkWell(
      onTap: () => _showPermissionsDialog(context, role),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ...displayGroups.map((entry) => _PermissionBadge(
                        label: entry.key,
                        count: entry.value,
                      )),
                  if (remainingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+$remainingCount more',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Always show view icon
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.visibility_outlined,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, StaffRole role) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 550,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.security, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${role.permissions.length} permissions',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: permissionGroupOrder.map((group) {
                      final groupPerms = role.permissions
                          .where((p) => permissionInfo[p]?.group == group)
                          .toList();
                      if (groupPerms.isEmpty) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                border: Border(bottom: BorderSide(color: AppColors.border)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    group,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${groupPerms.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Permissions
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: groupPerms.map((p) {
                                  final info = permissionInfo[p]!;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.success.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          info.label,
                                          style: TextStyle(
                                            color: AppColors.success,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Permission badge widget
class _PermissionBadge extends StatelessWidget {
  final String label;
  final int count;

  const _PermissionBadge({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons for role row
class _ActionButtons extends StatelessWidget {
  final StaffRole role;
  final int staffCount;

  const _ActionButtons({
    required this.role,
    required this.staffCount,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      tooltip: 'Actions',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          enabled: !role.isSystemRole,
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: role.isSystemRole ? AppColors.textLight : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(
                  color: role.isSystemRole ? AppColors.textLight : null,
                ),
              ),
            ],
          ),
        ),
        if (!role.isSystemRole) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            enabled: staffCount == 0,
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: staffCount == 0 ? AppColors.error : AppColors.textLight,
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: staffCount == 0 ? AppColors.error : AppColors.textLight,
                  ),
                ),
                if (staffCount > 0) ...[
                  const Spacer(),
                  Tooltip(
                    message: '$staffCount staff assigned',
                    child: Icon(Icons.info_outline, size: 14, color: AppColors.textLight),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            if (!role.isSystemRole) {
              RoleFormDialog.show(context, role: role);
            }
            break;
          case 'delete':
            if (staffCount == 0 && !role.isSystemRole) {
              _showDeleteDialog(context, role);
            }
            break;
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context, StaffRole role) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Delete Role'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the role "${role.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<StaffBloc>().add(DeleteRoleRequested(role.id));
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
