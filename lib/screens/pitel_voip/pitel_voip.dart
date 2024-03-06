import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:plugin_pitel/flutter_pitel_voip.dart';
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
  PitelClient pitelClient = PitelClient.getInstance();

  final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
  bool isCall = false;

  @override
  void initState() {
    super.initState();
    VoipNotifService.listenerEvent(
      callback: (event) {},
      onCallAccept: () {
        EasyLoading.show(status: "Connecting...");
        widget.handleRegisterCall();
      },
      onCallDecline: () {},
      onCallEnd: () {
        pitelCall.hangup();
      },
    );
    initRegister();
  }

  void initRegister() async {
    if (Platform.isAndroid) {
      widget.handleRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLifecycleTracker(
      didChangeAppState: (state) async {
        if (state == AppState.resumed) {
          pitelCall.setReconnect();
        }
      },
      child: widget.child,
    );
  }
}
