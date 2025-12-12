import 'package:equatable/equatable.dart';

import '../../domain/entities/referral_download.dart';
import '../../domain/entities/referral_link.dart';

/// Base class for referral events
abstract class ReferralEvent extends Equatable {
  const ReferralEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load referral data
class ReferralDataRequested extends ReferralEvent {
  const ReferralDataRequested();
}

/// Referral links stream updated
class ReferralLinksStreamUpdated extends ReferralEvent {
  final List<ReferralLink> links;

  const ReferralLinksStreamUpdated(this.links);

  @override
  List<Object?> get props => [links];
}

/// Request to create a new referral link
class CreateReferralLinkRequested extends ReferralEvent {
  final String name;
  final String mobile;

  const CreateReferralLinkRequested({
    required this.name,
    required this.mobile,
  });

  @override
  List<Object?> get props => [name, mobile];
}

/// Request to toggle link status
class ToggleLinkStatusRequested extends ReferralEvent {
  final String linkId;
  final bool isActive;

  const ToggleLinkStatusRequested({
    required this.linkId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [linkId, isActive];
}

/// Request to delete a referral link
class DeleteReferralLinkRequested extends ReferralEvent {
  final String linkId;

  const DeleteReferralLinkRequested(this.linkId);

  @override
  List<Object?> get props => [linkId];
}

/// Request to load downloads for a specific link
class LoadDownloadsRequested extends ReferralEvent {
  final String linkId;

  const LoadDownloadsRequested(this.linkId);

  @override
  List<Object?> get props => [linkId];
}

/// Downloads stream updated
class DownloadsStreamUpdated extends ReferralEvent {
  final List<ReferralDownload> downloads;

  const DownloadsStreamUpdated(this.downloads);

  @override
  List<Object?> get props => [downloads];
}

/// Close downloads view
class CloseDownloadsView extends ReferralEvent {
  const CloseDownloadsView();
}

/// Change analytics time period
class ChangeAnalyticsPeriodRequested extends ReferralEvent {
  final int days;

  const ChangeAnalyticsPeriodRequested(this.days);

  @override
  List<Object?> get props => [days];
}

/// Refresh analytics data
class RefreshAnalyticsRequested extends ReferralEvent {
  const RefreshAnalyticsRequested();
}

/// Clear messages
class ClearReferralMessage extends ReferralEvent {
  const ClearReferralMessage();
}

/// Filter links by status
class FilterByActiveStatusRequested extends ReferralEvent {
  final bool? isActive;

  const FilterByActiveStatusRequested(this.isActive);

  @override
  List<Object?> get props => [isActive];
}
