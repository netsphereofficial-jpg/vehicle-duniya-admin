import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/staff_member.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'staff_form_dialog.dart';

/// Tab widget for displaying staff members list
class StaffListTab extends StatelessWidget {
  const StaffListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        return ModernDataTable<StaffMember>(
          data: state.staffMembers,
          isLoading: state.status == StaffStatus.loading,
          emptyMessage: 'No staff members found',
          emptyIcon: Icons.people_outline,
          searchHint: 'Search by name, email, or username...',
          searchableText: (staff) =>
              '${staff.name} ${staff.email} ${staff.username} ${staff.roleName}',
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
              header: 'Staff Member',
              flex: 1.5,
              cellBuilder: (item, index) => _StaffInfoCell(staff: item),
            ),
            TableColumnDef(
              header: 'Contact',
              flex: 2,
              cellBuilder: (item, index) => _ContactCell(staff: item),
            ),
            TableColumnDef(
              header: 'Role',
              flex: 1,
              cellBuilder: (item, index) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.roleName,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            TableColumnDef(
              header: 'Status',
              width: 100,
              align: TextAlign.center,
              cellBuilder: (item, index) => _StatusBadge(isActive: item.isActive),
            ),
            TableColumnDef(
              header: 'Last Login',
              flex: 1,
              cellBuilder: (item, index) => Text(
                item.lastLoginAt != null
                    ? DateFormat('dd MMM, HH:mm').format(item.lastLoginAt!)
                    : 'Never',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            TableColumnDef(
              header: 'Actions',
              width: 100,
              align: TextAlign.center,
              cellBuilder: (item, index) => _ActionButtons(staff: item),
            ),
          ],
        );
      },
    );
  }
}

/// Staff info cell with avatar and details
class _StaffInfoCell extends StatelessWidget {
  final StaffMember staff;

  const _StaffInfoCell({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                staff.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '@${staff.username}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Contact cell with email and phone
class _ContactCell extends StatelessWidget {
  final StaffMember staff;

  const _ContactCell({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                staff.email,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              staff.formattedPhone,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons for staff row
class _ActionButtons extends StatelessWidget {
  final StaffMember staff;

  const _ActionButtons({required this.staff});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      tooltip: 'Actions',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                staff.isActive ? Icons.block : Icons.check_circle_outline,
                size: 18,
                color: staff.isActive ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: 12),
              Text(staff.isActive ? 'Deactivate' : 'Activate'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              const SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            StaffFormDialog.show(context, staff: staff);
            break;
          case 'toggle':
            context.read<StaffBloc>().add(ToggleStaffStatusRequested(
                  staffId: staff.id,
                  isActive: !staff.isActive,
                ));
            break;
          case 'delete':
            _showDeleteDialog(context, staff);
            break;
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context, StaffMember staff) {
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
            const Text('Delete Staff Member'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${staff.name}"?\n\n'
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
              context.read<StaffBloc>().add(DeleteStaffMemberRequested(staff.id));
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
