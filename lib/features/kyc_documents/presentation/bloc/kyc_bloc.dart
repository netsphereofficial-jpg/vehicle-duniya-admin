import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/kyc_document.dart';
import '../../domain/repositories/kyc_repository.dart';
import 'kyc_event.dart';
import 'kyc_state.dart';

/// BLoC for managing KYC documents
class KycBloc extends Bloc<KycEvent, KycState> {
  final KycRepository _repository;
  StreamSubscription<List<KycDocument>>? _documentsSubscription;

  KycBloc({required KycRepository repository})
      : _repository = repository,
        super(const KycState()) {
    on<LoadKycDocuments>(_onLoadDocuments);
    on<SubscribeToKycDocuments>(_onSubscribe);
    on<SearchKycDocuments>(_onSearch);
    on<ClearKycSearch>(_onClearSearch);
    on<SelectKycDocument>(_onSelectDocument);
    on<DeleteKycDocument>(_onDeleteDocument);
    on<LoadMoreKycDocuments>(_onLoadMore);
    on<KycDocumentsUpdated>(_onDocumentsUpdated);
  }

  Future<void> _onLoadDocuments(
    LoadKycDocuments event,
    Emitter<KycState> emit,
  ) async {
    emit(state.copyWith(status: KycStatus.loading));

    try {
      final documents = await _repository.getKycDocuments();
      final totalCount = await _repository.getTotalCount();

      emit(state.copyWith(
        documents: documents,
        status: KycStatus.loaded,
        totalCount: totalCount,
        hasMore: documents.length >= 50,
        lastDocumentId: documents.isNotEmpty ? documents.last.id : null,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: KycStatus.error,
        errorMessage: 'Failed to load documents: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSubscribe(
    SubscribeToKycDocuments event,
    Emitter<KycState> emit,
  ) async {
    emit(state.copyWith(status: KycStatus.loading));

    await _documentsSubscription?.cancel();
    _documentsSubscription = _repository.watchKycDocuments().listen(
      (documents) {
        add(KycDocumentsUpdated(documents));
      },
      onError: (error) {
        add(const KycDocumentsUpdated([]));
      },
    );
  }

  void _onDocumentsUpdated(
    KycDocumentsUpdated event,
    Emitter<KycState> emit,
  ) {
    final documents = event.documents.cast<KycDocument>();

    // If there's an active search, filter the updated documents
    List<KycDocument> filteredDocs = [];
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filteredDocs = documents
          .where((doc) =>
              doc.userName.toLowerCase().contains(query) ||
              doc.userPhone.contains(query) ||
              (doc.panNumber?.toLowerCase().contains(query) ?? false) ||
              (doc.aadhaarNumber?.contains(query) ?? false))
          .toList();
    }

    emit(state.copyWith(
      documents: documents,
      filteredDocuments: filteredDocs,
      status: KycStatus.loaded,
      totalCount: documents.length,
      clearError: true,
    ));
  }

  Future<void> _onSearch(
    SearchKycDocuments event,
    Emitter<KycState> emit,
  ) async {
    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredDocuments: [],
      ));
      return;
    }

    final filtered = state.documents
        .where((doc) =>
            doc.userName.toLowerCase().contains(query) ||
            doc.userPhone.contains(query) ||
            (doc.panNumber?.toLowerCase().contains(query) ?? false) ||
            (doc.aadhaarNumber?.contains(query) ?? false))
        .toList();

    emit(state.copyWith(
      searchQuery: event.query,
      filteredDocuments: filtered,
    ));
  }

  void _onClearSearch(
    ClearKycSearch event,
    Emitter<KycState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      filteredDocuments: [],
    ));
  }

  void _onSelectDocument(
    SelectKycDocument event,
    Emitter<KycState> emit,
  ) {
    if (event.documentId == null) {
      emit(state.copyWith(clearSelectedDocument: true));
      return;
    }

    final document = state.documents.firstWhere(
      (d) => d.id == event.documentId,
      orElse: () => state.documents.first,
    );

    emit(state.copyWith(selectedDocument: document));
  }

  Future<void> _onDeleteDocument(
    DeleteKycDocument event,
    Emitter<KycState> emit,
  ) async {
    try {
      await _repository.deleteKycDocument(event.documentId);

      // If using real-time stream, the update will come automatically
      // Otherwise, remove locally
      final updatedDocuments =
          state.documents.where((d) => d.id != event.documentId).toList();

      emit(state.copyWith(
        documents: updatedDocuments,
        totalCount: state.totalCount - 1,
        clearSelectedDocument:
            state.selectedDocument?.id == event.documentId,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete document: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreKycDocuments event,
    Emitter<KycState> emit,
  ) async {
    if (!state.hasMore || state.isLoading) return;

    try {
      final moreDocuments = await _repository.getKycDocuments(
        lastDocumentId: state.lastDocumentId,
      );

      final allDocuments = [...state.documents, ...moreDocuments];

      emit(state.copyWith(
        documents: allDocuments,
        hasMore: moreDocuments.length >= 50,
        lastDocumentId:
            moreDocuments.isNotEmpty ? moreDocuments.last.id : state.lastDocumentId,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load more documents: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    _documentsSubscription?.cancel();
    return super.close();
  }
}
