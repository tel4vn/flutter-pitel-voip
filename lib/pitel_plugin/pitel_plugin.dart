import 'dart:async';

import 'package:flutter/services.dart';

class PitelPlugin {
  static const MethodChannel _channel = MethodChannel('flutter_pitel_voip');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
