import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_client.dart';
import 'package:plugin_pitel/services/models/pn_push_params.dart';
import 'package:plugin_pitel/services/sip_info_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'android_connection_service.dart';

class PushNotifAndroid {
  static initFirebase(FirebaseOptions? options) async {
    await Firebase.initializeApp(
      options: options,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //! WARNING: solution 2
      // if (message.data['call_status'] == "REGISTER") {
      //   await registerWhenReceiveNotif();
      // }
      AndroidConnectionService.showCallkitIncoming(CallkitParamsModel(
        uuid: message.messageId ?? '',
        nameCaller: message.data['nameCaller'] ?? '',
        avatar: message.data['avatar'] ?? '',
        phoneNumber: message.data['phoneNumber'] ?? '',
        appName: message.data['appName'] ?? '',
        backgroundColor: message.data['backgroundColor'] ?? '#0955fa',
      ));
    });
  }

  static Future<String> getDeviceToken() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    var deviceToken = "";
    try {
      final token = await fcm.getToken();
      deviceToken = token.toString();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
    return deviceToken;
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    //! WARNING: solution 2
    // if (message.data['call_status'] == "REGISTER") {
    //   await registerWhenReceiveNotif();
    // }
    AndroidConnectionService.showCallkitIncoming(CallkitParamsModel(
      uuid: message.messageId ?? '',
      nameCaller: message.data['nameCaller'] ?? '',
      avatar: message.data['avatar'] ?? '',
      phoneNumber: message.data['phoneNumber'] ?? '',
      appName: message.data['appName'] ?? '',
      backgroundColor: message.data['backgroundColor'] ?? '#0955fa',
    ));
  }

  static Future<void> registerWhenReceiveNotif() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? sipInfoData = prefs.getString("SIP_INFO_DATA");
    final String? pnPushParams = prefs.getString("PN_PUSH_PARAMS");

    final SipInfoData? sipInfoDataDecode = sipInfoData != null
        ? SipInfoData.fromJson(jsonDecode(sipInfoData))
        : null;
    final PnPushParams? pnPushParamsDecode = pnPushParams != null
        ? PnPushParams.fromJson(jsonDecode(pnPushParams))
        : null;

    if (sipInfoDataDecode != null && pnPushParamsDecode != null) {
      final pitelClient = PitelClient.getInstance();
      pitelClient.setExtensionInfo(sipInfoDataDecode.toGetExtensionResponse());
      pitelClient.registerSipWithoutFCM(pnPushParamsDecode);
    }
  }
}

class VoipPushIOS {
  static Future<String> getVoipDeviceToken() async {
    return await FlutterCallkitIncoming.getDevicePushTokenVoIP();
  }
}

class PushVoipNotif {
  static Future<String> getDeviceToken() async {
    final deviceToken = Platform.isAndroid
        ? await PushNotifAndroid.getDeviceToken()
        : await VoipPushIOS.getVoipDeviceToken();
    return deviceToken;
  }

  static Future<String> getFCMToken() async {
    final fcmToken = await PushNotifAndroid.getDeviceToken();
    return fcmToken;
  }
}
