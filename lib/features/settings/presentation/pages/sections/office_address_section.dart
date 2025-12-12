import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_settings.dart';
import '../../bloc/settings_bloc.dart';
import '../../bloc/settings_event.dart';
import '../../widgets/settings_section_card.dart';

/// Office address and contact information section
class OfficeAddressSection extends StatefulWidget {
  final AppSettings settings;
  final bool isSaving;

  const OfficeAddressSection({
    super.key,
    required this.settings,
    required this.isSaving,
  });

  @override
  State<OfficeAddressSection> createState() => _OfficeAddressSectionState();
}

class _OfficeAddressSectionState extends State<OfficeAddressSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _faxController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.settings.officeAddress);
    _phoneController = TextEditingController(text: widget.settings.phone);
    _emailController = TextEditingController(text: widget.settings.email);
    _faxController = TextEditingController(text: widget.settings.fax);
  }

  @override
  void didUpdateWidget(OfficeAddressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.officeAddress != widget.settings.officeAddress) {
      _addressController.text = widget.settings.officeAddress;
    }
    if (oldWidget.settings.phone != widget.settings.phone) {
      _phoneController.text = widget.settings.phone;
    }
    if (oldWidget.settings.email != widget.settings.email) {
      _emailController.text = widget.settings.email;
    }
    if (oldWidget.settings.fax != widget.settings.fax) {
      _faxController.text = widget.settings.fax;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _faxController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(
            UpdateGeneralSettingsRequested(
              officeAddress: _addressController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              fax: _faxController.text.trim(),
            ),
          );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SettingsSectionCard(
        title: 'Office Address & Contact',
        subtitle: 'Manage your office location and contact information',
        icon: Icons.location_on,
        footer: SettingsSaveButton(
          onPressed: _saveSettings,
          isLoading: widget.isSaving,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTextField(
              label: 'Office Address',
              hint: 'Enter complete office address',
              controller: _addressController,
              maxLines: 3,
              enabled: !widget.isSaving,
              prefix: const Icon(Icons.business),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SettingsTextField(
                    label: 'Phone Number',
                    hint: '+91 XXXXX XXXXX',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !widget.isSaving,
                    prefix: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SettingsTextField(
                    label: 'Fax Number',
                    hint: '+91 XXXXX XXXXX',
                    controller: _faxController,
                    keyboardType: TextInputType.phone,
                    enabled: !widget.isSaving,
                    prefix: const Icon(Icons.fax),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsTextField(
              label: 'Email Address',
              hint: 'contact@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              enabled: !widget.isSaving,
              prefix: const Icon(Icons.email),
            ),
          ],
        ),
      ),
    );
  }
}
