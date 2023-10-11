import 'package:flutter/material.dart';
import 'package:flutter_pitel_voip/config/pitel_config.dart';

class PitelLog {
  PitelLog({required String tag}) : _tag = tag;
  final String _tag;

  void error(dynamic message) {
    if (PitelConfigure.isDebug) {
      debugPrint('PitelLogError - $_tag, $message');
    }
  }

  void info(dynamic message) {
    if (PitelConfigure.isDebug) {
      debugPrint('PitelLogInfo - $_tag, $message');
    }
  }
}
