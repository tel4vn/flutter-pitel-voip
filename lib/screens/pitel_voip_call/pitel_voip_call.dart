import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
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
    if (state.state == PitelCallStateEnum.ACCEPTED) {
      if (Platform.isAndroid) {
        CallKeep.instance.endAllCalls();
      }
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
        //! WARNING
        // _registerExtFailed();
        break;
      case PitelRegistrationStateEnum.registered:
        if (Platform.isIOS) {
          FlutterCallkitIncoming.startIncomingCall();
        }
        prefs.setString("REGISTER_STATE", "REGISTERED");
        widget.onRegisterState("REGISTERED");
        _registerExtSuccess();
        break;
    }
  }

  void _registerExtSuccess() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasDeviceToken = prefs.getBool("HAS_DEVICE_TOKEN");
    if (hasDeviceToken == true) return;
    prefs.setBool("HAS_DEVICE_TOKEN", true);

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
