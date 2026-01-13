import 'dart:io';
import 'package:eraser/eraser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming_timer/flutter_callkit_incoming.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pitel_voip/flutter_pitel_voip.dart';
import 'package:flutter_show_when_locked/flutter_show_when_locked.dart';

class PitelVoipCall extends StatefulWidget {
  final PitelCall _pitelCall = PitelClient.getInstance().pitelCall;
  final VoidCallback goBack;
  final VoidCallback goToCall;
  final Function(String) onRegisterState;
  final Function(PitelCallStateEnum) onCallState;
  final Widget child;
  final String bundleId;
  final SipInfoData? sipInfoData;
  final String appMode;

  PitelVoipCall({
    Key? key,
    required this.goBack,
    required this.goToCall,
    required this.child,
    required this.onRegisterState,
    required this.onCallState,
    required this.bundleId,
    required this.sipInfoData,
    this.appMode = '',
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

  @override
  void callStateChanged(String callId, PitelCallState state) async {
    widget.onCallState(state.state);
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
      if (pitelCall.direction == 'INCOMING' && Platform.isIOS) {
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
      pitelCall.answer();
    }
  }

  @override
  void onCallInitiated(String callId) {
    pitelCall.setCallCurrent(callId);
    if (mounted) {
      widget.goToCall();
    }
    if (Platform.isAndroid) {
      widget.goToCall();
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
        widget.onRegisterState("REGISTERED");
        // TODO: v3
        _registerExtSuccess();
        await EasyLoading.dismiss();
        break;
    }
  }

  void _registerExtSuccess() async {
    final deviceTokenRes = await PushVoipNotif.getDeviceToken();
    final fcmToken = await PushVoipNotif.getFCMToken();
    final appModeStatus = widget.appMode.isNotEmpty
        ? widget.appMode
        : kReleaseMode
            ? 'production'
            : 'dev';
    if (widget.sipInfoData != null) {
      pitelClient.registerDeviceToken(
        deviceToken: deviceTokenRes,
        platform: Platform.isIOS ? 'ios' : 'android',
        bundleId: widget.bundleId,
        domain: widget.sipInfoData!.registerServer,
        extension: widget.sipInfoData!.accountName.toString(),
        appMode: appModeStatus,
        fcmToken: fcmToken,
      );
    }
  }
}
