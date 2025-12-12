import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../domain/entities/suggestion.dart';
import '../bloc/suggestion_bloc.dart';
import '../bloc/suggestion_event.dart';
import '../bloc/suggestion_state.dart';
import '../widgets/suggestion_detail_dialog.dart';

/// Main page for suggestion box management
class SuggestionBoxPage extends StatefulWidget {
  const SuggestionBoxPage({super.key});

  @override
  State<SuggestionBoxPage> createState() => _SuggestionBoxPageState();
}

class _SuggestionBoxPageState extends State<SuggestionBoxPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuggestionBloc>().add(const SuggestionDataRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuggestionBloc, SuggestionState>(
      listener: (context, state) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<SuggestionBloc>().add(const ClearSuggestionMessage());
        }

        if (state.hasError && state.status != SuggestionLoadStatus.updating) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<SuggestionBloc>().add(const ClearSuggestionMessage());
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
              _buildStatsCards(),
              const SizedBox(height: 24),
              Expanded(child: _buildContentCard()),
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
              colors: [AppColors.primary, AppColors.primaryLight],
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
            Icons.feedback_outlined,
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
                'Suggestion Box',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage user suggestions, complaints, and feedback',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<SuggestionBloc, SuggestionState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pending',
                count: state.pendingCount,
                icon: Icons.schedule,
                color: AppColors.warning,
                isSelected: state.filterStatus == SuggestionStatus.pending,
                onTap: () {
                  context.read<SuggestionBloc>().add(FilterByStatusRequested(
                        state.filterStatus == SuggestionStatus.pending
                            ? null
                            : SuggestionStatus.pending,
                      ));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'In Progress',
                count: state.inProgressCount,
                icon: Icons.autorenew,
                color: AppColors.info,
                isSelected: state.filterStatus == SuggestionStatus.inProgress,
                onTap: () {
                  context.read<SuggestionBloc>().add(FilterByStatusRequested(
                        state.filterStatus == SuggestionStatus.inProgress
                            ? null
                            : SuggestionStatus.inProgress,
                      ));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'Resolved',
                count: state.resolvedCount,
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                isSelected: state.filterStatus == SuggestionStatus.resolved,
                onTap: () {
                  context.read<SuggestionBloc>().add(FilterByStatusRequested(
                        state.filterStatus == SuggestionStatus.resolved
                            ? null
                            : SuggestionStatus.resolved,
                      ));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'Closed',
                count: state.closedCount,
                icon: Icons.cancel_outlined,
                color: AppColors.textSecondary,
                isSelected: state.filterStatus == SuggestionStatus.closed,
                onTap: () {
                  context.read<SuggestionBloc>().add(FilterByStatusRequested(
                        state.filterStatus == SuggestionStatus.closed
                            ? null
                            : SuggestionStatus.closed,
                      ));
                },
              ),
            ),
          ],
        );
      },
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
      child: BlocBuilder<SuggestionBloc, SuggestionState>(
        builder: (context, state) {
          return ModernDataTable<Suggestion>(
            data: state.filteredSuggestions,
            isLoading: state.isLoading,
            emptyMessage: state.filterStatus != null
                ? 'No ${state.filterStatus!.label.toLowerCase()} suggestions'
                : 'No suggestions found',
            emptyIcon: Icons.inbox_outlined,
            searchHint: 'Search by name, username, or subject...',
            searchableText: (item) =>
                '${item.fullName} ${item.userName} ${item.subject} ${item.message}',
            onRowTap: (item) => SuggestionDetailDialog.show(context, item),
            headerActions: _buildTypeFilter(state),
            columns: [
              TableColumnDef(
                header: '#',
                width: 50,
                cellBuilder: (item, index) => Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TableColumnDef(
                header: 'Type',
                width: 100,
                cellBuilder: (item, index) => _TypeBadge(type: item.type),
              ),
              TableColumnDef(
                header: 'User',
                flex: 1.5,
                cellBuilder: (item, index) => _UserCell(suggestion: item),
              ),
              TableColumnDef(
                header: 'Subject',
                flex: 2,
                cellBuilder: (item, index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.subject,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.message,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TableColumnDef(
                header: 'Status',
                width: 120,
                align: TextAlign.center,
                cellBuilder: (item, index) => _StatusBadge(status: item.status),
              ),
              TableColumnDef(
                header: 'Date',
                width: 110,
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
                cellBuilder: (item, index) => _ActionButtons(suggestion: item),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeFilter(SuggestionState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Type: ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        ...SuggestionType.values.map((type) {
          final isSelected = state.filterType == type;
          final color = _getTypeColor(type);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                context.read<SuggestionBloc>().add(FilterByTypeRequested(
                      isSelected ? null : type,
                    ));
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                  ),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
        if (state.filterType != null || state.filterStatus != null)
          TextButton.icon(
            onPressed: () {
              context
                  .read<SuggestionBloc>()
                  .add(const FilterByTypeRequested(null));
              context
                  .read<SuggestionBloc>()
                  .add(const FilterByStatusRequested(null));
            },
            icon: Icon(Icons.clear, size: 16, color: AppColors.error),
            label: Text(
              'Clear',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Color _getTypeColor(SuggestionType type) {
    switch (type) {
      case SuggestionType.suggestion:
        return AppColors.info;
      case SuggestionType.complaint:
        return AppColors.error;
      case SuggestionType.feedback:
        return AppColors.success;
    }
  }
}

/// Stats card widget
class _StatCard extends StatefulWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? widget.color
                  : (_isHovered ? widget.color.withValues(alpha: 0.5) : AppColors.border),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: _isHovered || widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.count}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
                Icon(
                  Icons.filter_list,
                  color: widget.color,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Type badge widget
class _TypeBadge extends StatelessWidget {
  final SuggestionType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(type);
    final icon = _getTypeIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(SuggestionType type) {
    switch (type) {
      case SuggestionType.suggestion:
        return AppColors.info;
      case SuggestionType.complaint:
        return AppColors.error;
      case SuggestionType.feedback:
        return AppColors.success;
    }
  }

  IconData _getTypeIcon(SuggestionType type) {
    switch (type) {
      case SuggestionType.suggestion:
        return Icons.lightbulb_outline;
      case SuggestionType.complaint:
        return Icons.report_problem_outlined;
      case SuggestionType.feedback:
        return Icons.thumb_up_outlined;
    }
  }
}

/// User cell widget
class _UserCell extends StatelessWidget {
  final Suggestion suggestion;

  const _UserCell({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            suggestion.fullName.isNotEmpty
                ? suggestion.fullName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                suggestion.fullName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '@${suggestion.userName}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
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

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final SuggestionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SuggestionStatus status) {
    switch (status) {
      case SuggestionStatus.pending:
        return AppColors.warning;
      case SuggestionStatus.inProgress:
        return AppColors.info;
      case SuggestionStatus.resolved:
        return AppColors.success;
      case SuggestionStatus.closed:
        return AppColors.textSecondary;
    }
  }
}

/// Action buttons widget
class _ActionButtons extends StatelessWidget {
  final Suggestion suggestion;

  const _ActionButtons({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      tooltip: 'Actions',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('View Details'),
            ],
          ),
        ),
        if (suggestion.isOpen) ...[
          PopupMenuItem(
            value: 'progress',
            child: Row(
              children: [
                Icon(Icons.autorenew, size: 18, color: AppColors.info),
                const SizedBox(width: 12),
                const Text('Mark In Progress'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'resolve',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 18, color: AppColors.success),
                const SizedBox(width: 12),
                const Text('Mark Resolved'),
              ],
            ),
          ),
        ],
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
          case 'view':
            SuggestionDetailDialog.show(context, suggestion);
            break;
          case 'progress':
            context.read<SuggestionBloc>().add(UpdateSuggestionStatusRequested(
                  suggestionId: suggestion.id,
                  status: SuggestionStatus.inProgress,
                ));
            break;
          case 'resolve':
            context.read<SuggestionBloc>().add(UpdateSuggestionStatusRequested(
                  suggestionId: suggestion.id,
                  status: SuggestionStatus.resolved,
                ));
            break;
          case 'delete':
            _showDeleteDialog(context, suggestion);
            break;
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Suggestion suggestion) {
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
            const Text('Delete Suggestion'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this ${suggestion.type.label.toLowerCase()} from "${suggestion.fullName}"?\n\n'
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
              context
                  .read<SuggestionBloc>()
                  .add(DeleteSuggestionRequested(suggestion.id));
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
