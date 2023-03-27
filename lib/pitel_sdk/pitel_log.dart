import 'package:flutter/material.dart';
import 'package:plugin_pitel/config/pitel_config.dart';

class PitelLog {
  PitelLog({required String tag}) : _TAG = tag;
  final String _TAG;

  void error(dynamic message) {
    if (PitelConfigure.isDebug) {
      debugPrint('PitelLogError - $_TAG, $message');
    }
  }

  void info(dynamic message) {
    if (PitelConfigure.isDebug) {
      debugPrint('PitelLogInfo - $_TAG, $message');
    }
  }
}
