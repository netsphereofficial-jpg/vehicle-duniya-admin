import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/property_auction_bloc.dart';
import '../bloc/property_auction_event.dart';
import '../bloc/property_auction_state.dart';

/// Page for creating property auctions via Excel import
class CreatePropertyAuctionPage extends StatefulWidget {
  const CreatePropertyAuctionPage({super.key});

  @override
  State<CreatePropertyAuctionPage> createState() =>
      _CreatePropertyAuctionPageState();
}

class _CreatePropertyAuctionPageState extends State<CreatePropertyAuctionPage> {
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  PlatformFile? _excelFile;

  final DateFormat _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');

  Future<void> _selectDateTime(BuildContext ctx, bool isStart) async {
    final initialDate = isStart
        ? (_startDateTime ?? DateTime.now())
        : (_endDateTime ?? DateTime.now().add(const Duration(days: 7)));

    final pickedDate = await showDatePicker(
      context: ctx,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: ctx,
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

      // If we already have an Excel file, re-preview with new dates
      if (_excelFile != null && _startDateTime != null && _endDateTime != null) {
        _previewImport();
      }
    }
  }

  Future<void> _pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'], // Only .xlsx supported, not .xls
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _excelFile = file;
        });

        // Preview the import if dates are selected
        if (_startDateTime != null && _endDateTime != null) {
          _previewImport();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _previewImport() {
    if (_excelFile?.bytes == null ||
        _startDateTime == null ||
        _endDateTime == null) {
      return;
    }

    context.read<PropertyAuctionBloc>().add(PreviewImportRequested(
          startDate: _startDateTime!,
          endDate: _endDateTime!,
          excelBytes: _excelFile!.bytes!,
          fileName: _excelFile!.name,
        ));
  }

  void _onSubmit() {
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_excelFile?.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an Excel file'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<PropertyAuctionBloc>().add(CreateAuctionsRequested(
          startDate: _startDateTime!,
          endDate: _endDateTime!,
          excelBytes: _excelFile!.bytes!,
          fileName: _excelFile!.name,
        ));
  }

  void _clearForm() {
    setState(() {
      _excelFile = null;
    });
    context.read<PropertyAuctionBloc>().add(const ClearImportPreview());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyAuctionBloc, PropertyAuctionState>(
      listener: (context, state) {
        if (state.status == PropertyAuctionBlocStatus.created) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Auctions created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/property-auction/active');
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
        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildDatesCard(context),
                    const SizedBox(height: 24),
                    _buildExcelImportCard(context, state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Sticky footer with action buttons
            _buildStickyFooter(context, state),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/property-auction/active'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Property Auction',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Import property auctions from Excel file',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatesCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Auction Schedule',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set the start and end date/time for all properties in this import',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Date time pickers
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildDateTimeField('Auction Start Date & Time', true),
                      const SizedBox(height: 16),
                      _buildDateTimeField('Auction End Date & Time', false),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                        child:
                            _buildDateTimeField('Auction Start Date & Time', true)),
                    const SizedBox(width: 24),
                    Expanded(
                        child:
                            _buildDateTimeField('Auction End Date & Time', false)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField(String label, bool isStart) {
    final dateTime = isStart ? _startDateTime : _endDateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(context, isStart),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateTime != null
                        ? _dateTimeFormatter.format(dateTime)
                        : 'Select date & time',
                    style: TextStyle(
                      color: dateTime != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today,
                    size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExcelImportCard(
      BuildContext context, PropertyAuctionState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.upload_file,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Data Import',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload Excel file with property auction details',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Excel Upload Area
            InkWell(
              onTap: state.isImporting ? null : _pickExcelFile,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: _excelFile != null ? AppColors.success : AppColors.border,
                    width: _excelFile != null ? 2 : 1,
                    style: _excelFile != null ? BorderStyle.solid : BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (state.isImporting) ...[
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: 16),
                      const Text('Processing Excel file...'),
                    ] else if (_excelFile != null) ...[
                      Icon(Icons.check_circle, size: 48, color: AppColors.success),
                      const SizedBox(height: 12),
                      Text(
                        _excelFile!.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(_excelFile!.size),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _clearForm,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Remove & Choose Another'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.upload_file,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'Click to upload Excel file',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Only .xlsx format supported (Save as Excel Workbook)',
                        style:
                            TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Import Preview/Summary
            if (state.importResult != null) ...[
              const SizedBox(height: 20),
              _buildImportSummary(context, state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportSummary(BuildContext context, PropertyAuctionState state) {
    final result = state.importResult!;
    final hasErrors = result.errors.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasErrors
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasErrors
                  ? AppColors.warning.withValues(alpha: 0.3)
                  : AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasErrors ? Icons.warning_amber : Icons.check_circle,
                color: hasErrors ? AppColors.warning : AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result.successfulRows} properties ready to import',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: hasErrors ? AppColors.warning : AppColors.success,
                      ),
                    ),
                    if (result.totalRows > result.successfulRows)
                      Text(
                        '${result.totalRows - result.successfulRows} rows skipped',
                        style: TextStyle(
                          fontSize: 13,
                          color: hasErrors
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Error details
        if (hasErrors) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 20, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Import Warnings (${result.errors.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...result.errors.take(5).map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $error',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textPrimary),
                      ),
                    )),
                if (result.errors.length > 5)
                  Text(
                    '... and ${result.errors.length - 5} more warnings',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStickyFooter(BuildContext context, PropertyAuctionState state) {
    final isLoading = state.isCreating || state.isImporting;
    final canSubmit = _startDateTime != null &&
        _endDateTime != null &&
        _excelFile != null &&
        state.importResult != null &&
        state.importResult!.successfulRows > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            text: 'Cancel',
            type: ButtonType.outline,
            onPressed: isLoading ? null : () => context.go('/property-auction/active'),
          ),
          const SizedBox(width: 16),
          CustomButton(
            text: 'Create ${state.importResult?.successfulRows ?? 0} Auctions',
            type: ButtonType.primary,
            isLoading: isLoading,
            icon: Icons.add,
            onPressed: isLoading || !canSubmit ? null : _onSubmit,
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
