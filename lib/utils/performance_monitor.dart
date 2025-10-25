import 'package:flutter/foundation.dart';

/// Performance monitoring utility to track main thread blocking operations.
///
/// This helps identify operations that shouldn't be running on the main thread
/// and ensures we follow the principle that only UI painting should block the main thread.
class PerformanceMonitor {
  static const Duration _mainThreadThreshold = Duration(milliseconds: 16);

  /// Wraps expensive operations and warns if they take too long on the main thread
  static T monitorMainThreadOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      final result = operation();
      stopwatch.stop();

      if (stopwatch.elapsed > _mainThreadThreshold) {
        debugPrint(
          '⚠️ PERFORMANCE WARNING: Operation "$operationName" took ${stopwatch.elapsed.inMilliseconds}ms on main thread',
        );
        debugPrint(
          '   This may cause frame drops. Consider moving to background isolate or caching.',
        );
      }

      return result;
    } else {
      return operation();
    }
  }

  /// Logs when expensive operations start to help track performance issues
  static void logExpensiveOperation(String operationName) {
    if (kDebugMode) {
      debugPrint('📊 Starting potentially expensive operation: $operationName');
    }
  }

  /// Logs successful completion of expensive operations
  static void logOperationComplete(String operationName, Duration elapsed) {
    if (kDebugMode) {
      debugPrint(
        '✅ Operation "$operationName" completed in ${elapsed.inMilliseconds}ms',
      );
    }
  }
}
