import 'package:equatable/equatable.dart';

/// Document type enum
enum DocumentType {
  aadhaar,
  pan,
}

/// KYC Document entity
class KycDocument extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String? userAddress;

  // Aadhaar details
  final String? aadhaarNumber;
  final String? aadhaarFrontUrl;
  final String? aadhaarBackUrl;

  // PAN details
  final String? panNumber;
  final String? panFrontUrl;
  final String? panBackUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  const KycDocument({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userAddress,
    this.aadhaarNumber,
    this.aadhaarFrontUrl,
    this.aadhaarBackUrl,
    this.panNumber,
    this.panFrontUrl,
    this.panBackUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if has Aadhaar documents
  bool get hasAadhaar =>
      aadhaarFrontUrl != null ||
      aadhaarBackUrl != null ||
      (aadhaarNumber != null && aadhaarNumber!.isNotEmpty);

  /// Check if has PAN documents
  bool get hasPan =>
      panFrontUrl != null ||
      panBackUrl != null ||
      (panNumber != null && panNumber!.isNotEmpty);

  /// Get total document images count
  int get totalImages {
    int count = 0;
    if (aadhaarFrontUrl != null) count++;
    if (aadhaarBackUrl != null) count++;
    if (panFrontUrl != null) count++;
    if (panBackUrl != null) count++;
    return count;
  }

  /// Get all image URLs
  List<DocumentImage> get allImages {
    final images = <DocumentImage>[];
    if (aadhaarFrontUrl != null) {
      images.add(DocumentImage(
        url: aadhaarFrontUrl!,
        type: DocumentType.aadhaar,
        label: 'Aadhaar Front',
      ));
    }
    if (aadhaarBackUrl != null) {
      images.add(DocumentImage(
        url: aadhaarBackUrl!,
        type: DocumentType.aadhaar,
        label: 'Aadhaar Back',
      ));
    }
    if (panFrontUrl != null) {
      images.add(DocumentImage(
        url: panFrontUrl!,
        type: DocumentType.pan,
        label: 'PAN Front',
      ));
    }
    if (panBackUrl != null) {
      images.add(DocumentImage(
        url: panBackUrl!,
        type: DocumentType.pan,
        label: 'PAN Back',
      ));
    }
    return images;
  }

  /// Format phone number
  String get formattedPhone {
    if (userPhone.length == 10) {
      return '+91 ${userPhone.substring(0, 5)} ${userPhone.substring(5)}';
    }
    return userPhone;
  }

  /// Mask Aadhaar number (show last 4 digits)
  String get maskedAadhaar {
    if (aadhaarNumber == null || aadhaarNumber!.length < 4) {
      return aadhaarNumber ?? '-';
    }
    final lastFour = aadhaarNumber!.substring(aadhaarNumber!.length - 4);
    return 'XXXX XXXX $lastFour';
  }

  /// Format PAN number
  String get formattedPan => panNumber?.toUpperCase() ?? '-';

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userPhone,
        userAddress,
        aadhaarNumber,
        aadhaarFrontUrl,
        aadhaarBackUrl,
        panNumber,
        panFrontUrl,
        panBackUrl,
        createdAt,
        updatedAt,
      ];
}

/// Document image with metadata
class DocumentImage {
  final String url;
  final DocumentType type;
  final String label;

  const DocumentImage({
    required this.url,
    required this.type,
    required this.label,
  });
}
