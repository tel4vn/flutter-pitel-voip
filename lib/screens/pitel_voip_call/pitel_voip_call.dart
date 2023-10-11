import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_pitel_voip/flutter_pitel_voip.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PitelVoipCall extends StatefulWidget {
  final PitelCall _pitelCall = PitelClient.getInstance().pitelCall;
  final VoidCallback goBack;
  final VoidCallback goToCall;
  final Function(String) onRegisterState;
  final Function(PitelCallStateEnum) onCallState;
  final Widget child;

  PitelVoipCall({
    Key? key,
    required this.goBack,
    required this.goToCall,
    required this.child,
    required this.onRegisterState,
    required this.onCallState,
  }) : super(key: key);

  @override
  State<PitelVoipCall> createState() => _MyPitelVoipCall();
}

class _MyPitelVoipCall extends State<PitelVoipCall>
    implements SipPitelHelperListener {
  PitelCall get pitelCall => widget._pitelCall;
  PitelClient pitelClient = PitelClient.getInstance();
  String state = '';

  @override
  initState() {
    super.initState();
    state = pitelCall.getRegisterState();
    _bindEventListeners();
  }

  @override
  void deactivate() {
    super.deactivate();
    _removeEventListeners();
  }

  void _bindEventListeners() {
    pitelCall.addListener(this);
  }

  void _removeEventListeners() {
    pitelCall.removeListener(this);
  }

  // HANDLE: handle message if register status change
  @override
  void onNewMessage(PitelSIPMessageRequest msg) {}

  @override
  void callStateChanged(String callId, PitelCallState state) async {
    widget.onCallState(state.state);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (state.state == PitelCallStateEnum.ENDED) {
      FlutterCallkitIncoming.endAllCalls();
      widget.goBack();
      prefs.setBool("ACCEPT_CALL", false);
    }
    if (state.state == PitelCallStateEnum.FAILED) {
      widget.goBack();
      prefs.setBool("ACCEPT_CALL", false);
    }
    if (state.state == PitelCallStateEnum.STREAM) {
      pitelCall.enableSpeakerphone(false);
    }
  }

  @override
  void transportStateChanged(PitelTransportState state) {}

  @override
  void onCallReceived(String callId) async {
    pitelCall.setCallCurrent(callId);
    //! Back up
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? acceptCall = prefs.getBool("ACCEPT_CALL");
    if (Platform.isIOS && acceptCall != null && acceptCall) {
      pitelCall.answer(callId: callId);
      widget.goToCall();
    }
    if (Platform.isAndroid) {
      widget.goToCall();
    }
    //! Back up
    // if (Platform.isIOS) {
    //   pitelCall.answer();
    // }
    // widget.goToCall();
  }

  @override
  void onCallInitiated(String callId) {
    pitelCall.setCallCurrent(callId);
    widget.goToCall();
  }

  void goToBack() {
    pitelClient.release();
    widget.goBack();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }

  // STATUS: check register status
  @override
  void registrationStateChanged(PitelRegistrationState state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (state.state) {
      case PitelRegistrationStateEnum.registrationFailed:
        break;
      case PitelRegistrationStateEnum.none:
      case PitelRegistrationStateEnum.unregistered:
        prefs.setString("REGISTER_STATE", "UNREGISTERED");
        widget.onRegisterState("UNREGISTERED");
        break;
      case PitelRegistrationStateEnum.registered:
        prefs.setString("REGISTER_STATE", "REGISTERED");
        widget.onRegisterState("REGISTERED");
        break;
    }
  }
}
