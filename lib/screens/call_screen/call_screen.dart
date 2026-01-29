import 'package:flutter_pitel_voip/services/pitel_callstate_service.dart';
import 'package:flutter/material.dart';

import 'call_page.dart';

class CallScreen extends StatelessWidget {
  final Color bgColor;
  final String? txtMute;
  final String? txtUnMute;
  final String? txtSpeaker;
  final String? txtOutgoing;
  final String? txtIncoming;
  final String? txtHoldCall;
  final String? txtUnHoldCall;
  final String? txtTimer;
  final String? txtWaiting;
  final TextStyle? textStyle;
  final TextStyle? titleTextStyle;
  final TextStyle? timerTextStyle;
  final TextStyle? directionTextStyle;
  final bool showHoldCall;

  const CallScreen({
    Key? key,
    required this.bgColor,
    this.txtMute,
    this.txtUnMute,
    this.txtSpeaker,
    this.txtOutgoing,
    this.txtIncoming,
    this.txtHoldCall,
    this.txtUnHoldCall,
    this.textStyle,
    this.titleTextStyle,
    this.timerTextStyle,
    this.directionTextStyle,
    this.txtTimer,
    this.txtWaiting,
    this.showHoldCall = false,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PitelCallStateService(),
      builder: (context, child) {
        return Scaffold(
          body: Container(
            color: bgColor,
            child: CallPageWidget(
              txtMute: txtMute ?? 'Mute',
              txtUnMute: txtUnMute ?? 'Unmute',
              txtSpeaker: txtSpeaker ?? 'Speaker',
              txtOutgoing: txtOutgoing ?? 'Outgoing',
              txtIncoming: txtIncoming ?? 'Incoming',
              txtHoldCall: txtHoldCall ?? 'Hold call',
              txtUnHoldCall: txtUnHoldCall ?? 'Resume call',
              showHoldCall: showHoldCall,
              textStyle: textStyle ?? const TextStyle(),
              titleTextStyle: titleTextStyle ?? const TextStyle(),
              timerTextStyle: timerTextStyle ?? const TextStyle(),
              directionTextStyle: directionTextStyle ?? const TextStyle(),
              txtTimer: txtTimer ?? '',
              txtWaiting: txtWaiting ?? '00:00',
            ),
          ),
        );
      },
    );
  }
}
