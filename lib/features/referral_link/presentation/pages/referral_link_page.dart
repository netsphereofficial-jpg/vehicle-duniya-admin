import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';
import '../widgets/download_details_sheet.dart';
import '../widgets/referral_charts.dart';
import '../widgets/referral_form_dialog.dart';
import '../widgets/referral_link_table.dart';
import '../widgets/referral_stats_cards.dart';

/// Main page for referral code management
class ReferralLinkPage extends StatefulWidget {
  const ReferralLinkPage({super.key});

  @override
  State<ReferralLinkPage> createState() => _ReferralLinkPageState();
}

class _ReferralLinkPageState extends State<ReferralLinkPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReferralBloc>().add(const ReferralDataRequested());
  }

  void _showCreateDialog() {
    final bloc = context.read<ReferralBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<ReferralBloc, ReferralState>(
          builder: (context, state) {
            return ReferralFormDialog(
              isLoading: state.isCreating,
              createdLink: state.createdLink,
              onSubmit: (name, mobile) {
                context.read<ReferralBloc>().add(
                      CreateReferralLinkRequested(
                        name: name,
                        mobile: mobile,
                      ),
                    );
              },
            );
          },
        ),
      ),
    ).then((_) {
      bloc.add(const ClearReferralMessage());
    });
  }

  void _showDownloadsSheet(BuildContext context, ReferralState state) {
    final link = state.selectedLink;
    if (link == null) return;

    final bloc = context.read<ReferralBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<ReferralBloc, ReferralState>(
          builder: (context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (_, controller) {
                return DownloadDetailsSheet(
                  link: link,
                  downloads: state.selectedLinkDownloads,
                  onClose: () {
                    Navigator.pop(context);
                    context.read<ReferralBloc>().add(const CloseDownloadsView());
                  },
                );
              },
            );
          },
        ),
      ),
    ).then((_) {
      bloc.add(const CloseDownloadsView());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReferralBloc, ReferralState>(
      listener: (context, state) {
        // Show snackbar messages
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ReferralBloc>().add(const ClearReferralMessage());
        }

        if (state.hasSuccess && state.createdLink == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ReferralBloc>().add(const ClearReferralMessage());
        }

        // Show downloads sheet when link selected
        if (state.selectedLinkId != null && state.selectedLink != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDownloadsSheet(context, state);
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),

                // Stats Cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: ReferralStatsCards(
                      stats: state.stats,
                      totalLinks: state.totalLinks,
                      activeLinks: state.activeLinks,
                      totalDownloads: state.totalDownloads,
                      totalPremiumConversions: state.totalPremiumConversions,
                    ),
                  ),
                ),

                // Table Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const Text(
                          'Referral Codes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${state.filteredLinks.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Links Table (moved up - more important)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 450,
                      child: ReferralLinkTable(
                        links: state.filteredLinks,
                        isLoading: state.isLoading,
                        filterByActive: state.filterByActive,
                        onFilterChanged: (isActive) {
                          context.read<ReferralBloc>().add(
                                FilterByActiveStatusRequested(isActive),
                              );
                        },
                        onViewDownloads: (link) {
                          context.read<ReferralBloc>().add(
                                LoadDownloadsRequested(link.id),
                              );
                        },
                        onToggleStatus: (linkId, isActive) {
                          context.read<ReferralBloc>().add(
                                ToggleLinkStatusRequested(
                                  linkId: linkId,
                                  isActive: isActive,
                                ),
                              );
                        },
                        onDelete: (linkId) {
                          context.read<ReferralBloc>().add(
                                DeleteReferralLinkRequested(linkId),
                              );
                        },
                      ),
                    ),
                  ),
                ),

                // Charts Section (moved below table)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: ReferralCharts(
                      downloadTrend: state.downloadTrend,
                      platformDistribution: state.platformDistribution,
                      topPerformers: state.topPerformers,
                      selectedPeriod: state.analyticsPeriod,
                      onPeriodChanged: (days) {
                        context.read<ReferralBloc>().add(
                              ChangeAnalyticsPeriodRequested(days),
                            );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.share_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Referral Codes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track app downloads via referral codes',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Generate Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
