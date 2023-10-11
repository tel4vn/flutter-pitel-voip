import 'dart:async';

import 'package:flutter/services.dart';

class PitelPlugin {
  static const MethodChannel _channel = MethodChannel('plugin_pitel');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
