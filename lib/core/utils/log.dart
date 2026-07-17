import 'package:flutter/foundation.dart';

void logDebug(String message) {
  if (!kReleaseMode) {
    debugPrint(message);
  }
}
