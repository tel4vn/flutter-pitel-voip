import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:plugin_pitel/component/pitel_rtc_video_renderer.dart';

class PitelRTCVideoView extends RTCVideoView {
  PitelRTCVideoView(PitelRTCVideoRenderer renderer, {Key? key})
      : super(renderer, key: key);
}
