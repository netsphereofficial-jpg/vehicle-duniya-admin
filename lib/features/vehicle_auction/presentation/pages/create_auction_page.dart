import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/auction.dart';
import '../../domain/entities/category.dart';
import '../bloc/auction_bloc.dart';
import '../bloc/auction_event.dart';
import '../bloc/auction_state.dart';
import '../widgets/file_upload_widget.dart';

/// Page for creating a new vehicle auction
class CreateAuctionPage extends StatefulWidget {
  final String? auctionId;

  const CreateAuctionPage({super.key, this.auctionId});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedCategory;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  AuctionMode _mode = AuctionMode.online;
  bool _checkBasePrice = false;
  EventType _eventType = EventType.other;
  ZipType _zipType = ZipType.contractNo;

  PlatformFile? _bidReportFile;
  PlatformFile? _imagesZipFile;
  PlatformFile? _vehicleExcelFile;

  bool get _isEditing => widget.auctionId != null;

  @override
  void initState() {
    super.initState();
    context.read<AuctionBloc>().add(const LoadCategoriesRequested());

    if (_isEditing) {
      context.read<AuctionBloc>().add(LoadAuctionDetailRequested(widget.auctionId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _populateFormFromAuction(Auction auction) {
    _nameController.text = auction.name;
    _selectedCategory = auction.category;
    _startDateTime = auction.startDate;
    _endDateTime = auction.endDate;
    _mode = auction.mode;
    _checkBasePrice = auction.checkBasePrice;
    _eventType = auction.eventType;
    _zipType = auction.zipType;
  }

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
    }
  }

  Future<void> _downloadSampleExcel() async {
    try {
      final data = await rootBundle.load('assets/samples/vehicle_import_sample.xlsx');
      final bytes = data.buffer.asUint8List();

      // For web, we'll create a download
      // For desktop, we can use path_provider
      // For now, show a snackbar since web download requires additional setup
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sample Excel loaded (${bytes.length} bytes). Download functionality coming soon.'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sample: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickVehicleExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'], // Only .xlsx supported, not .xls
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _vehicleExcelFile = file;
        });

        // Parse the Excel file
        if (file.bytes != null && mounted) {
          context.read<AuctionBloc>().add(ImportVehiclesFromExcel(
            fileBytes: file.bytes!,
            auctionId: widget.auctionId ?? 'new',
          ));
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

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

    if (_isEditing) {
      context.read<AuctionBloc>().add(UpdateAuctionRequested(
        auctionId: widget.auctionId!,
        updates: {
          'name': _nameController.text.trim(),
          'category': _selectedCategory,
          'startDate': _startDateTime,
          'endDate': _endDateTime,
          'mode': _mode.name,
          'checkBasePrice': _checkBasePrice,
          'eventType': _eventType.name,
          'zipType': _zipType.name,
        },
      ));
    } else {
      context.read<AuctionBloc>().add(CreateAuctionRequested(
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        startDate: _startDateTime!,
        endDate: _endDateTime!,
        mode: _mode,
        checkBasePrice: _checkBasePrice,
        eventType: _eventType,
        zipType: _zipType,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuctionBloc, AuctionState>(
      listener: (context, state) {
        if (_isEditing && state.selectedAuction != null && _nameController.text.isEmpty) {
          _populateFormFromAuction(state.selectedAuction!);
          setState(() {});
        }

        if (state.status == AuctionStateStatus.created ||
            state.status == AuctionStateStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Success!'),
              backgroundColor: AppColors.success,
            ),
          );

          if (state.selectedAuction != null) {
            if (_bidReportFile != null && _bidReportFile!.bytes != null) {
              context.read<AuctionBloc>().add(UploadBidReportRequested(
                auctionId: state.selectedAuction!.id,
                fileBytes: _bidReportFile!.bytes!,
                fileName: _bidReportFile!.name,
              ));
            }
            if (_imagesZipFile != null && _imagesZipFile!.bytes != null) {
              context.read<AuctionBloc>().add(UploadImagesZipRequested(
                auctionId: state.selectedAuction!.id,
                fileBytes: _imagesZipFile!.bytes!,
                fileName: _imagesZipFile!.name,
              ));
            }
          }

          context.go('/vehicle-auctions/active');
        }

        if (state.status == AuctionStateStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        // Handle import success message
        if (state.status == AuctionStateStatus.imported && state.hasImportedVehicles) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Vehicles imported!'),
              backgroundColor: state.hasImportErrors ? AppColors.warning : AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildAuctionDetailsCard(context, state),
                const SizedBox(height: 24),
                _buildFilesCard(context, state),
                const SizedBox(height: 24),
                _buildVehicleImportCard(context, state),
                const SizedBox(height: 24),
                _buildActionButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/vehicles/auctions/active'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        const SizedBox(width: 8),
        Text(
          _isEditing ? 'Edit Vehicle Auction' : 'Create Vehicle Auction',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionDetailsCard(BuildContext context, AuctionState state) {
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
            Text(
              'Auction Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Row 1: Auction Name + Category
            _buildResponsiveRow(
              children: [
                Expanded(flex: 2, child: _buildNameField()),
                const SizedBox(width: 16),
                Expanded(child: _buildCategoryDropdown(state.categories)),
              ],
            ),
            const SizedBox(height: 20),

            // Row 2: Start DateTime + End DateTime
            _buildResponsiveRow(
              children: [
                Expanded(child: _buildDateTimeField('Start Date & Time', true)),
                const SizedBox(width: 16),
                Expanded(child: _buildDateTimeField('End Date & Time', false)),
              ],
            ),
            const SizedBox(height: 20),

            // Row 3: Mode + Event Type
            _buildResponsiveRow(
              children: [
                Expanded(child: _buildModeDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildEventTypeDropdown()),
              ],
            ),
            const SizedBox(height: 20),

            // Row 4: Check Base Price
            _buildCheckBasePriceField(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRow({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: children.where((w) => w is! SizedBox).map((w) {
              if (w is Expanded) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: w.child,
                );
              }
              return w;
            }).toList(),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      },
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Auction Name', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter auction name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Auction name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Category', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: const Text('Select category'),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeField(String label, bool isStart) {
    final dateTime = isStart ? _startDateTime : _endDateTime;
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
                    dateTime != null ? formatter.format(dateTime) : 'Select date & time',
                    style: TextStyle(
                      color: dateTime != null ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Mode', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AuctionMode>(
          initialValue: _mode,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: AuctionMode.values.map((mode) {
            return DropdownMenuItem<AuctionMode>(
              value: mode,
              child: Text(mode.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _mode = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildEventTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Event Type', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<EventType>(
          initialValue: _eventType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: EventType.values.map((type) {
            return DropdownMenuItem<EventType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _eventType = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCheckBasePriceField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _checkBasePrice,
            onChanged: (value) {
              setState(() {
                _checkBasePrice = value ?? false;
              });
            },
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check Base Price',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Require base price validation for all vehicles in this auction',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesCard(BuildContext context, AuctionState state) {
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
            Text(
              'Files & Upload Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure zip type and upload files for this auction',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Zip Type Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zip Type',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildZipTypeOption(ZipType.contractNo, 'Contract No'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildZipTypeOption(ZipType.rcNo, 'RC No'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // File Uploads
            _buildResponsiveRow(
              children: [
                Expanded(
                  child: FileUploadWidget(
                    label: 'Bid Report',
                    hint: 'PDF or Excel file',
                    allowedExtensions: const ['pdf', 'xlsx', 'xls', 'csv'],
                    isLoading: state.isUploading,
                    onFileSelected: (file) {
                      setState(() {
                        _bidReportFile = file;
                      });
                    },
                    onFileRemoved: () {
                      setState(() {
                        _bidReportFile = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FileUploadWidget(
                    label: 'Images Zip',
                    hint: 'ZIP file with vehicle images',
                    allowedExtensions: const ['zip'],
                    isLoading: state.isUploading,
                    onFileSelected: (file) {
                      setState(() {
                        _imagesZipFile = file;
                      });
                    },
                    onFileRemoved: () {
                      setState(() {
                        _imagesZipFile = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZipTypeOption(ZipType type, String label) {
    final isSelected = _zipType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _zipType = type;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImportCard(BuildContext context, AuctionState state) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Data Import',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Import vehicle data from Excel spreadsheet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _downloadSampleExcel,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download Sample'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Excel Upload Area
            InkWell(
              onTap: state.isImporting ? null : _pickVehicleExcel,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: _vehicleExcelFile != null ? AppColors.success : AppColors.border,
                    width: _vehicleExcelFile != null ? 2 : 1,
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
                    ] else if (_vehicleExcelFile != null) ...[
                      Icon(Icons.check_circle, size: 48, color: AppColors.success),
                      const SizedBox(height: 12),
                      Text(
                        _vehicleExcelFile!.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (state.hasImportedVehicles) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: state.hasImportErrors
                                ? AppColors.warning.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            state.importSummary,
                            style: TextStyle(
                              color: state.hasImportErrors ? AppColors.warning : AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _vehicleExcelFile = null;
                          });
                          context.read<AuctionBloc>().add(const ClearImportedVehicles());
                        },
                        child: const Text('Remove & Choose Another'),
                      ),
                    ] else ...[
                      Icon(Icons.upload_file, size: 48, color: AppColors.textSecondary),
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
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Import Errors
            if (state.hasImportErrors) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, size: 20, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'Import Errors (${state.importErrors.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...state.importErrors.take(5).map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $error',
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    )),
                    if (state.importErrors.length > 5)
                      Text(
                        '... and ${state.importErrors.length - 5} more errors',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AuctionState state) {
    final isLoading = state.isCreating || state.isUpdating || state.isUploading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          text: 'Cancel',
          type: ButtonType.outline,
          onPressed: isLoading ? null : () => context.go('/vehicles/auctions/active'),
        ),
        const SizedBox(width: 16),
        CustomButton(
          text: _isEditing ? 'Update Auction' : 'Create Auction',
          type: ButtonType.primary,
          isLoading: isLoading,
          icon: _isEditing ? Icons.save : Icons.add,
          onPressed: isLoading ? null : _onSubmit,
        ),
      ],
    );
  }
}
