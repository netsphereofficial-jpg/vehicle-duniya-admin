import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/app_settings_model.dart';

/// Implementation of SettingsRepository using Firebase
class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // Single document for all settings - efficient and atomic
  static const String _collection = 'app_config';
  static const String _documentId = 'settings';
  static const String _storagePath = 'app_config/payment';

  SettingsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  DocumentReference get _settingsDoc =>
      _firestore.collection(_collection).doc(_documentId);

  @override
  Future<AppSettings> getSettings() async {
    final doc = await _settingsDoc.get();
    return AppSettingsModel.fromFirestore(doc);
  }

  @override
  Stream<AppSettings> watchSettings() {
    return _settingsDoc.snapshots().map(
          (doc) => AppSettingsModel.fromFirestore(doc),
        );
  }

  @override
  Future<void> updateGeneralSettings({
    required String officeAddress,
    required String phone,
    required String email,
    required String fax,
  }) async {
    await _settingsDoc.set(
      {
        'officeAddress': officeAddress,
        'phone': phone,
        'email': email,
        'fax': fax,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateAboutUs(String aboutUs) async {
    await _settingsDoc.set(
      {
        'aboutUs': aboutUs,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateBiddingTerms(String biddingTerms) async {
    await _settingsDoc.set(
      {
        'biddingTerms': biddingTerms,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updatePaymentSettings({
    required bool paymentPageEnabled,
    required String paymentQrCodeUrl,
  }) async {
    await _settingsDoc.set(
      {
        'paymentPageEnabled': paymentPageEnabled,
        'paymentQrCodeUrl': paymentQrCodeUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateAppVersion({
    required String appVersion,
    required String minAppVersion,
    required bool forceUpdate,
  }) async {
    await _settingsDoc.set(
      {
        'appVersion': appVersion,
        'minAppVersion': minAppVersion,
        'forceUpdate': forceUpdate,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateSocialLinks(SocialLinks socialLinks) async {
    await _settingsDoc.set(
      {
        'socialLinks': SocialLinksModel.fromEntity(socialLinks).toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<String> uploadPaymentQrCode(
    List<int> imageBytes,
    String fileName,
  ) async {
    final ext = fileName.split('.').last.toLowerCase();
    final ref = _storage.ref().child('$_storagePath/qr_code.$ext');

    // Convert List<int> to Uint8List for Firebase Storage
    final data = Uint8List.fromList(imageBytes);

    await ref.putData(
      data,
      SettableMetadata(contentType: 'image/$ext'),
    );

    return await ref.getDownloadURL();
  }

  @override
  Future<void> deletePaymentQrCode(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Ignore deletion errors (file might not exist)
    }
  }
}
