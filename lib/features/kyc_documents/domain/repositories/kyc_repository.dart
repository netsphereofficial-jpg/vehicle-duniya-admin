import '../entities/kyc_document.dart';

/// Repository interface for KYC documents
abstract class KycRepository {
  /// Watch all KYC documents (real-time stream)
  Stream<List<KycDocument>> watchKycDocuments();

  /// Get KYC documents with pagination
  Future<List<KycDocument>> getKycDocuments({
    int limit = 50,
    String? lastDocumentId,
  });

  /// Get KYC document by ID
  Future<KycDocument?> getKycDocumentById(String id);

  /// Get KYC document by user ID
  Future<KycDocument?> getKycDocumentByUserId(String userId);

  /// Search KYC documents
  Future<List<KycDocument>> searchKycDocuments(String query);

  /// Get total KYC documents count
  Future<int> getTotalCount();

  /// Delete KYC document
  Future<void> deleteKycDocument(String id);
}
