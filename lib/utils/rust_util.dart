import 'dart:async';

import 'package:moodiary/src/rust/frb_generated.dart';
import 'package:moodiary/utils/log_util.dart';

class RustUtil {
  static bool _isInitialized = false;
  static Completer<void>? _initCompleter;

  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    if (_isInitialized) return;

    _initCompleter ??= Completer<void>();

    try {
      await RustLib.init();
      _isInitialized = true;
      if (!_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
      logger.i('RustLib initialized successfully');
    } catch (e) {
      logger.e('RustLib init failed', error: e);
      if (!_initCompleter!.isCompleted) {
        _initCompleter!.completeError(e);
      }
    }
  }

  static Future<bool> waitForInit({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (_isInitialized) return true;

    if (_initCompleter == null) {
      return false;
    }

    try {
      await _initCompleter!.future.timeout(timeout);
      return true;
    } catch (e) {
      logger.i('Timeout waiting for RustLib init');
      return false;
    }
  }
}
