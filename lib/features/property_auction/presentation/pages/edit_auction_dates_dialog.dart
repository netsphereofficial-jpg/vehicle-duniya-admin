import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/property_auction.dart';

/// Dialog for editing auction start and end dates
class EditAuctionDatesDialog extends StatefulWidget {
  final PropertyAuction auction;
  final Function(DateTime startDate, DateTime endDate) onSave;

  const EditAuctionDatesDialog({
    super.key,
    required this.auction,
    required this.onSave,
  });

  @override
  State<EditAuctionDatesDialog> createState() => _EditAuctionDatesDialogState();
}

class _EditAuctionDatesDialogState extends State<EditAuctionDatesDialog> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  final DateFormat _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    _startDateTime = widget.auction.auctionStartDate;
    _endDateTime = widget.auction.auctionEndDate;
  }

  Future<void> _selectDateTime(bool isStart) async {
    final initialDate = isStart ? _startDateTime : _endDateTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        final dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (isStart) {
          _startDateTime = dateTime;
        } else {
          _endDateTime = dateTime;
        }
      });
    }
  }

  void _onSave() {
    if (_endDateTime.isBefore(_startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSave(_startDateTime, _endDateTime);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit_calendar, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Edit Auction Dates',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.gavel, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.auction.eventNo} - ${widget.auction.eventBank}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Start Date
            _buildDateTimeField('Start Date & Time', true),
            const SizedBox(height: 16),

            // End Date
            _buildDateTimeField('End Date & Time', false),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildDateTimeField(String label, bool isStart) {
    final dateTime = isStart ? _startDateTime : _endDateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(isStart),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dateTimeFormatter.format(dateTime),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Icon(Icons.calendar_today,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
