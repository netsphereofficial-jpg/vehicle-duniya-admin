import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Result of a highest bid API call
class MetaBidResult {
  final bool success;
  final double? amount;
  final String? errorMessage;

  const MetaBidResult({
    required this.success,
    this.amount,
    this.errorMessage,
  });
}

/// Service for calling Meta Portal API to get highest bids
class MetaApiService {
  // Production API keys for each organizer
  static const Map<String, String> _apiKeys = {
    'LNT': 'edf3ba542b70de89ffba5c9bc66aa371',
    'TCF': 'e638d0e6b05cedc9671248a7c09df42c',
    'MNBAF': 'a6839478964e88145ba023cb8a94b66c',
    'HDBF': '03564bda10c087e2ba7a8506e3a7a5cc',
    'CWCF': '77c93d3c8dd7d0dc48c0dbde91af1f77',
  };

  // Production Meta Portal API base URL
  static const String _baseUrl = 'https://metaportal.in/api/platform/v1';

  /// Get the API key for an organizer
  static String? getApiKey(String organizer) {
    return _apiKeys[organizer.toUpperCase()];
  }

  /// Check if organizer is a Meta-compatible type
  static bool isMetaOrganizer(String organizer) {
    return _apiKeys.containsKey(organizer.toUpperCase());
  }

  /// Get all supported organizers
  static List<String> get supportedOrganizers => _apiKeys.keys.toList();

  /// Fetch highest bid for a specific event and contract number
  /// API: GET /bid/getMaxBidAmountByEventIdAndLoanNo/{eventId}/{contractNo}
  Future<MetaBidResult> getHighestBid({
    required String organizer,
    required String eventId,
    required String contractNo,
  }) async {
    final apiKey = getApiKey(organizer);
    if (apiKey == null) {
      return const MetaBidResult(
        success: false,
        errorMessage: 'Invalid organizer type',
      );
    }

    if (eventId.isEmpty || contractNo.isEmpty) {
      return const MetaBidResult(
        success: false,
        errorMessage: 'Event ID and Contract No are required',
      );
    }

    try {
      final url =
          '$_baseUrl/bid/getMaxBidAmountByEventIdAndLoanNo/$eventId/$contractNo';

      developer.log('[MetaAPI] Calling: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'auth_key': apiKey,
        },
      ).timeout(const Duration(seconds: 10));

      developer.log('[MetaAPI] Response status: ${response.statusCode}');
      developer.log('[MetaAPI] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse response based on Meta Portal API format
        if (data['status'] == 200 || data['success'] == true) {
          final amount = _parseAmount(data['data'] ??
              data['amount'] ??
              data['maxBidAmount'] ??
              data['highestBidAmount']);
          developer.log('[MetaAPI] Parsed amount: $amount');
          return MetaBidResult(
            success: true,
            amount: amount,
          );
        }

        developer.log('[MetaAPI] API returned error: ${data['message']}');
        return MetaBidResult(
          success: false,
          errorMessage: data['message'] ?? 'Failed to fetch bid',
        );
      } else {
        developer.log('[MetaAPI] Server error: ${response.statusCode}');
        return MetaBidResult(
          success: false,
          errorMessage: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log('[MetaAPI] Network error: $e');
      return MetaBidResult(
        success: false,
        errorMessage: 'Network error: $e',
      );
    }
  }

  /// Parse amount from various possible response formats
  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is Map) {
      // Handle nested response like {highestBidAmount: 123456}
      return _parseAmount(value['amount'] ??
          value['maxBidAmount'] ??
          value['highestBidAmount'] ??
          value['bidAmount']);
    }
    return 0.0;
  }
}
