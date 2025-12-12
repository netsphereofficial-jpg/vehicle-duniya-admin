import 'package:equatable/equatable.dart';

/// Status of a suggestion/complaint
enum SuggestionStatus {
  pending,
  inProgress,
  resolved,
  closed,
}

/// Type of submission
enum SuggestionType {
  suggestion,
  complaint,
  feedback,
}

/// Extension for SuggestionStatus
extension SuggestionStatusX on SuggestionStatus {
  String get label {
    switch (this) {
      case SuggestionStatus.pending:
        return 'Pending';
      case SuggestionStatus.inProgress:
        return 'In Progress';
      case SuggestionStatus.resolved:
        return 'Resolved';
      case SuggestionStatus.closed:
        return 'Closed';
    }
  }

  String get description {
    switch (this) {
      case SuggestionStatus.pending:
        return 'Awaiting review';
      case SuggestionStatus.inProgress:
        return 'Being addressed';
      case SuggestionStatus.resolved:
        return 'Issue resolved';
      case SuggestionStatus.closed:
        return 'No action needed';
    }
  }
}

/// Extension for SuggestionType
extension SuggestionTypeX on SuggestionType {
  String get label {
    switch (this) {
      case SuggestionType.suggestion:
        return 'Suggestion';
      case SuggestionType.complaint:
        return 'Complaint';
      case SuggestionType.feedback:
        return 'Feedback';
    }
  }
}

/// Suggestion/Complaint entity from mobile users
class Suggestion extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String fullName;
  final String phone;
  final String? email;
  final SuggestionType type;
  final String subject;
  final String message;
  final SuggestionStatus status;
  final String? adminNotes;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const Suggestion({
    required this.id,
    required this.userId,
    required this.userName,
    required this.fullName,
    required this.phone,
    this.email,
    required this.type,
    required this.subject,
    required this.message,
    required this.status,
    this.adminNotes,
    this.resolvedBy,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  /// Check if suggestion is open (can be updated)
  bool get isOpen =>
      status == SuggestionStatus.pending ||
      status == SuggestionStatus.inProgress;

  /// Check if suggestion is closed
  bool get isClosed =>
      status == SuggestionStatus.resolved ||
      status == SuggestionStatus.closed;

  /// Get formatted phone with +91
  String get formattedPhone => phone.startsWith('+91') ? phone : '+91 $phone';

  /// Copy with method
  Suggestion copyWith({
    String? id,
    String? userId,
    String? userName,
    String? fullName,
    String? phone,
    String? email,
    SuggestionType? type,
    String? subject,
    String? message,
    SuggestionStatus? status,
    String? adminNotes,
    String? resolvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return Suggestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        fullName,
        phone,
        email,
        type,
        subject,
        message,
        status,
        adminNotes,
        resolvedBy,
        createdAt,
        updatedAt,
        resolvedAt,
      ];
}
