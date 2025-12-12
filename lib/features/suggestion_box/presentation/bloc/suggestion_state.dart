import 'package:equatable/equatable.dart';

import '../../domain/entities/suggestion.dart';

/// Status of suggestion operations
enum SuggestionLoadStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

/// State for suggestion bloc
class SuggestionState extends Equatable {
  final List<Suggestion> suggestions;
  final SuggestionLoadStatus status;
  final String? errorMessage;
  final String? successMessage;
  final SuggestionStatus? filterStatus;
  final SuggestionType? filterType;

  const SuggestionState({
    this.suggestions = const [],
    this.status = SuggestionLoadStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.filterStatus,
    this.filterType,
  });

  /// Get filtered suggestions
  List<Suggestion> get filteredSuggestions {
    var result = suggestions;

    if (filterStatus != null) {
      result = result.where((s) => s.status == filterStatus).toList();
    }

    if (filterType != null) {
      result = result.where((s) => s.type == filterType).toList();
    }

    return result;
  }

  /// Count by status
  int countByStatus(SuggestionStatus status) {
    return suggestions.where((s) => s.status == status).length;
  }

  /// Count by type
  int countByType(SuggestionType type) {
    return suggestions.where((s) => s.type == type).length;
  }

  /// Total pending count
  int get pendingCount => countByStatus(SuggestionStatus.pending);

  /// Total in progress count
  int get inProgressCount => countByStatus(SuggestionStatus.inProgress);

  /// Total resolved count
  int get resolvedCount => countByStatus(SuggestionStatus.resolved);

  /// Total closed count
  int get closedCount => countByStatus(SuggestionStatus.closed);

  /// Check if loading
  bool get isLoading => status == SuggestionLoadStatus.loading;

  /// Check if updating
  bool get isUpdating => status == SuggestionLoadStatus.updating;

  /// Check if has error
  bool get hasError => errorMessage != null;

  /// Check if has success
  bool get hasSuccess => successMessage != null;

  /// Copy with method
  SuggestionState copyWith({
    List<Suggestion>? suggestions,
    SuggestionLoadStatus? status,
    String? errorMessage,
    String? successMessage,
    SuggestionStatus? filterStatus,
    SuggestionType? filterType,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearFilterStatus = false,
    bool clearFilterType = false,
  }) {
    return SuggestionState(
      suggestions: suggestions ?? this.suggestions,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      filterStatus:
          clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
    );
  }

  @override
  List<Object?> get props => [
        suggestions,
        status,
        errorMessage,
        successMessage,
        filterStatus,
        filterType,
      ];
}
