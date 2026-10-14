import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A copy of the save in the player's iCloud (key-value storage), on iPhone
/// and iPad: back after deleting the app, and shared by the player's Apple
/// devices. Native side: ios/Runner/AppDelegate.swift. Android has Google's
/// Auto Backup instead (android/app/src/main/res/xml/), which needs no code.
class CloudSave {
  static const _channel = MethodChannel('adadi/cloud');
  static const _key = 'adadi.save';

  const CloudSave();

  bool get available => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<String?> read() async {
    if (!available) return null;
    try {
      return await _channel.invokeMethod<String>('get', {'key': _key});
    } on Object catch (e) {
      debugPrint('iCloud read: $e');
      return null;
    }
  }

  Future<void> write(String save) async {
    if (!available) return;
    try {
      await _channel.invokeMethod<void>('set', {'key': _key, 'value': save});
    } on Object catch (e) {
      debugPrint('iCloud write: $e');
    }
  }
}
