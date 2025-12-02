import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonType { primary, secondary, outline, text, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton();
      case ButtonType.secondary:
        return _buildSecondaryButton();
      case ButtonType.outline:
        return _buildOutlineButton();
      case ButtonType.text:
        return _buildTextButton();
      case ButtonType.danger:
        return _buildDangerButton();
    }
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
      ),
      child: _buildChild(AppColors.textOnPrimary),
    );
  }

  Widget _buildSecondaryButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.6),
      ),
      child: _buildChild(AppColors.textOnPrimary),
    );
  }

  Widget _buildOutlineButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildDangerButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.error.withValues(alpha: 0.6),
      ),
      child: _buildChild(AppColors.textOnPrimary),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
