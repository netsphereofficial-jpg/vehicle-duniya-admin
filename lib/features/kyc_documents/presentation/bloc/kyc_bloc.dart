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

    // TODO: Remove dummy data and uncomment real subscription
    // For testing UI - load dummy data
    await Future.delayed(const Duration(milliseconds: 500));
    add(KycDocumentsUpdated(_getDummyDocuments()));
    return;

    // Real subscription (commented for testing)
    // await _documentsSubscription?.cancel();
    // _documentsSubscription = _repository.watchKycDocuments().listen(
    //   (documents) {
    //     add(KycDocumentsUpdated(documents));
    //   },
    //   onError: (error) {
    //     add(const KycDocumentsUpdated([]));
    //   },
    // );
  }

  /// Dummy data for UI testing - REMOVE IN PRODUCTION
  List<KycDocument> _getDummyDocuments() {
    return [
      KycDocument(
        id: '1',
        userId: 'user1',
        userName: 'Rajesh Kumar',
        userPhone: '9876543210',
        userAddress: '123, MG Road, Bangalore, Karnataka - 560001',
        aadhaarNumber: '234567891234',
        aadhaarFrontUrl: 'https://picsum.photos/seed/aadhaar1f/400/250',
        aadhaarBackUrl: 'https://picsum.photos/seed/aadhaar1b/400/250',
        panNumber: 'ABCDE1234F',
        panFrontUrl: 'https://picsum.photos/seed/pan1f/400/250',
        panBackUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      KycDocument(
        id: '2',
        userId: 'user2',
        userName: 'Priya Sharma',
        userPhone: '9123456789',
        userAddress: '456, Park Street, Kolkata, West Bengal - 700016',
        aadhaarNumber: '876543219876',
        aadhaarFrontUrl: 'https://picsum.photos/seed/aadhaar2f/400/250',
        aadhaarBackUrl: 'https://picsum.photos/seed/aadhaar2b/400/250',
        panNumber: 'FGHIJ5678K',
        panFrontUrl: 'https://picsum.photos/seed/pan2f/400/250',
        panBackUrl: 'https://picsum.photos/seed/pan2b/400/250',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      KycDocument(
        id: '3',
        userId: 'user3',
        userName: 'Amit Patel',
        userPhone: '8765432109',
        userAddress: '789, SG Highway, Ahmedabad, Gujarat - 380015',
        aadhaarNumber: '543216789012',
        aadhaarFrontUrl: 'https://picsum.photos/seed/aadhaar3f/400/250',
        aadhaarBackUrl: null,
        panNumber: null,
        panFrontUrl: null,
        panBackUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      KycDocument(
        id: '4',
        userId: 'user4',
        userName: 'Sneha Reddy',
        userPhone: '7654321098',
        userAddress: '321, Jubilee Hills, Hyderabad, Telangana - 500033',
        aadhaarNumber: null,
        aadhaarFrontUrl: null,
        aadhaarBackUrl: null,
        panNumber: 'KLMNO9012P',
        panFrontUrl: 'https://picsum.photos/seed/pan4f/400/250',
        panBackUrl: 'https://picsum.photos/seed/pan4b/400/250',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      KycDocument(
        id: '5',
        userId: 'user5',
        userName: 'Vikram Singh',
        userPhone: '6543210987',
        userAddress: '654, Civil Lines, Jaipur, Rajasthan - 302006',
        aadhaarNumber: '123498765432',
        aadhaarFrontUrl: 'https://picsum.photos/seed/aadhaar5f/400/250',
        aadhaarBackUrl: 'https://picsum.photos/seed/aadhaar5b/400/250',
        panNumber: 'PQRST3456U',
        panFrontUrl: 'https://picsum.photos/seed/pan5f/400/250',
        panBackUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      KycDocument(
        id: '6',
        userId: 'user6',
        userName: 'Ananya Iyer',
        userPhone: '5432109876',
        userAddress: '987, T Nagar, Chennai, Tamil Nadu - 600017',
        aadhaarNumber: '987612345678',
        aadhaarFrontUrl: 'https://picsum.photos/seed/aadhaar6f/400/250',
        aadhaarBackUrl: 'https://picsum.photos/seed/aadhaar6b/400/250',
        panNumber: 'UVWXY7890Z',
        panFrontUrl: 'https://picsum.photos/seed/pan6f/400/250',
        panBackUrl: 'https://picsum.photos/seed/pan6b/400/250',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
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
