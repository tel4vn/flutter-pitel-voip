import 'dart:io';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pitel_voip/component/app_life_cycle/app_life_cycle.dart';
import 'package:flutter_pitel_voip/pitel_sdk/pitel_call.dart';
import 'package:flutter_pitel_voip/pitel_sdk/pitel_client.dart';
import 'package:flutter_pitel_voip/voip_push/voip_notif.dart';

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
  PitelClient pitelClient = PitelClient.getInstance();

  final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
  bool isCall = false;

  @override
  void initState() {
    super.initState();
    VoipNotifService.listenerEvent(
      callback: (event) {},
      onCallAccept: () {
        widget.handleRegisterCall();
      },
      onCallDecline: (CallEvent event) {},
      onCallEnd: () {
        pitelCall.hangup();
      },
    );
    //! WARNING
    initRegister();
  }

  void initRegister() async {
    if (Platform.isAndroid) {
      widget.handleRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
