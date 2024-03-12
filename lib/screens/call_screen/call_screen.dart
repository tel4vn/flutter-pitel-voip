import 'package:flutter/material.dart';
import 'package:plugin_pitel/sip/src/sip_ua_helper.dart';

import 'call_page.dart';

class CallScreen extends StatelessWidget {
  final Color bgColor;
  final PitelCallStateEnum callState;
  final String? txtMute;
  final String? txtUnMute;
  final String? txtSpeaker;
  final String? txtOutgoing;
  final String? txtIncoming;
  final String? txtTimer;
  final String? txtWaiting;
  final TextStyle? textStyle;
  final TextStyle? titleTextStyle;
  final TextStyle? timerTextStyle;
  final TextStyle? directionTextStyle;

  const CallScreen({
    Key? key,
    required this.bgColor,
    required this.callState,
    this.txtMute,
    this.txtUnMute,
    this.txtSpeaker,
    this.txtOutgoing,
    this.txtIncoming,
    this.textStyle,
    this.titleTextStyle,
    this.timerTextStyle,
    this.directionTextStyle,
    this.txtTimer,
    this.txtWaiting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: bgColor,
        child: CallPageWidget(
          callState: callState,
          txtMute: txtMute ?? 'Mute',
          txtUnMute: txtUnMute ?? 'Unmute',
          txtSpeaker: txtSpeaker ?? 'Speaker',
          txtOutgoing: txtOutgoing ?? 'Outgoing',
          txtIncoming: txtIncoming ?? 'Incoming',
          txtTimer: txtTimer ?? '',
          textStyle: textStyle ?? const TextStyle(),
          titleTextStyle: titleTextStyle ?? const TextStyle(),
          timerTextStyle: timerTextStyle ?? const TextStyle(),
          directionTextStyle: directionTextStyle ?? const TextStyle(),
          txtWaiting: txtWaiting ?? '00:00',
        ),
      ),
    );
  }
}
