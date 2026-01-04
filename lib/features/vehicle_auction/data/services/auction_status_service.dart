import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/utils/app_logger.dart';

/// Service to trigger auction status updates
class AuctionStatusService {
  static const _tag = 'AuctionStatusService';

  // Cloud Function URL
  static const String _triggerUrl =
      'https://asia-south1-vehicle-duniya-198e5.cloudfunctions.net/triggerAuctionStatusUpdate';

  /// Trigger immediate auction status update
  /// Returns the number of auctions updated or -1 on error
  static Future<int> triggerStatusUpdate() async {
    try {
      AppLogger.info(_tag, 'Triggering auction status update...');

      final response = await http.get(
        Uri.parse(_triggerUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final upcomingToLive = data['upcomingToLive'] ?? 0;
        final liveToEnded = data['liveToEnded'] ?? 0;
        final total = upcomingToLive + liveToEnded;

        if (total > 0) {
          AppLogger.info(
            _tag,
            'Status update complete: $upcomingToLive upcoming→live, $liveToEnded live→ended',
          );
        } else {
          AppLogger.debug(_tag, 'No auctions needed status update');
        }

        return total;
      } else {
        AppLogger.warning(
          _tag,
          'Status update failed: ${response.statusCode} - ${response.body}',
        );
        return -1;
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to trigger status update', e);
      return -1;
    }
  }
}
