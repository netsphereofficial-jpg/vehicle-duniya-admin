import 'package:equatable/equatable.dart';

/// KYC document events
sealed class KycEvent extends Equatable {
  const KycEvent();

  @override
  List<Object?> get props => [];
}

/// Load KYC documents
class LoadKycDocuments extends KycEvent {
  const LoadKycDocuments();
}

/// Subscribe to real-time KYC updates
class SubscribeToKycDocuments extends KycEvent {
  const SubscribeToKycDocuments();
}

/// Search KYC documents
class SearchKycDocuments extends KycEvent {
  final String query;

  const SearchKycDocuments(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search
class ClearKycSearch extends KycEvent {
  const ClearKycSearch();
}

/// Select KYC document for detail view
class SelectKycDocument extends KycEvent {
  final String? documentId;

  const SelectKycDocument(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Delete KYC document
class DeleteKycDocument extends KycEvent {
  final String documentId;

  const DeleteKycDocument(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Load more documents (pagination)
class LoadMoreKycDocuments extends KycEvent {
  const LoadMoreKycDocuments();
}

/// Update documents from stream (internal event)
class KycDocumentsUpdated extends KycEvent {
  final List<dynamic> documents;

  const KycDocumentsUpdated(this.documents);

  @override
  List<Object?> get props => [documents];
}
