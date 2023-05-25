import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugin_pitel/component/app_life_cycle/app_life_cycle.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_call.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_client.dart';
import 'package:plugin_pitel/voip_push/voip_notif.dart';

class PitelVoip extends StatefulWidget {
  final VoidCallback handleRegister;
  final VoidCallback handleRegisterCall;
  final Widget child;

  const PitelVoip({
    Key? key,
    required this.handleRegister,
    required this.child,
    required this.handleRegisterCall,
  }) : super(key: key);

  @override
  State<PitelVoip> createState() => _PitelVoipState();
}

class _PitelVoipState extends State<PitelVoip> {
  final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
  bool haveCall = false;

  @override
  void initState() {
    super.initState();
    VoipNotifService.listenerEvent(
      callback: (event) {},
      onCallAccept: () {
        setState(() {
          haveCall = true;
        });
        widget.handleRegisterCall();
      },
      onCallDecline: () {},
      onCallEnd: () {
        pitelCall.hangup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLifecycleTracker(
      didChangeAppState: (state) {
        if (Platform.isIOS && state == AppState.resumed && !haveCall) {
          widget.handleRegister();
        }
        if (Platform.isAndroid && state == AppState.resumed) {
          widget.handleRegister();
        }
        if (Platform.isAndroid && state == AppState.resumed) {
          if (!pitelCall.isConnected) {
            widget.handleRegister();
          }
        }
      },
      child: widget.child,
    );
  }
}
