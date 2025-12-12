import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_settings.dart';
import '../../bloc/settings_bloc.dart';
import '../../bloc/settings_event.dart';
import '../../widgets/settings_section_card.dart';

/// About Us content section
class AboutUsSection extends StatefulWidget {
  final AppSettings settings;
  final bool isSaving;

  const AboutUsSection({
    super.key,
    required this.settings,
    required this.isSaving,
  });

  @override
  State<AboutUsSection> createState() => _AboutUsSectionState();
}

class _AboutUsSectionState extends State<AboutUsSection> {
  late TextEditingController _aboutUsController;

  @override
  void initState() {
    super.initState();
    _aboutUsController = TextEditingController(text: widget.settings.aboutUs);
  }

  @override
  void didUpdateWidget(AboutUsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.aboutUs != widget.settings.aboutUs) {
      _aboutUsController.text = widget.settings.aboutUs;
    }
  }

  @override
  void dispose() {
    _aboutUsController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    context.read<SettingsBloc>().add(
          UpdateAboutUsRequested(_aboutUsController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'About Us',
      subtitle: 'Content displayed in the About Us section of the app',
      icon: Icons.info_outline,
      footer: SettingsSaveButton(
        onPressed: _saveSettings,
        isLoading: widget.isSaving,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsTextField(
            label: 'About Us Content',
            hint: 'Enter information about your company, mission, and services...',
            controller: _aboutUsController,
            maxLines: 12,
            enabled: !widget.isSaving,
          ),
        ],
      ),
    );
  }
}
