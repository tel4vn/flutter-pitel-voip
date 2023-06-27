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
  final TextStyle? textStyle;

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
          textStyle: textStyle ?? const TextStyle(),
        ),
      ),
    );
  }
}
