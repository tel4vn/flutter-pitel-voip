import 'dart:io';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_pitel_voip/component/pitel_call_state.dart';
import 'package:flutter_pitel_voip/component/sip_pitel_helper_listener.dart';
import 'package:flutter_pitel_voip/flutter_pitel_voip.dart';
import 'package:flutter_pitel_voip/pitel_sdk/pitel_client.dart';
import 'package:flutter_pitel_voip/sip/src/sip_ua_helper.dart';

import 'models/pn_push_params.dart';
import 'models/push_notif_params.dart';
import 'pitel_service_interface.dart';
import 'sip_info_data.dart';

class PitelServiceImpl implements PitelService, SipPitelHelperListener {
  final pitelClient = PitelClient.getInstance();

  SipInfoData? sipInfoData;

  PitelServiceImpl() {
    pitelClient.pitelCall.addListener(this);
  }

  @override
  Future<PitelSettings> registerSipWithoutFCM(PnPushParams pnPushParams) {
    return pitelClient.registerSipWithoutFCM(pnPushParams);
  }

  @override
  Future<PitelSettings> setExtensionInfo(
    SipInfoData sipInfoData,
    PushNotifParams pushNotifParams,
  ) async {
    //! WARNING: solution 2
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final sipInfoEncode = jsonEncode(sipInfoData);
    // final pnPushParamsEncode = jsonEncode(pnPushParams);
    // await prefs.setString("SIP_INFO_DATA", sipInfoEncode);
    // await prefs.setString("PN_PUSH_PARAMS", pnPushParamsEncode);

    final deviceTokenRes = await PushVoipNotif.getDeviceToken();
    final fcmToken = await PushVoipNotif.getFCMToken();

    final pnPushParams = PnPushParams(
      pnProvider: Platform.isAndroid ? 'fcm' : 'apns',
      pnParam: Platform.isAndroid
          ? pushNotifParams.bundleId
          : '${pushNotifParams.teamId}.${pushNotifParams.bundleId}.voip',
      pnPrid: deviceTokenRes,
      fcmToken: fcmToken,
    );

    this.sipInfoData = sipInfoData;
    pitelClient.setExtensionInfo(sipInfoData.toGetExtensionResponse());
    final pitelSetting = await pitelClient.registerSipWithoutFCM(pnPushParams);
    return pitelSetting;
  }

  @override
  void callStateChanged(String callId, PitelCallState state) {
    if (kDebugMode) {
      print('❌ ❌ ❌ callStateChanged $callId state ${state.state.toString()}');
    }
  }

  @override
  void onCallInitiated(String callId) {
    if (kDebugMode) {
      print('❌ ❌ ❌ onCallInitiated $callId');
    }
  }

  @override
  void onCallReceived(String callId) {
    if (kDebugMode) {
      print('❌ ❌ ❌ onCallReceived $callId');
    }
  }

  @override
  void onNewMessage(PitelSIPMessageRequest msg) {
    if (kDebugMode) {
      print('❌ ❌ ❌ transportStateChanged ${msg.message}');
    }
  }

  @override
  void registrationStateChanged(PitelRegistrationState state) {
    if (kDebugMode) {
      print('❌ ❌ ❌ registrationStateChanged ${state.state.toString()}');
    }
  }

  @override
  void transportStateChanged(PitelTransportState state) {
    if (kDebugMode) {
      print('❌ ❌ ❌ transportStateChanged ${state.state.toString()}');
    }
  }
}
