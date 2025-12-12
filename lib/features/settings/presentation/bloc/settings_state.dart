import 'package:equatable/equatable.dart';

import '../../domain/entities/app_settings.dart';

/// Status enum for settings operations
enum SettingsStateStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  uploading,
  uploaded,
  error,
}

/// State class for settings bloc
class SettingsState extends Equatable {
  final SettingsStateStatus status;
  final AppSettings settings;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.status = SettingsStateStatus.initial,
    this.settings = const AppSettings(),
    this.errorMessage,
    this.successMessage,
  });

  /// Initial state
  const SettingsState.initial() : this();

  /// Copy with method for immutable updates
  SettingsState copyWith({
    SettingsStateStatus? status,
    AppSettings? settings,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// Check if currently loading
  bool get isLoading => status == SettingsStateStatus.loading;

  /// Check if currently saving
  bool get isSaving => status == SettingsStateStatus.saving;

  /// Check if currently uploading
  bool get isUploading => status == SettingsStateStatus.uploading;

  /// Check if any operation is in progress
  bool get isProcessing => isLoading || isSaving || isUploading;

  /// Check if there's an error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Check if there's a success message
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;

  /// Check if settings are loaded
  bool get isLoaded => status == SettingsStateStatus.loaded ||
      status == SettingsStateStatus.saved ||
      status == SettingsStateStatus.uploaded;

  @override
  List<Object?> get props => [
        status,
        settings,
        errorMessage,
        successMessage,
      ];

  @override
  String toString() => 'SettingsState(status: $status)';
}
