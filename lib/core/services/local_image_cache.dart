import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching images locally to avoid CORS issues with Firebase Storage
class LocalImageCache {
  static const String _prefix = 'cached_image_';

  final SharedPreferences _prefs;

  LocalImageCache({required SharedPreferences prefs}) : _prefs = prefs;

  /// Cache image bytes with a key
  Future<void> cacheImage(String key, Uint8List bytes) async {
    final base64String = base64Encode(bytes);
    await _prefs.setString('$_prefix$key', base64String);
  }

  /// Get cached image bytes by key
  Uint8List? getCachedImage(String key) {
    final base64String = _prefs.getString('$_prefix$key');
    if (base64String == null) return null;

    try {
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  /// Check if image is cached
  bool hasImage(String key) {
    return _prefs.containsKey('$_prefix$key');
  }

  /// Remove cached image
  Future<void> removeImage(String key) async {
    await _prefs.remove('$_prefix$key');
  }

  /// Clear all cached images
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  /// Cache keys for settings images
  static const String paymentQrCodeKey = 'payment_qr_code';
}
