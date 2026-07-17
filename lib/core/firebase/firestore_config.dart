import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> configureFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // Offline persistence improves load time on mobile/desktop.
  // Web uses its own caching strategy and may ignore these settings.
  if (!kIsWeb) {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 104857600,
    );
  }
}
