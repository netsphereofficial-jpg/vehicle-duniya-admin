import 'package:equatable/equatable.dart';

import '../../domain/entities/kyc_document.dart';

/// Data loading status
enum KycStatus { initial, loading, loaded, error }

/// KYC documents state
class KycState extends Equatable {
  final List<KycDocument> documents;
  final List<KycDocument> filteredDocuments;
  final KycDocument? selectedDocument;
  final KycStatus status;
  final String? errorMessage;
  final String searchQuery;
  final int totalCount;
  final bool hasMore;
  final String? lastDocumentId;

  const KycState({
    this.documents = const [],
    this.filteredDocuments = const [],
    this.selectedDocument,
    this.status = KycStatus.initial,
    this.errorMessage,
    this.searchQuery = '',
    this.totalCount = 0,
    this.hasMore = true,
    this.lastDocumentId,
  });

  /// Check if currently loading
  bool get isLoading => status == KycStatus.loading;

  /// Check if has error
  bool get hasError => status == KycStatus.error;

  /// Check if data is loaded
  bool get isLoaded => status == KycStatus.loaded;

  /// Get documents to display (filtered if search active)
  List<KycDocument> get displayDocuments =>
      searchQuery.isNotEmpty ? filteredDocuments : documents;

  /// Stats
  int get totalDocuments => documents.length;
  int get documentsWithAadhaar =>
      documents.where((d) => d.hasAadhaar).length;
  int get documentsWithPan => documents.where((d) => d.hasPan).length;
  int get documentsWithBoth =>
      documents.where((d) => d.hasAadhaar && d.hasPan).length;

  KycState copyWith({
    List<KycDocument>? documents,
    List<KycDocument>? filteredDocuments,
    KycDocument? selectedDocument,
    bool clearSelectedDocument = false,
    KycStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    int? totalCount,
    bool? hasMore,
    String? lastDocumentId,
  }) {
    return KycState(
      documents: documents ?? this.documents,
      filteredDocuments: filteredDocuments ?? this.filteredDocuments,
      selectedDocument: clearSelectedDocument
          ? null
          : (selectedDocument ?? this.selectedDocument),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      lastDocumentId: lastDocumentId ?? this.lastDocumentId,
    );
  }

  @override
  List<Object?> get props => [
        documents,
        filteredDocuments,
        selectedDocument,
        status,
        errorMessage,
        searchQuery,
        totalCount,
        hasMore,
        lastDocumentId,
      ];
}
