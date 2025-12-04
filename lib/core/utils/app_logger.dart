import 'package:flutter/foundation.dart';

/// Simple structured logging utility for the admin panel
/// Only logs in debug mode to avoid exposing sensitive data in production
class AppLogger {
  static const String _appName = 'VehicleDuniya';

  /// Log an info message
  static void info(String tag, String message) {
    _log('INFO', tag, message);
  }

  /// Log a debug message
  static void debug(String tag, String message) {
    _log('DEBUG', tag, message);
  }

  /// Log a warning message
  static void warning(String tag, String message) {
    _log('WARNING', tag, message);
  }

  /// Log an error message with optional error object and stack trace
  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', tag, message);
    if (error != null && kDebugMode) {
      debugPrint('[$_appName] ERROR Details: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('[$_appName] Stack Trace:\n$stackTrace');
    }
  }

  /// Log BLoC event
  static void blocEvent(String blocName, String eventName) {
    _log('BLOC', blocName, 'Event: $eventName');
  }

  /// Log BLoC state change
  static void blocState(String blocName, String fromState, String toState) {
    _log('BLOC', blocName, 'State: $fromState → $toState');
  }

  /// Log API call
  static void api(String method, String endpoint, {Map<String, dynamic>? params}) {
    final paramsStr = params != null ? ' | Params: $params' : '';
    _log('API', method.toUpperCase(), '$endpoint$paramsStr');
  }

  /// Log Firebase operation
  static void firebase(String operation, String collection, {String? docId}) {
    final docStr = docId != null ? '/$docId' : '';
    _log('FIREBASE', operation, '$collection$docStr');
  }

  static void _log(String level, String tag, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String().substring(11, 23);
      debugPrint('[$timestamp] [$_appName] [$level] [$tag] $message');
    }
  }
}
