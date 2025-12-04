import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/auction.dart';
import '../../domain/entities/category.dart';
import '../bloc/auction_bloc.dart';
import '../bloc/auction_event.dart';
import '../bloc/auction_state.dart';
import '../widgets/file_upload_widget.dart';

/// Page for creating a new vehicle auction
class CreateAuctionPage extends StatefulWidget {
  final String? auctionId; // If provided, we're editing

  const CreateAuctionPage({super.key, this.auctionId});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _eventIdController = TextEditingController();

  String? _selectedCategory;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  AuctionMode _mode = AuctionMode.online;
  bool _checkBasePrice = false;
  EventType _eventType = EventType.other;
  ZipType _zipType = ZipType.contractNo;

  PlatformFile? _bidReportFile;
  PlatformFile? _imagesZipFile;

  bool get _isEditing => widget.auctionId != null;
  bool get _requiresEventId => _eventType != EventType.other;

  @override
  void initState() {
    super.initState();
    // Load categories
    context.read<AuctionBloc>().add(const LoadCategoriesRequested());

    // If editing, load auction details
    if (_isEditing) {
      context.read<AuctionBloc>().add(LoadAuctionDetailRequested(widget.auctionId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _eventIdController.dispose();
    super.dispose();
  }

  void _populateFormFromAuction(Auction auction) {
    _nameController.text = auction.name;
    _eventIdController.text = auction.eventId ?? '';
    _selectedCategory = auction.category;
    _startDate = auction.startDate;
    _startTime = TimeOfDay.fromDateTime(auction.startDate);
    _endDate = auction.endDate;
    _endTime = TimeOfDay.fromDateTime(auction.endDate);
    _mode = auction.mode;
    _checkBasePrice = auction.checkBasePrice;
    _eventType = auction.eventType;
    _zipType = auction.zipType;
  }

  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    final t = time ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now().add(const Duration(days: 7)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = _combineDateTime(_startDate, _startTime);
    final endDateTime = _combineDateTime(_endDate, _endTime);

    if (startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isEditing) {
      // Update existing auction
      context.read<AuctionBloc>().add(UpdateAuctionRequested(
            auctionId: widget.auctionId!,
            updates: {
              'name': _nameController.text.trim(),
              'category': _selectedCategory,
              'startDate': startDateTime,
              'endDate': endDateTime,
              'mode': _mode.name,
              'checkBasePrice': _checkBasePrice,
              'eventType': _eventType.name,
              'eventId': _requiresEventId ? _eventIdController.text.trim() : null,
              'zipType': _zipType.name,
            },
          ));
    } else {
      // Create new auction
      context.read<AuctionBloc>().add(CreateAuctionRequested(
            name: _nameController.text.trim(),
            category: _selectedCategory!,
            startDate: startDateTime,
            endDate: endDateTime,
            mode: _mode,
            checkBasePrice: _checkBasePrice,
            eventType: _eventType,
            eventId: _requiresEventId ? _eventIdController.text.trim() : null,
            zipType: _zipType,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuctionBloc, AuctionState>(
      listener: (context, state) {
        // Populate form when editing
        if (_isEditing && state.selectedAuction != null && _nameController.text.isEmpty) {
          _populateFormFromAuction(state.selectedAuction!);
          setState(() {});
        }

        // Handle success
        if (state.status == AuctionStateStatus.created ||
            state.status == AuctionStateStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Success!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Upload files if provided
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

          // Navigate to auctions list
          context.go('/vehicles/auctions/active');
        }

        // Handle error
        if (state.status == AuctionStateStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
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
                _buildFormCard(context, state),
                const SizedBox(height: 24),
                _buildFileUploadsCard(context, state),
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

  Widget _buildFormCard(BuildContext context, AuctionState state) {
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(state.categories),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildNameField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCategoryDropdown(state.categories)),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Row 2: Start Date/Time + End Date/Time
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildDateTimeField('Start Date & Time', true),
                      const SizedBox(height: 16),
                      _buildDateTimeField('End Date & Time', false),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDateTimeField('Start Date & Time', true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDateTimeField('End Date & Time', false)),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Row 3: Mode + Event Type
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildModeDropdown(),
                      const SizedBox(height: 16),
                      _buildEventTypeDropdown(),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildModeDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildEventTypeDropdown()),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Row 4: Event ID (conditional)
            if (_requiresEventId) ...[
              CustomTextField(
                label: 'Event ID',
                hint: 'Enter event ID',
                controller: _eventIdController,
                prefixIcon: Icons.tag,
                validator: (value) {
                  if (_requiresEventId && (value == null || value.isEmpty)) {
                    return 'Event ID is required for ${_eventType.displayName}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Row 5: Check Base Price + Zip Type
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildCheckBasePriceField(),
                      const SizedBox(height: 16),
                      _buildZipTypeField(),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCheckBasePriceField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildZipTypeField()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      label: 'Auction Name',
      hint: 'Enter auction name',
      controller: _nameController,
      prefixIcon: Icons.gavel,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Auction name is required';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
    final date = isStart ? _startDate : _endDate;
    final time = isStart ? _startTime : _endTime;
    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Date Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context, isStart),
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  date != null ? dateFormatter.format(date) : 'Select Date',
                  style: TextStyle(
                    color: date != null ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Time Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(context, isStart),
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(
                  time != null
                      ? timeFormatter.format(DateTime(2000, 1, 1, time.hour, time.minute))
                      : 'Select Time',
                  style: TextStyle(
                    color: time != null ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
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
            Text(
              'Mode',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AuctionMode>(
          initialValue: _mode,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lan_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
            Text(
              'Event Type',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<EventType>(
          initialValue: _eventType,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.business_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check Base Price',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Require base price for all vehicles',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZipTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Zip Type',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<ZipType>(
                  value: ZipType.contractNo,
                  groupValue: _zipType,
                  onChanged: (value) {
                    if (value != null) setState(() => _zipType = value);
                  },
                  title: const Text('Contract No', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<ZipType>(
                  value: ZipType.rcNo,
                  groupValue: _zipType,
                  onChanged: (value) {
                    if (value != null) setState(() => _zipType = value);
                  },
                  title: const Text('RC No', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadsCard(BuildContext context, AuctionState state) {
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
              'File Uploads',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload bid report and images (optional)',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      FileUploadWidget(
                        label: 'Bid Report',
                        hint: 'Upload PDF or Excel file',
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
                      const SizedBox(height: 16),
                      FileUploadWidget(
                        label: 'Images Zip',
                        hint: 'Upload ZIP file with vehicle images',
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
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FileUploadWidget(
                        label: 'Bid Report',
                        hint: 'Upload PDF or Excel file',
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
                        hint: 'Upload ZIP file with vehicle images',
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
                );
              },
            ),
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
