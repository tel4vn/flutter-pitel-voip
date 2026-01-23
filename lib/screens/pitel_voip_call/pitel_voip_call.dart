import 'dart:io';
import 'package:eraser/eraser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming_timer/flutter_callkit_incoming.dart';
import 'package:flutter_pitel_voip/component/loading/pitel_loading.dart';
import 'package:flutter_pitel_voip/flutter_pitel_voip.dart';
import 'package:flutter_pitel_voip/services/pitel_callstate_service.dart';
import 'package:flutter_show_when_locked/flutter_show_when_locked.dart';

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

  @override
  initState() {
    super.initState();
    _bindEventListeners();
  }

  @override
  void dispose() {
    super.dispose();
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

  static const _audioPlatform =
      MethodChannel('com.pitel.flutter_pitel_voip/audio');
  Future<void> _enableManualAudio() async {
    if (Platform.isIOS) {
      try {
        await _audioPlatform.invokeMethod('enableAudio');
      } catch (_) {}
    }
  }

  @override
  void callStateChanged(String callId, PitelCallState state) async {
    widget.onCallState(state.state);
    PitelCallStateService().updateState(state.state);
    if (state.state == PitelCallStateEnum.ENDED) {
      pitelCall.resetOutPhone();
      pitelCall.resetNameCaller();
      pitelCall.setIsHoldCall(false);
      FlutterCallkitIncoming.endAllCalls();
      if (Platform.isAndroid) {
        await FlutterShowWhenLocked().hide();
      }
      widget.goBack();
    }
    if (state.state == PitelCallStateEnum.FAILED) {
      pitelCall.resetOutPhone();
      pitelCall.resetNameCaller();
      pitelCall.setIsHoldCall(false);
      widget.goBack();
    }
    if (state.state == PitelCallStateEnum.STREAM) {
      pitelCall.enableSpeakerphone(false);
    }
    if (state.state == PitelCallStateEnum.ACCEPTED) {
      pitelCall.setIsHoldCall(true);
      if (pitelCall.direction == 'Direction.incoming' && Platform.isIOS) {
        widget.goToCall();
      }
      if (Platform.isAndroid) {
        Eraser.clearAllAppNotifications();
      }
    }
  }

  @override
  void transportStateChanged(PitelTransportState state) {}

  @override
  void onCallReceived(String callId) async {
    pitelCall.setCallCurrent(callId);
    if (Platform.isIOS) {
      await _enableManualAudio();
      pitelCall.answer();
    }
    if (Platform.isAndroid) {
      widget.goToCall();
    }
  }

  @override
  void onCallInitiated(String callId) async {
    pitelCall.setCallCurrent(callId);

    if (Platform.isIOS) {
      await _enableManualAudio();
    }

    if (!mounted) return;

    if (Platform.isAndroid) {
      widget.goToCall();
    } else {
      Future.delayed(const Duration(milliseconds: 200), widget.goToCall);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  // STATUS: check register status
  @override
  void registrationStateChanged(PitelRegistrationState state) async {
    switch (state.state) {
      case PitelRegistrationStateEnum.registrationFailed:
        pitelCall.resetOutPhone();
        PitelLoading.instance.hide();
        break;
      case PitelRegistrationStateEnum.none:
      case PitelRegistrationStateEnum.unregistered:
        widget.onRegisterState("UNREGISTERED");
        // _registerExtFailed();
        break;
      case PitelRegistrationStateEnum.registered:
        if (pitelCall.outPhone.isNotEmpty) {
          pitelClient.call(pitelCall.outPhone, true).then(
                (value) => value.fold((succ) => "OK", (err) {
                  PitelToast.instance.show(
                      message: err.toString(),
                      position: PitelToastPosition.center);
                }),
              );
        }
        if (Platform.isIOS) {
          FlutterCallkitIncoming.startIncomingCall();
        }
        widget.onRegisterState("REGISTERED");
        PitelLoading.instance.hide();
        break;
    }
  }
}
