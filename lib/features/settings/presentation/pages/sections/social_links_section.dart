import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/app_settings.dart';
import '../../bloc/settings_bloc.dart';
import '../../bloc/settings_event.dart';
import '../../widgets/settings_section_card.dart';

/// Social links settings section
class SocialLinksSection extends StatefulWidget {
  final AppSettings settings;
  final bool isSaving;

  const SocialLinksSection({
    super.key,
    required this.settings,
    required this.isSaving,
  });

  @override
  State<SocialLinksSection> createState() => _SocialLinksSectionState();
}

class _SocialLinksSectionState extends State<SocialLinksSection> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _facebookController;
  late TextEditingController _twitterController;
  late TextEditingController _instagramController;
  late TextEditingController _youtubeController;
  late TextEditingController _linkedinController;
  late TextEditingController _whatsappController;

  late bool _facebookEnabled;
  late bool _twitterEnabled;
  late bool _instagramEnabled;
  late bool _youtubeEnabled;
  late bool _linkedinEnabled;
  late bool _whatsappEnabled;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final links = widget.settings.socialLinks;
    _facebookController = TextEditingController(text: links.facebook);
    _twitterController = TextEditingController(text: links.twitter);
    _instagramController = TextEditingController(text: links.instagram);
    _youtubeController = TextEditingController(text: links.youtube);
    _linkedinController = TextEditingController(text: links.linkedin);
    _whatsappController = TextEditingController(text: links.whatsapp);

    _facebookEnabled = links.facebookEnabled;
    _twitterEnabled = links.twitterEnabled;
    _instagramEnabled = links.instagramEnabled;
    _youtubeEnabled = links.youtubeEnabled;
    _linkedinEnabled = links.linkedinEnabled;
    _whatsappEnabled = links.whatsappEnabled;
  }

  @override
  void didUpdateWidget(SocialLinksSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.socialLinks != widget.settings.socialLinks) {
      final links = widget.settings.socialLinks;
      _facebookController.text = links.facebook;
      _twitterController.text = links.twitter;
      _instagramController.text = links.instagram;
      _youtubeController.text = links.youtube;
      _linkedinController.text = links.linkedin;
      _whatsappController.text = links.whatsapp;

      setState(() {
        _facebookEnabled = links.facebookEnabled;
        _twitterEnabled = links.twitterEnabled;
        _instagramEnabled = links.instagramEnabled;
        _youtubeEnabled = links.youtubeEnabled;
        _linkedinEnabled = links.linkedinEnabled;
        _whatsappEnabled = links.whatsappEnabled;
      });
    }
  }

  @override
  void dispose() {
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _linkedinController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(
            UpdateSocialLinksRequested(
              SocialLinks(
                facebook: _facebookController.text.trim(),
                facebookEnabled: _facebookEnabled,
                twitter: _twitterController.text.trim(),
                twitterEnabled: _twitterEnabled,
                instagram: _instagramController.text.trim(),
                instagramEnabled: _instagramEnabled,
                youtube: _youtubeController.text.trim(),
                youtubeEnabled: _youtubeEnabled,
                linkedin: _linkedinController.text.trim(),
                linkedinEnabled: _linkedinEnabled,
                whatsapp: _whatsappController.text.trim(),
                whatsappEnabled: _whatsappEnabled,
              ),
            ),
          );
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SettingsSectionCard(
        title: 'Social Links',
        subtitle: 'Configure your social media presence',
        icon: Icons.share,
        footer: SettingsSaveButton(
          onPressed: _saveSettings,
          isLoading: widget.isSaving,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSocialLinkField(
              label: 'Facebook',
              controller: _facebookController,
              enabled: _facebookEnabled,
              onEnabledChanged: (v) => setState(() => _facebookEnabled = v),
              icon: Icons.facebook,
              color: const Color(0xFF1877F2),
            ),
            const SizedBox(height: 16),
            _buildSocialLinkField(
              label: 'Twitter / X',
              controller: _twitterController,
              enabled: _twitterEnabled,
              onEnabledChanged: (v) => setState(() => _twitterEnabled = v),
              icon: Icons.close,
              color: const Color(0xFF000000),
            ),
            const SizedBox(height: 16),
            _buildSocialLinkField(
              label: 'Instagram',
              controller: _instagramController,
              enabled: _instagramEnabled,
              onEnabledChanged: (v) => setState(() => _instagramEnabled = v),
              icon: Icons.camera_alt,
              color: const Color(0xFFE4405F),
            ),
            const SizedBox(height: 16),
            _buildSocialLinkField(
              label: 'YouTube',
              controller: _youtubeController,
              enabled: _youtubeEnabled,
              onEnabledChanged: (v) => setState(() => _youtubeEnabled = v),
              icon: Icons.play_circle_filled,
              color: const Color(0xFFFF0000),
            ),
            const SizedBox(height: 16),
            _buildSocialLinkField(
              label: 'LinkedIn',
              controller: _linkedinController,
              enabled: _linkedinEnabled,
              onEnabledChanged: (v) => setState(() => _linkedinEnabled = v),
              icon: Icons.work,
              color: const Color(0xFF0A66C2),
            ),
            const SizedBox(height: 16),
            _buildSocialLinkField(
              label: 'WhatsApp',
              controller: _whatsappController,
              enabled: _whatsappEnabled,
              onEnabledChanged: (v) => setState(() => _whatsappEnabled = v),
              icon: Icons.chat,
              color: const Color(0xFF25D366),
              hint: 'https://wa.me/919876543210',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinkField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required ValueChanged<bool> onEnabledChanged,
    required IconData icon,
    required Color color,
    String hint = 'https://...',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? color.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
              Switch(
                value: enabled,
                onChanged: widget.isSaving ? null : onEnabledChanged,
                activeTrackColor: color.withValues(alpha: 0.5),
                activeThumbColor: color,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              validator: _validateUrl,
              enabled: !widget.isSaving,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
