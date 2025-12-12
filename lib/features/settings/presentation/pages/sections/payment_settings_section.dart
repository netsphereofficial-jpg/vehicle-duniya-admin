import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/services/local_image_cache.dart';
import '../../../domain/entities/app_settings.dart';
import '../../bloc/settings_bloc.dart';
import '../../bloc/settings_event.dart';
import '../../widgets/settings_section_card.dart';

/// Payment settings section for QR code upload and payment page toggle
class PaymentSettingsSection extends StatefulWidget {
  final AppSettings settings;
  final bool isSaving;

  const PaymentSettingsSection({
    super.key,
    required this.settings,
    required this.isSaving,
  });

  @override
  State<PaymentSettingsSection> createState() => _PaymentSettingsSectionState();
}

class _PaymentSettingsSectionState extends State<PaymentSettingsSection> {
  late bool _paymentEnabled;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  final LocalImageCache _imageCache = sl<LocalImageCache>();

  @override
  void initState() {
    super.initState();
    _paymentEnabled = widget.settings.paymentPageEnabled;
  }

  @override
  void didUpdateWidget(PaymentSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.paymentPageEnabled != widget.settings.paymentPageEnabled) {
      _paymentEnabled = widget.settings.paymentPageEnabled;
    }
  }

  /// Get cached QR code image
  Uint8List? get _cachedQrCode => _imageCache.getCachedImage(LocalImageCache.paymentQrCodeKey);

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = Uint8List.fromList(file.bytes!);
        });
      }
    }
  }

  void _saveSettings() {
    if (_selectedFileBytes != null && _selectedFileName != null) {
      // Cache the image locally before uploading
      _imageCache.cacheImage(LocalImageCache.paymentQrCodeKey, _selectedFileBytes!);

      context.read<SettingsBloc>().add(
            UploadPaymentQrCodeRequested(
              imageBytes: _selectedFileBytes!,
              fileName: _selectedFileName!,
              paymentPageEnabled: _paymentEnabled,
            ),
          );
      setState(() {
        _selectedFileName = null;
        _selectedFileBytes = null;
      });
    } else {
      context.read<SettingsBloc>().add(
            UpdatePaymentSettingsRequested(
              paymentPageEnabled: _paymentEnabled,
              paymentQrCodeUrl: widget.settings.paymentQrCodeUrl,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Payment Page Settings',
      subtitle: 'Configure payment QR code visible on the app',
      icon: Icons.qr_code_2,
      footer: SettingsSaveButton(
        onPressed: _saveSettings,
        isLoading: widget.isSaving,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSwitchTile(
            title: 'Enable Payment Page',
            subtitle: 'Show payment QR code to users in the app',
            value: _paymentEnabled,
            onChanged: (value) {
              setState(() => _paymentEnabled = value);
            },
            enabled: !widget.isSaving,
          ),
          const SizedBox(height: 20),
          Text(
            'Payment QR Code',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildQrCodeUploader(),
        ],
      ),
    );
  }

  Widget _buildQrCodeUploader() {
    final cachedImage = _cachedQrCode;
    final hasExistingImage = widget.settings.paymentQrCodeUrl.isNotEmpty || cachedImage != null;
    final hasNewImage = _selectedFileBytes != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Image preview
          if (hasExistingImage || hasNewImage) ...[
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImagePreview(hasNewImage, cachedImage),
              ),
            ),
            const SizedBox(height: 12),
            if (hasNewImage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.info),
                    const SizedBox(width: 6),
                    Text(
                      'New image selected: $_selectedFileName',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
          // Upload button
          InkWell(
            onTap: widget.isSaving ? null : _pickImage,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: Column(
                children: [
                  Icon(
                    hasExistingImage || hasNewImage
                        ? Icons.change_circle_outlined
                        : Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasExistingImage || hasNewImage
                        ? 'Click to change QR code'
                        : 'Click to upload QR code',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG up to 5MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build image preview - prioritize: new selection > cached > network
  Widget _buildImagePreview(bool hasNewImage, Uint8List? cachedImage) {
    // 1. Show newly selected image
    if (hasNewImage) {
      return Image.memory(
        _selectedFileBytes!,
        fit: BoxFit.contain,
      );
    }

    // 2. Show cached image (avoids CORS issues)
    if (cachedImage != null) {
      return Image.memory(
        cachedImage,
        fit: BoxFit.contain,
      );
    }

    // 3. Fallback to network image (may fail due to CORS)
    return Image.network(
      widget.settings.paymentQrCodeUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stack) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'Image saved to Firebase',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '(CORS restricted)',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
