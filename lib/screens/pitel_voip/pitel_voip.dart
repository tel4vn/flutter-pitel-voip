import 'dart:io';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
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
      onCallDecline: () {},
      onCallEnd: () {
        pitelCall.hangup();
      },
    );
    initRegister();
  }

  void initRegister() async {
    isCall = true;
    final List<dynamic> res = await FlutterCallkitIncoming.activeCalls();
    if (Platform.isAndroid) {
      widget.handleRegister();
    }
    if (res.isEmpty && Platform.isIOS) {
      widget.handleRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLifecycleTracker(
      didChangeAppState: (state) async {
        if (Platform.isIOS) {
          final List<dynamic> res = await FlutterCallkitIncoming.activeCalls();
          if (state == AppState.resumed && res.isEmpty) {
            if (!isCall) {
              widget.handleRegister();
            }
          }
          if (state == AppState.inactive || state == AppState.paused) {
            setState(() {
              isCall = false;
            });
          }
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
