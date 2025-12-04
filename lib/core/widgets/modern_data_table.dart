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

/// Modern, reusable data table with search, pagination, and animations
class ModernDataTable<T> extends StatefulWidget {
  final List<T> data;
  final List<TableColumnDef<T>> columns;
  final bool isLoading;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final bool showSearch;
  final bool showEntriesDropdown;
  final String? searchHint;
  final String Function(T item)? searchableText;
  final Widget? headerActions;
  final void Function(T item)? onRowTap;
  final bool enableHover;
  final double rowHeight;
  final List<int> entriesOptions;
  final int initialEntriesPerPage;

  const ModernDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyIcon,
    this.showSearch = true,
    this.showEntriesDropdown = true,
    this.searchHint = 'Search...',
    this.searchableText,
    this.headerActions,
    this.onRowTap,
    this.enableHover = true,
    this.rowHeight = 56,
    this.entriesOptions = const [10, 25, 50, 100],
    this.initialEntriesPerPage = 10,
  });

  @override
  State<ModernDataTable<T>> createState() => _ModernDataTableState<T>();
}

class _ModernDataTableState<T> extends State<ModernDataTable<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late int _entriesPerPage;
  int _currentPage = 0;
  int? _hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _entriesPerPage = widget.initialEntriesPerPage;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<T> get _paginatedData {
    final startIndex = _currentPage * _entriesPerPage;
    final endIndex = (startIndex + _entriesPerPage).clamp(0, _filteredData.length);
    if (startIndex >= _filteredData.length) return [];
    return _filteredData.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredData.length / _entriesPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with search and entries
        if (widget.showSearch || widget.showEntriesDropdown || widget.headerActions != null)
          _buildHeader(),

        // Table
        Expanded(
          child: widget.isLoading
              ? _buildLoadingState()
              : _filteredData.isEmpty
                  ? _buildEmptyState()
                  : _buildTable(),
        ),

        // Footer with pagination
        if (!widget.isLoading && _filteredData.isNotEmpty) _buildFooter(),
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

          // Entries dropdown
          if (widget.showEntriesDropdown) ...[
            Text(
              'Show ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _entriesPerPage,
                  isDense: true,
                  items: widget.entriesOptions.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text('$e', style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _entriesPerPage = value;
                        _currentPage = 0;
                      });
                    }
                  },
                ),
              ),
            ),
            Text(
              ' entries',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(width: 24),
          ],

          // Search
          if (widget.showSearch)
            SizedBox(
              width: 280,
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
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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

  Widget _buildTable() {
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
          ...List.generate(_paginatedData.length, (index) {
            final item = _paginatedData[index];
            final actualIndex = _currentPage * _entriesPerPage + index;
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
        column.header,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.textSecondary,
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

  Widget _buildFooter() {
    final startItem = _currentPage * _entriesPerPage + 1;
    final endItem = ((_currentPage + 1) * _entriesPerPage).clamp(0, _filteredData.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $startItem to $endItem of ${_filteredData.length} entries',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          if (_filteredData.length != widget.data.length)
            Text(
              ' (filtered from ${widget.data.length} total)',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
              ),
            ),
          const Spacer(),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        _PaginationButton(
          icon: Icons.chevron_left,
          onPressed: _currentPage > 0
              ? () => setState(() => _currentPage--)
              : null,
        ),
        const SizedBox(width: 8),

        // Page numbers
        ..._buildPageNumbers(),

        const SizedBox(width: 8),
        // Next button
        _PaginationButton(
          icon: Icons.chevron_right,
          onPressed: _currentPage < _totalPages - 1
              ? () => setState(() => _currentPage++)
              : null,
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    final pages = <Widget>[];
    const maxVisiblePages = 5;

    int startPage = (_currentPage - maxVisiblePages ~/ 2).clamp(0, _totalPages - maxVisiblePages).clamp(0, _totalPages - 1);
    int endPage = (startPage + maxVisiblePages - 1).clamp(0, _totalPages - 1);

    if (startPage > 0) {
      pages.add(_PageNumber(page: 0, isSelected: _currentPage == 0, onTap: () => setState(() => _currentPage = 0)));
      if (startPage > 1) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...'),
        ));
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pages.add(_PageNumber(
        page: i,
        isSelected: _currentPage == i,
        onTap: () => setState(() => _currentPage = i),
      ));
    }

    if (endPage < _totalPages - 1) {
      if (endPage < _totalPages - 2) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...'),
        ));
      }
      pages.add(_PageNumber(
        page: _totalPages - 1,
        isSelected: _currentPage == _totalPages - 1,
        onTap: () => setState(() => _currentPage = _totalPages - 1),
      ));
    }

    return pages;
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Material(
      color: isEnabled ? AppColors.surface : AppColors.background,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isEnabled ? AppColors.textPrimary : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int page;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageNumber({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: isSelected ? null : onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${page + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
