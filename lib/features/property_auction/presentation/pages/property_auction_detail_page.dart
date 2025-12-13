import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/property_auction.dart';
import '../bloc/property_auction_bloc.dart';
import '../bloc/property_auction_event.dart';
import '../bloc/property_auction_state.dart';
import 'edit_auction_dates_dialog.dart';

/// Page displaying property auction details
class PropertyAuctionDetailPage extends StatefulWidget {
  final String auctionId;

  const PropertyAuctionDetailPage({super.key, required this.auctionId});

  @override
  State<PropertyAuctionDetailPage> createState() =>
      _PropertyAuctionDetailPageState();
}

class _PropertyAuctionDetailPageState extends State<PropertyAuctionDetailPage> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');
  final DateFormat _fullFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    context
        .read<PropertyAuctionBloc>()
        .add(SelectAuctionRequested(widget.auctionId));
  }

  void _onEditDates(PropertyAuction auction) {
    showDialog(
      context: context,
      builder: (context) => EditAuctionDatesDialog(
        auction: auction,
        onSave: (startDate, endDate) {
          context.read<PropertyAuctionBloc>().add(UpdateAuctionDatesRequested(
                auctionId: auction.id,
                startDate: startDate,
                endDate: endDate,
              ));
        },
      ),
    );
  }

  void _onDelete(PropertyAuction auction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Auction?'),
        content: Text(
          'This will permanently delete the auction for "${auction.eventTitle}". '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<PropertyAuctionBloc>()
                  .add(DeleteAuctionRequested(auction.id));
              context.go('/property-auction/active');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyUrl(String? url) {
    if (url == null || url.isEmpty) return;
    Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to clipboard'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyAuctionBloc, PropertyAuctionState>(
      listener: (context, state) {
        if (state.status == PropertyAuctionBlocStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Auction updated'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.status == PropertyAuctionBlocStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final auction = state.selectedAuction ??
            state.auctions.where((a) => a.id == widget.auctionId).firstOrNull;

        if (auction == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, auction),
              const SizedBox(height: 24),
              _buildStatusBanner(auction),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        _buildPropertyInfoCard(auction),
                        const SizedBox(height: 10),
                        _buildAuctionInfoCard(auction),
                        const SizedBox(height: 10),
                        _buildFinancialCard(auction),
                        const SizedBox(height: 10),
                        _buildDatesCard(auction),
                        const SizedBox(height: 10),
                        _buildDocumentsCard(auction),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildPropertyInfoCard(auction)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildAuctionInfoCard(auction)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildFinancialCard(auction)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDatesCard(auction)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDocumentsCard(auction),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PropertyAuction auction) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/property-auction/active'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auction.eventTitle.isNotEmpty
                    ? auction.eventTitle
                    : 'Property Auction ${auction.eventNo}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      auction.eventNo,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    auction.eventBank,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        CustomButton(
          text: 'Edit Dates',
          type: ButtonType.outline,
          icon: Icons.edit_calendar,
          onPressed: () => _onEditDates(auction),
        ),
        const SizedBox(width: 8),
        CustomButton(
          text: 'Delete',
          type: ButtonType.outline,
          icon: Icons.delete_outline,
          onPressed: () => _onDelete(auction),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(PropertyAuction auction) {
    Color color;
    String label;
    String description;
    IconData icon;

    switch (auction.status) {
      case PropertyAuctionStatus.live:
        color = AppColors.success;
        label = 'Live Auction';
        description = 'Ends ${_fullFormat.format(auction.auctionEndDate)}';
        icon = Icons.play_circle;
        break;
      case PropertyAuctionStatus.upcoming:
        color = AppColors.warning;
        label = 'Upcoming Auction';
        description = 'Starts ${_fullFormat.format(auction.auctionStartDate)}';
        icon = Icons.schedule;
        break;
      case PropertyAuctionStatus.ended:
        color = AppColors.textSecondary;
        label = 'Auction Ended';
        description = 'Ended ${_fullFormat.format(auction.auctionEndDate)}';
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfoCard(PropertyAuction auction) {
    return _buildCard(
      title: 'Property Details',
      icon: Icons.home,
      color: AppColors.primary,
      children: [
        _buildInfoRow('Category', auction.propertyCategory),
        _buildInfoRow('Sub Category', auction.propertySubCategory),
        _buildInfoRow('Borrower Name', auction.borrowerName),
        _buildInfoRow('Description', auction.propertyDescription, isLong: true),
      ],
    );
  }

  Widget _buildAuctionInfoCard(PropertyAuction auction) {
    return _buildCard(
      title: 'Auction Details',
      icon: Icons.gavel,
      color: AppColors.warning,
      children: [
        _buildInfoRow('Event Type', auction.eventType),
        _buildInfoRow('NIT Ref No', auction.nitRefNo),
        _buildInfoRow('Bank', auction.eventBank),
        _buildInfoRow('Branch', auction.eventBranch),
        _buildInfoRow('DSC Required', auction.dscRequired),
        _buildInfoRow('Price Bid', auction.priceBid),
        _buildInfoRow('Auto Extension', auction.autoExtensionTime),
        _buildInfoRow('No. of Extensions', auction.noOfAutoExtension),
      ],
    );
  }

  Widget _buildFinancialCard(PropertyAuction auction) {
    return _buildCard(
      title: 'Financial Details',
      icon: Icons.account_balance_wallet,
      color: AppColors.success,
      children: [
        _buildInfoRow('Reserve Price', '₹${auction.formattedReservePrice}',
            highlight: true),
        _buildInfoRow('EMD Amount', '₹${auction.formattedEmdAmount}'),
        _buildInfoRow('Tender Fee', '₹${auction.formattedTenderFee}'),
        _buildInfoRow(
            'Bid Increment', '₹${_formatNumber(auction.bidIncrementValue)}'),
        const Divider(height: 24),
        _buildInfoRow('EMD Bank', auction.emdBankName),
        _buildInfoRow('EMD Account No', auction.emdAccountNo),
        _buildInfoRow('EMD IFSC', auction.emdIfscCode),
      ],
    );
  }

  Widget _buildDatesCard(PropertyAuction auction) {
    return _buildCard(
      title: 'Important Dates',
      icon: Icons.calendar_today,
      color: AppColors.info,
      children: [
        _buildDateRow('Auction Start', auction.auctionStartDate, isHighlight: true),
        _buildDateRow('Auction End', auction.auctionEndDate, isHighlight: true),
        if (auction.pressReleaseDate != null)
          _buildDateRow('Press Release', auction.pressReleaseDate!),
        if (auction.inspectionDateFrom != null)
          _buildDateRow('Inspection From', auction.inspectionDateFrom!),
        if (auction.inspectionDateTo != null)
          _buildDateRow('Inspection To', auction.inspectionDateTo!),
        if (auction.submissionLastDate != null)
          _buildDateRow('Submission Last Date', auction.submissionLastDate!),
        if (auction.offerOpeningDate != null)
          _buildDateRow('Offer Opening', auction.offerOpeningDate!),
      ],
    );
  }

  Widget _buildDocumentsCard(PropertyAuction auction) {
    final hasDocuments = auction.paperPublishingUrl?.isNotEmpty == true ||
        auction.detailsOfBidderUrl?.isNotEmpty == true ||
        auction.declarationUrl?.isNotEmpty == true ||
        auction.documentsRequired.isNotEmpty;

    if (!hasDocuments) return const SizedBox.shrink();

    return _buildCard(
      title: 'Documents & Requirements',
      icon: Icons.description,
      color: AppColors.error,
      children: [
        if (auction.documentsRequired.isNotEmpty)
          _buildInfoRow('Required Documents', auction.documentsRequired,
              isLong: true),
        if (auction.paperPublishingUrl?.isNotEmpty == true)
          _buildLinkRow('Paper Publishing', auction.paperPublishingUrl!),
        if (auction.detailsOfBidderUrl?.isNotEmpty == true)
          _buildLinkRow('Details of Bidder (Annexure 2)', auction.detailsOfBidderUrl!),
        if (auction.declarationUrl?.isNotEmpty == true)
          _buildLinkRow('Declaration (Annexure 3)', auction.declarationUrl!),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with colored accent
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: color.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color.withValues(alpha: 0.9),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isLong = false, bool highlight = false}) {
    if (value.isEmpty) return const SizedBox.shrink();

    if (isLong) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                height: 1.4,
                color: highlight ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                color: highlight ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateFormat.format(date),
                  style: TextStyle(
                    fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                    color: isHighlight ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeFormat.format(date),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Material(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => _copyUrl(url),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)} L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)} K';
    }
    return value.toStringAsFixed(0);
  }
}
