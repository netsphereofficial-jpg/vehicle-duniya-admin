import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';

/// A reusable file upload widget for selecting and displaying files
class FileUploadWidget extends StatefulWidget {
  final String label;
  final String hint;
  final List<String>? allowedExtensions;
  final FileType fileType;
  final void Function(PlatformFile file)? onFileSelected;
  final void Function()? onFileRemoved;
  final bool isRequired;
  final bool isLoading;
  final String? errorText;
  final PlatformFile? initialFile;

  const FileUploadWidget({
    super.key,
    required this.label,
    this.hint = 'Click to select a file',
    this.allowedExtensions,
    this.fileType = FileType.any,
    this.onFileSelected,
    this.onFileRemoved,
    this.isRequired = false,
    this.isLoading = false,
    this.errorText,
    this.initialFile,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  PlatformFile? _selectedFile;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  @override
  void didUpdateWidget(FileUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFile != oldWidget.initialFile) {
      _selectedFile = widget.initialFile;
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: widget.allowedExtensions != null
            ? FileType.custom
            : widget.fileType,
        allowedExtensions: widget.allowedExtensions,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
        widget.onFileSelected?.call(result.files.first);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
    widget.onFileRemoved?.call();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'xlsx':
      case 'xls':
      case 'csv':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Upload Area
        if (widget.isLoading)
          _buildLoadingState()
        else if (_selectedFile != null)
          _buildFilePreview()
        else
          _buildUploadArea(),

        // Error Text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickFile,
        child: DragTarget<Object>(
          onWillAcceptWithDetails: (data) {
            setState(() => _isDragging = true);
            return true;
          },
          onLeave: (data) {
            setState(() => _isDragging = false);
          },
          onAcceptWithDetails: (data) {
            setState(() => _isDragging = false);
            // Handle drag and drop if needed
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isDragging
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isDragging ? AppColors.primary : AppColors.border,
                  width: _isDragging ? 2 : 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.hint,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.allowedExtensions != null
                        ? 'Supported: ${widget.allowedExtensions!.join(', ').toUpperCase()}'
                        : 'Any file type',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final file = _selectedFile!;
    final extension = file.extension;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(extension),
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(file.size),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Success Icon
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),

          // Remove Button
          IconButton(
            onPressed: _removeFile,
            icon: const Icon(Icons.close),
            iconSize: 20,
            color: AppColors.textSecondary,
            tooltip: 'Remove file',
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Uploading...',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
