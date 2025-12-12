import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_settings.dart';
import '../../bloc/settings_bloc.dart';
import '../../bloc/settings_event.dart';
import '../../widgets/settings_section_card.dart';

/// Bidding terms and conditions section
class BiddingTermsSection extends StatefulWidget {
  final AppSettings settings;
  final bool isSaving;

  const BiddingTermsSection({
    super.key,
    required this.settings,
    required this.isSaving,
  });

  @override
  State<BiddingTermsSection> createState() => _BiddingTermsSectionState();
}

class _BiddingTermsSectionState extends State<BiddingTermsSection> {
  late TextEditingController _biddingTermsController;

  @override
  void initState() {
    super.initState();
    _biddingTermsController = TextEditingController(text: widget.settings.biddingTerms);
  }

  @override
  void didUpdateWidget(BiddingTermsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.biddingTerms != widget.settings.biddingTerms) {
      _biddingTermsController.text = widget.settings.biddingTerms;
    }
  }

  @override
  void dispose() {
    _biddingTermsController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    context.read<SettingsBloc>().add(
          UpdateBiddingTermsRequested(_biddingTermsController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Bidding Terms & Conditions',
      subtitle: 'Terms shown to users before placing bids',
      icon: Icons.gavel,
      footer: SettingsSaveButton(
        onPressed: _saveSettings,
        isLoading: widget.isSaving,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsTextField(
            label: 'Terms & Conditions',
            hint: 'Enter the bidding terms and conditions...',
            controller: _biddingTermsController,
            maxLines: 12,
            enabled: !widget.isSaving,
          ),
        ],
      ),
    );
  }
}
