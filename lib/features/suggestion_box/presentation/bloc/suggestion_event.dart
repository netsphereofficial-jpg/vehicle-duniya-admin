import 'package:equatable/equatable.dart';

import '../../domain/entities/suggestion.dart';

/// Base class for suggestion events
abstract class SuggestionEvent extends Equatable {
  const SuggestionEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load suggestions
class SuggestionDataRequested extends SuggestionEvent {
  const SuggestionDataRequested();
}

/// Suggestions stream updated
class SuggestionsStreamUpdated extends SuggestionEvent {
  final List<Suggestion> suggestions;

  const SuggestionsStreamUpdated(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

/// Request to update suggestion status
class UpdateSuggestionStatusRequested extends SuggestionEvent {
  final String suggestionId;
  final SuggestionStatus status;
  final String? adminNotes;

  const UpdateSuggestionStatusRequested({
    required this.suggestionId,
    required this.status,
    this.adminNotes,
  });

  @override
  List<Object?> get props => [suggestionId, status, adminNotes];
}

/// Request to add admin notes
class AddAdminNotesRequested extends SuggestionEvent {
  final String suggestionId;
  final String notes;

  const AddAdminNotesRequested({
    required this.suggestionId,
    required this.notes,
  });

  @override
  List<Object?> get props => [suggestionId, notes];
}

/// Request to delete suggestion
class DeleteSuggestionRequested extends SuggestionEvent {
  final String suggestionId;

  const DeleteSuggestionRequested(this.suggestionId);

  @override
  List<Object?> get props => [suggestionId];
}

/// Clear messages
class ClearSuggestionMessage extends SuggestionEvent {
  const ClearSuggestionMessage();
}

/// Filter suggestions by status
class FilterByStatusRequested extends SuggestionEvent {
  final SuggestionStatus? status;

  const FilterByStatusRequested(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter suggestions by type
class FilterByTypeRequested extends SuggestionEvent {
  final SuggestionType? type;

  const FilterByTypeRequested(this.type);

  @override
  List<Object?> get props => [type];
}
