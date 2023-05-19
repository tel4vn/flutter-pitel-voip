import 'package:flutter/material.dart';
import 'package:plugin_pitel/sip/src/sip_ua_helper.dart';
import 'dart:math' as math;

import 'call_page.dart';

class CallScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Color bgColor;
  final PitelCallStateEnum callState;

  const CallScreen({
    Key? key,
    required this.goBack,
    required this.bgColor,
    required this.callState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: bgColor,
        child: CallPageWidget(
          goBack: goBack,
          callState: callState,
        ),
      ),
    );
  }
}
