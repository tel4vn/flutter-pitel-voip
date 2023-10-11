import 'package:flutter_webrtc/flutter_webrtc.dart';

class PitelRTCVideoRenderer extends RTCVideoRenderer {
  bool isInit = false;

  @override
  Future<void> initialize() async {
    await super.initialize();
    isInit = true;
    return;
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    isInit = false;
    return;
  }
}
