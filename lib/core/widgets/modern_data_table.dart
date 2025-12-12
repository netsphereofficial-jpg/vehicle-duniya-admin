import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Column definition for ModernDataTable
class TableColumnDef<T> {
  final String header;
  final String? key;
  final double? width;
  final double? flex;
  final Widget Function(T item, int index)? cellBuilder;
  final TextAlign align;
  final bool sortable;

  const TableColumnDef({
    required this.header,
    this.key,
    this.width,
    this.flex,
    this.cellBuilder,
    this.align = TextAlign.left,
    this.sortable = false,
  });
}

/// Modern, reusable data table with smart auto-pagination
class ModernDataTable<T> extends StatefulWidget {
  final List<T> data;
  final List<TableColumnDef<T>> columns;
  final bool isLoading;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final bool showSearch;
  final String? searchHint;
  final String Function(T item)? searchableText;
  final Widget? headerActions;
  final void Function(T item)? onRowTap;
  final bool enableHover;
  final double rowHeight;
  /// If true, auto-calculates rows per page based on available height
  final bool smartPagination;
  /// Fixed entries per page (used when smartPagination is false)
  final int entriesPerPage;

  const ModernDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyIcon,
    this.showSearch = true,
    this.searchHint = 'Search...',
    this.searchableText,
    this.headerActions,
    this.onRowTap,
    this.enableHover = true,
    this.rowHeight = 56,
    this.smartPagination = true,
    this.entriesPerPage = 10,
  });

  @override
  State<ModernDataTable<T>> createState() => _ModernDataTableState<T>();
}

class _ModernDataTableState<T> extends State<ModernDataTable<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  int? _hoveredRowIndex;
  int _calculatedEntriesPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Calculate optimal entries based on available height
  int _calculateEntriesPerPage(double availableHeight) {
    if (!widget.smartPagination) return widget.entriesPerPage;

    // Account for header row (48px) and some padding
    const headerHeight = 48.0;
    const padding = 16.0;
    final usableHeight = availableHeight - headerHeight - padding;
    final calculatedEntries = (usableHeight / widget.rowHeight).floor();

    // Minimum 5 entries, maximum 50
    return calculatedEntries.clamp(5, 50);
  }

  List<T> get _filteredData {
    if (_searchQuery.isEmpty || widget.searchableText == null) {
      return widget.data;
    }
    final query = _searchQuery.toLowerCase();
    return widget.data.where((item) {
      return widget.searchableText!(item).toLowerCase().contains(query);
    }).toList();
  }

  List<T> _getPaginatedData(int entriesPerPage) {
    final startIndex = _currentPage * entriesPerPage;
    final endIndex = (startIndex + entriesPerPage).clamp(0, _filteredData.length);
    if (startIndex >= _filteredData.length) return [];
    return _filteredData.sublist(startIndex, endIndex);
  }

  int _getTotalPages(int entriesPerPage) => entriesPerPage > 0
      ? (_filteredData.length / entriesPerPage).ceil()
      : 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with search
        if (widget.showSearch || widget.headerActions != null)
          _buildHeader(),

        // Table with smart pagination
        Expanded(
          child: widget.isLoading
              ? _buildLoadingState()
              : _filteredData.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final entriesPerPage = _calculateEntriesPerPage(constraints.maxHeight);
                        // Reset page if data changed and current page is out of bounds
                        final totalPages = _getTotalPages(entriesPerPage);
                        if (_currentPage >= totalPages && totalPages > 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() => _currentPage = totalPages - 1);
                          });
                        }
                        return _buildTable(entriesPerPage);
                      },
                    ),
        ),

        // Footer with pagination
        if (!widget.isLoading && _filteredData.isNotEmpty)
          _buildSmartFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (widget.headerActions != null) ...[
            widget.headerActions!,
            const Spacer(),
          ] else
            const Spacer(),

          // Search
          if (widget.showSearch)
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _currentPage = 0;
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTable(int entriesPerPage) {
    _calculatedEntriesPerPage = entriesPerPage;
    final paginatedData = _getPaginatedData(entriesPerPage);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Table Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: widget.columns.map((col) {
                return _buildHeaderCell(col);
              }).toList(),
            ),
          ),

          // Table Rows
          ...List.generate(paginatedData.length, (index) {
            final item = paginatedData[index];
            final actualIndex = _currentPage * entriesPerPage + index;
            return _buildRow(item, actualIndex, index);
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(TableColumnDef<T> column) {
    Widget cell = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: _getAlignment(column.align),
      child: Text(
        column.header.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (column.width != null) {
      return SizedBox(width: column.width, child: cell);
    }
    return Expanded(flex: column.flex?.toInt() ?? 1, child: cell);
  }

  Widget _buildRow(T item, int actualIndex, int displayIndex) {
    final isHovered = _hoveredRowIndex == displayIndex;

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _hoveredRowIndex = displayIndex) : null,
      onExit: widget.enableHover ? (_) => setState(() => _hoveredRowIndex = null) : null,
      child: GestureDetector(
        onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.rowHeight,
          decoration: BoxDecoration(
            color: isHovered ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: widget.columns.map((col) {
              return _buildCell(col, item, actualIndex);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(TableColumnDef<T> column, T item, int index) {
    Widget content;

    if (column.cellBuilder != null) {
      content = column.cellBuilder!(item, index);
    } else {
      content = Text(
        '-',
        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      );
    }

    Widget cell = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: _getAlignment(column.align),
      child: content,
    );

    if (column.width != null) {
      return SizedBox(width: column.width, child: cell);
    }
    return Expanded(flex: column.flex?.toInt() ?? 1, child: cell);
  }

  Alignment _getAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.emptyIcon ?? Icons.inbox_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? 'No data found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmartFooter() {
    final entriesPerPage = _calculatedEntriesPerPage;
    final totalPages = _getTotalPages(entriesPerPage);
    final startItem = _currentPage * entriesPerPage + 1;
    final endItem = ((_currentPage + 1) * entriesPerPage).clamp(0, _filteredData.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Result count with modern styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.list_alt, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '$startItem–$endItem',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  ' of ${_filteredData.length}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_filteredData.length != widget.data.length) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, size: 12, color: AppColors.info),
                  const SizedBox(width: 4),
                  Text(
                    'Filtered',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          _buildSmartPagination(totalPages),
        ],
      ),
    );
  }

  Widget _buildSmartPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First page button
        if (totalPages > 3)
          _SmartPaginationButton(
            icon: Icons.first_page,
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage = 0)
                : null,
            tooltip: 'First page',
          ),

        // Previous button
        _SmartPaginationButton(
          icon: Icons.chevron_left,
          onPressed: _currentPage > 0
              ? () => setState(() => _currentPage--)
              : null,
          tooltip: 'Previous',
        ),

        const SizedBox(width: 8),

        // Current page indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${_currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Next button
        _SmartPaginationButton(
          icon: Icons.chevron_right,
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() => _currentPage++)
              : null,
          tooltip: 'Next',
        ),

        // Last page button
        if (totalPages > 3)
          _SmartPaginationButton(
            icon: Icons.last_page,
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage = totalPages - 1)
                : null,
            tooltip: 'Last page',
          ),
      ],
    );
  }
}

/// Smart pagination button with hover effect
class _SmartPaginationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _SmartPaginationButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_SmartPaginationButton> createState() => _SmartPaginationButtonState();
}

class _SmartPaginationButtonState extends State<_SmartPaginationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: isEnabled && _isHovered
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isEnabled && _isHovered
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: isEnabled
                      ? (_isHovered ? AppColors.primary : AppColors.textPrimary)
                      : AppColors.textLight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
