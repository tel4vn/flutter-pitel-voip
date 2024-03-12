import 'dart:io';
import 'package:eraser/eraser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:plugin_pitel/flutter_pitel_voip.dart';
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
  void callStateChanged(String callId, PitelCallState state) {
    widget.onCallState(state.state);
    if (state.state == PitelCallStateEnum.ENDED) {
      pitelCall.resetOutPhone();
      pitelCall.resetNameCaller();
      FlutterCallkitIncoming.endAllCalls();
      widget.goBack();
    }
    if (state.state == PitelCallStateEnum.FAILED) {
      pitelCall.resetOutPhone();
      pitelCall.resetNameCaller();
      widget.goBack();
    }
    if (state.state == PitelCallStateEnum.STREAM) {
      pitelCall.enableSpeakerphone(false);
    }
    if (state.state == PitelCallStateEnum.ACCEPTED) {
      if (Platform.isAndroid) {
        Eraser.clearAllAppNotifications();
      }
    }
  }

  @override
  void transportStateChanged(PitelTransportState state) {}

  @override
  void onCallReceived(String callId) {
    pitelCall.setCallCurrent(callId);
    if (Platform.isIOS) {
      pitelCall.answer();
    }
    widget.goToCall();
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
      case PitelRegistrationStateEnum.REGISTRATION_FAILED:
        pitelCall.resetOutPhone();
        EasyLoading.dismiss();
        break;
      case PitelRegistrationStateEnum.NONE:
      case PitelRegistrationStateEnum.UNREGISTERED:
        prefs.setString("REGISTER_STATE", "UNREGISTERED");
        widget.onRegisterState("UNREGISTERED");
        break;
      case PitelRegistrationStateEnum.REGISTERED:
        EasyLoading.dismiss();
        if (pitelCall.outPhone.isNotEmpty) {
          pitelClient.call(pitelCall.outPhone, true).then(
                (value) => value.fold((succ) => "OK", (err) {
                  EasyLoading.showToast(
                    err.toString(),
                    toastPosition: EasyLoadingToastPosition.center,
                  );
                }),
              );
        }
        if (Platform.isIOS) {
          FlutterCallkitIncoming.startIncomingCall();
        }
        prefs.setString("REGISTER_STATE", "REGISTERED");
        widget.onRegisterState("REGISTERED");
        break;
    }
  }
}
