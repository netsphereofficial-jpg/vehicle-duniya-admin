import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_settings.dart';
import '../../bloc/settings_bloc.dart';
import '../../bloc/settings_event.dart';
import '../../widgets/settings_section_card.dart';

/// App version settings section
class AppVersionSection extends StatefulWidget {
  final AppSettings settings;
  final bool isSaving;

  const AppVersionSection({
    super.key,
    required this.settings,
    required this.isSaving,
  });

  @override
  State<AppVersionSection> createState() => _AppVersionSectionState();
}

class _AppVersionSectionState extends State<AppVersionSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _appVersionController;
  late TextEditingController _minVersionController;
  late bool _forceUpdate;

  @override
  void initState() {
    super.initState();
    _appVersionController = TextEditingController(text: widget.settings.appVersion);
    _minVersionController = TextEditingController(text: widget.settings.minAppVersion);
    _forceUpdate = widget.settings.forceUpdate;
  }

  @override
  void didUpdateWidget(AppVersionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.appVersion != widget.settings.appVersion) {
      _appVersionController.text = widget.settings.appVersion;
    }
    if (oldWidget.settings.minAppVersion != widget.settings.minAppVersion) {
      _minVersionController.text = widget.settings.minAppVersion;
    }
    if (oldWidget.settings.forceUpdate != widget.settings.forceUpdate) {
      _forceUpdate = widget.settings.forceUpdate;
    }
  }

  @override
  void dispose() {
    _appVersionController.dispose();
    _minVersionController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(
            UpdateAppVersionRequested(
              appVersion: _appVersionController.text.trim(),
              minAppVersion: _minVersionController.text.trim(),
              forceUpdate: _forceUpdate,
            ),
          );
    }
  }

  String? _validateVersion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Version is required';
    }
    // Basic version format validation (x.y.z)
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
    if (!versionRegex.hasMatch(value.trim())) {
      return 'Use format: x.y.z (e.g., 1.0.0)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SettingsSectionCard(
        title: 'App Version Settings',
        subtitle: 'Manage app version and force update settings',
        icon: Icons.system_update,
        footer: SettingsSaveButton(
          onPressed: _saveSettings,
          isLoading: widget.isSaving,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTextField(
              label: 'Current App Version',
              hint: 'e.g., 1.0.0',
              controller: _appVersionController,
              validator: _validateVersion,
              enabled: !widget.isSaving,
              prefix: const Icon(Icons.tag),
            ),
            const SizedBox(height: 16),
            SettingsTextField(
              label: 'Minimum Required Version',
              hint: 'e.g., 1.0.0',
              controller: _minVersionController,
              validator: _validateVersion,
              enabled: !widget.isSaving,
              prefix: const Icon(Icons.low_priority),
            ),
            const SizedBox(height: 16),
            SettingsSwitchTile(
              title: 'Force Update',
              subtitle: 'Users must update to minimum version to use the app',
              value: _forceUpdate,
              onChanged: (value) {
                setState(() => _forceUpdate = value);
              },
              enabled: !widget.isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
