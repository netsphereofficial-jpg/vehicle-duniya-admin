import '../entities/suggestion.dart';

/// Repository interface for suggestion box operations
abstract class SuggestionRepository {
  /// Watch all suggestions in real-time
  Stream<List<Suggestion>> watchSuggestions();

  /// Get suggestion by ID
  Future<Suggestion?> getSuggestionById(String id);

  /// Update suggestion status
  Future<void> updateStatus({
    required String suggestionId,
    required SuggestionStatus status,
    String? adminNotes,
    String? resolvedBy,
  });

  /// Add admin notes to suggestion
  Future<void> addAdminNotes({
    required String suggestionId,
    required String notes,
  });

  /// Delete suggestion
  Future<void> deleteSuggestion(String suggestionId);

  /// Get suggestions count by status
  Future<Map<SuggestionStatus, int>> getSuggestionsCountByStatus();
}
