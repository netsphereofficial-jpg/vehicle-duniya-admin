import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/suggestion.dart';
import '../../domain/repositories/suggestion_repository.dart';
import 'suggestion_event.dart';
import 'suggestion_state.dart';

/// BLoC for suggestion box management
class SuggestionBloc extends Bloc<SuggestionEvent, SuggestionState> {
  final SuggestionRepository _repository;
  StreamSubscription? _suggestionsSubscription;

  SuggestionBloc({required SuggestionRepository repository})
      : _repository = repository,
        super(const SuggestionState()) {
    on<SuggestionDataRequested>(_onDataRequested);
    on<SuggestionsStreamUpdated>(_onStreamUpdated);
    on<UpdateSuggestionStatusRequested>(_onUpdateStatus);
    on<AddAdminNotesRequested>(_onAddNotes);
    on<DeleteSuggestionRequested>(_onDelete);
    on<ClearSuggestionMessage>(_onClearMessage);
    on<FilterByStatusRequested>(_onFilterByStatus);
    on<FilterByTypeRequested>(_onFilterByType);
  }

  /// Handle data requested
  Future<void> _onDataRequested(
    SuggestionDataRequested event,
    Emitter<SuggestionState> emit,
  ) async {
    emit(state.copyWith(status: SuggestionLoadStatus.loading));

    await _suggestionsSubscription?.cancel();
    _suggestionsSubscription = _repository.watchSuggestions().listen(
          (suggestions) => add(SuggestionsStreamUpdated(suggestions)),
          onError: (error) => emit(state.copyWith(
            status: SuggestionLoadStatus.error,
            errorMessage: 'Failed to load suggestions: $error',
          )),
        );
  }

  /// Handle stream updated
  void _onStreamUpdated(
    SuggestionsStreamUpdated event,
    Emitter<SuggestionState> emit,
  ) {
    emit(state.copyWith(
      suggestions: event.suggestions,
      status: SuggestionLoadStatus.loaded,
    ));
  }

  /// Handle update status
  Future<void> _onUpdateStatus(
    UpdateSuggestionStatusRequested event,
    Emitter<SuggestionState> emit,
  ) async {
    emit(state.copyWith(status: SuggestionLoadStatus.updating));

    try {
      await _repository.updateStatus(
        suggestionId: event.suggestionId,
        status: event.status,
        adminNotes: event.adminNotes,
      );

      emit(state.copyWith(
        status: SuggestionLoadStatus.loaded,
        successMessage: 'Status updated to ${event.status.label}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SuggestionLoadStatus.loaded,
        errorMessage: 'Failed to update status: $e',
      ));
    }
  }

  /// Handle add notes
  Future<void> _onAddNotes(
    AddAdminNotesRequested event,
    Emitter<SuggestionState> emit,
  ) async {
    emit(state.copyWith(status: SuggestionLoadStatus.updating));

    try {
      await _repository.addAdminNotes(
        suggestionId: event.suggestionId,
        notes: event.notes,
      );

      emit(state.copyWith(
        status: SuggestionLoadStatus.loaded,
        successMessage: 'Notes added successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SuggestionLoadStatus.loaded,
        errorMessage: 'Failed to add notes: $e',
      ));
    }
  }

  /// Handle delete
  Future<void> _onDelete(
    DeleteSuggestionRequested event,
    Emitter<SuggestionState> emit,
  ) async {
    emit(state.copyWith(status: SuggestionLoadStatus.updating));

    try {
      await _repository.deleteSuggestion(event.suggestionId);

      emit(state.copyWith(
        status: SuggestionLoadStatus.loaded,
        successMessage: 'Suggestion deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SuggestionLoadStatus.loaded,
        errorMessage: 'Failed to delete: $e',
      ));
    }
  }

  /// Handle clear message
  void _onClearMessage(
    ClearSuggestionMessage event,
    Emitter<SuggestionState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  /// Handle filter by status
  void _onFilterByStatus(
    FilterByStatusRequested event,
    Emitter<SuggestionState> emit,
  ) {
    if (event.status == null) {
      emit(state.copyWith(clearFilterStatus: true));
    } else {
      emit(state.copyWith(filterStatus: event.status));
    }
  }

  /// Handle filter by type
  void _onFilterByType(
    FilterByTypeRequested event,
    Emitter<SuggestionState> emit,
  ) {
    if (event.type == null) {
      emit(state.copyWith(clearFilterType: true));
    } else {
      emit(state.copyWith(filterType: event.type));
    }
  }

  @override
  Future<void> close() {
    _suggestionsSubscription?.cancel();
    return super.close();
  }
}
