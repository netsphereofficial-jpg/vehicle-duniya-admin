import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/suggestion.dart';
import '../bloc/suggestion_bloc.dart';
import '../bloc/suggestion_event.dart';
import '../bloc/suggestion_state.dart';

/// Dialog to view and manage suggestion details
class SuggestionDetailDialog extends StatefulWidget {
  final Suggestion suggestion;

  const SuggestionDetailDialog({super.key, required this.suggestion});

  /// Show the dialog
  static Future<void> show(BuildContext context, Suggestion suggestion) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SuggestionBloc>(),
        child: SuggestionDetailDialog(suggestion: suggestion),
      ),
    );
  }

  @override
  State<SuggestionDetailDialog> createState() => _SuggestionDetailDialogState();
}

class _SuggestionDetailDialogState extends State<SuggestionDetailDialog> {
  late TextEditingController _notesController;
  SuggestionStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.suggestion.adminNotes ?? '');
    _selectedStatus = widget.suggestion.status;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleUpdateStatus() {
    if (_selectedStatus == null) return;

    context.read<SuggestionBloc>().add(UpdateSuggestionStatusRequested(
          suggestionId: widget.suggestion.id,
          status: _selectedStatus!,
          adminNotes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuggestionBloc, SuggestionState>(
      listener: (context, state) {
        if (state.hasSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(),
                      const SizedBox(height: 20),
                      _buildMessageSection(),
                      const SizedBox(height: 20),
                      _buildStatusSection(),
                      const SizedBox(height: 20),
                      _buildNotesSection(),
                      const SizedBox(height: 16),
                      _buildTimestamps(),
                    ],
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final suggestion = widget.suggestion;
    final typeColor = _getTypeColor(suggestion.type);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [typeColor.withValues(alpha: 0.1), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(suggestion.type),
              color: typeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        suggestion.type.label,
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: suggestion.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  suggestion.subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final suggestion = widget.suggestion;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'User Information',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Full Name',
                  value: suggestion.fullName,
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoItem(
                  label: 'Username',
                  value: '@${suggestion.userName}',
                  icon: Icons.alternate_email,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Phone',
                  value: suggestion.formattedPhone,
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoItem(
                  label: 'Email',
                  value: suggestion.email ?? 'Not provided',
                  icon: Icons.email_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.message_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Message',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            widget.suggestion.message,
            style: TextStyle(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.track_changes, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Update Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SuggestionStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            final color = _getStatusColor(status);

            return InkWell(
              onTap: () => setState(() => _selectedStatus = status),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 16,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.label,
                      style: TextStyle(
                        color: isSelected ? color : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.note_alt_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Admin Notes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add notes about this suggestion/complaint...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamps() {
    final suggestion = widget.suggestion;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TimestampItem(
            label: 'Created',
            value: dateFormat.format(suggestion.createdAt),
            icon: Icons.add_circle_outline,
          ),
          if (suggestion.resolvedAt != null)
            _TimestampItem(
              label: 'Resolved',
              value: dateFormat.format(suggestion.resolvedAt!),
              icon: Icons.check_circle_outline,
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return BlocBuilder<SuggestionBloc, SuggestionState>(
      builder: (context, state) {
        final isUpdating = state.isUpdating;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              if (state.hasError)
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage ?? 'An error occurred',
                            style:
                                TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!state.hasError) const Spacer(),
              const SizedBox(width: 12),
              TextButton(
                onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isUpdating ? null : _handleUpdateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Update'),
              ),
            ],
          ),
        );
      },
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
        return Icons.feedback_outlined;
    }
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

  IconData _getStatusIcon(SuggestionStatus status) {
    switch (status) {
      case SuggestionStatus.pending:
        return Icons.schedule;
      case SuggestionStatus.inProgress:
        return Icons.autorenew;
      case SuggestionStatus.resolved:
        return Icons.check_circle_outline;
      case SuggestionStatus.closed:
        return Icons.cancel_outlined;
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 12,
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

/// Info item widget
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Timestamp item widget
class _TimestampItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TimestampItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
