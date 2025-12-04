import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Modern action button styles
enum ActionButtonStyle {
  filled,
  outlined,
  icon,
}

/// Reusable Edit Button
class EditButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ActionButtonStyle style;
  final String? tooltip;
  final bool isLoading;
  final double? size;

  const EditButton({
    super.key,
    required this.onPressed,
    this.style = ActionButtonStyle.icon,
    this.tooltip = 'Edit',
    this.isLoading = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: size ?? 36,
        height: size ?? 36,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    switch (style) {
      case ActionButtonStyle.filled:
        return _FilledActionButton(
          onPressed: onPressed,
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: AppColors.primary,
          tooltip: tooltip,
        );
      case ActionButtonStyle.outlined:
        return _OutlinedActionButton(
          onPressed: onPressed,
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: AppColors.primary,
          tooltip: tooltip,
        );
      case ActionButtonStyle.icon:
        return _IconActionButton(
          onPressed: onPressed,
          icon: Icons.edit_outlined,
          color: AppColors.primary,
          hoverColor: AppColors.primary.withValues(alpha: 0.1),
          tooltip: tooltip,
          size: size,
        );
    }
  }
}

/// Reusable Delete Button
class DeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ActionButtonStyle style;
  final String? tooltip;
  final bool isLoading;
  final double? size;

  const DeleteButton({
    super.key,
    required this.onPressed,
    this.style = ActionButtonStyle.icon,
    this.tooltip = 'Delete',
    this.isLoading = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: size ?? 36,
        height: size ?? 36,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.error,
          ),
        ),
      );
    }

    switch (style) {
      case ActionButtonStyle.filled:
        return _FilledActionButton(
          onPressed: onPressed,
          icon: Icons.delete_outlined,
          label: 'Delete',
          color: AppColors.error,
          tooltip: tooltip,
        );
      case ActionButtonStyle.outlined:
        return _OutlinedActionButton(
          onPressed: onPressed,
          icon: Icons.delete_outlined,
          label: 'Delete',
          color: AppColors.error,
          tooltip: tooltip,
        );
      case ActionButtonStyle.icon:
        return _IconActionButton(
          onPressed: onPressed,
          icon: Icons.delete_outlined,
          color: AppColors.error,
          hoverColor: AppColors.error.withValues(alpha: 0.1),
          tooltip: tooltip,
          size: size,
        );
    }
  }
}

/// Reusable View Button
class ViewButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ActionButtonStyle style;
  final String? tooltip;
  final bool isLoading;
  final double? size;

  const ViewButton({
    super.key,
    required this.onPressed,
    this.style = ActionButtonStyle.icon,
    this.tooltip = 'View',
    this.isLoading = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: size ?? 36,
        height: size ?? 36,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    switch (style) {
      case ActionButtonStyle.filled:
        return _FilledActionButton(
          onPressed: onPressed,
          icon: Icons.visibility_outlined,
          label: 'View',
          color: AppColors.info,
          tooltip: tooltip,
        );
      case ActionButtonStyle.outlined:
        return _OutlinedActionButton(
          onPressed: onPressed,
          icon: Icons.visibility_outlined,
          label: 'View',
          color: AppColors.info,
          tooltip: tooltip,
        );
      case ActionButtonStyle.icon:
        return _IconActionButton(
          onPressed: onPressed,
          icon: Icons.visibility_outlined,
          color: AppColors.info,
          hoverColor: AppColors.info.withValues(alpha: 0.1),
          tooltip: tooltip,
          size: size,
        );
    }
  }
}

/// Action buttons row - combines multiple action buttons
class ActionButtonsRow extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLoading;
  final double spacing;

  const ActionButtonsRow({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null) ...[
          ViewButton(onPressed: isLoading ? null : onView),
          SizedBox(width: spacing),
        ],
        if (onEdit != null) ...[
          EditButton(onPressed: isLoading ? null : onEdit),
          SizedBox(width: spacing),
        ],
        if (onDelete != null)
          DeleteButton(onPressed: isLoading ? null : onDelete),
      ],
    );
  }
}

// ============ Private Widget Components ============

class _IconActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final Color hoverColor;
  final String? tooltip;
  final double? size;

  const _IconActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.hoverColor,
    this.tooltip,
    this.size,
  });

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.size ?? 36.0;
    final iconSize = buttonSize * 0.55;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: _isHovered && widget.onPressed != null
                  ? widget.hoverColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered && widget.onPressed != null
                    ? widget.color.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: iconSize,
                color: widget.onPressed != null
                    ? widget.color
                    : widget.color.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final String? tooltip;

  const _FilledActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final String? tooltip;

  const _OutlinedActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
