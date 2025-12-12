import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/role_form_dialog.dart';
import '../widgets/roles_list_tab.dart';
import '../widgets/staff_form_dialog.dart';
import '../widgets/staff_list_tab.dart';

/// Main page for staff and role management
class StaffManagementPage extends StatefulWidget {
  final int initialTab;

  const StaffManagementPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Load data when page opens
    context.read<StaffBloc>().add(const StaffDataRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffBloc, StaffState>(
      listener: (context, state) {
        // Show success message
        if (state.hasSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(state.successMessage!),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<StaffBloc>().add(const ClearStaffMessage());
        }

        // Show error message
        if (state.hasError && state.status != StaffStatus.saving) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<StaffBloc>().add(const ClearStaffMessage());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: _buildContentCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage staff members and their access roles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        _AddButton(
          isRolesTab: _tabController.index == 1,
          onPressed: () {
            if (_tabController.index == 1) {
              RoleFormDialog.show(context);
            } else {
              StaffFormDialog.show(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildContentCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildModernTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                StaffListTab(),
                RolesListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              _ModernTab(
                icon: Icons.badge_outlined,
                activeIcon: Icons.badge,
                label: 'Staff Members',
                count: state.staffMembers.length,
                isSelected: _tabController.index == 0,
                onTap: () => _tabController.animateTo(0),
              ),
              _ModernTab(
                icon: Icons.security_outlined,
                activeIcon: Icons.security,
                label: 'Roles',
                count: state.roles.length,
                isSelected: _tabController.index == 1,
                onTap: () => _tabController.animateTo(1),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

/// Modern tab widget
class _ModernTab extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ModernTab> createState() => _ModernTabState();
}

class _ModernTabState extends State<_ModernTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : (_isHovered ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent),
            border: Border(
              bottom: BorderSide(
                color: widget.isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                size: 20,
                color: widget.isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        )
                      : null,
                  color: widget.isSelected ? null : AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add button with gradient and hover effect
class _AddButton extends StatefulWidget {
  final bool isRolesTab;
  final VoidCallback onPressed;

  const _AddButton({
    required this.isRolesTab,
    required this.onPressed,
  });

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      widget.isRolesTab ? 'Add Role' : 'Add Staff',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
