import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:eraser/eraser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:plugin_pitel/flutter_pitel_voip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'android_connection_service.dart';

class PushNotifAndroid {
  static initFirebase({
    FirebaseOptions? options,
    Function(RemoteMessage message)? onMessage,
    Function(RemoteMessage message)? onMessageOpenedApp,
    Function(RemoteMessage? message)? getInitialMessage,
  }) async {
    await Firebase.initializeApp();
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

    // iOS: show notification in foreground
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true, // Required to display a heads up notification
    //   badge: true,
    //   sound: true,
    // );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleNotification(message);
      if (onMessage != null) {
        onMessage(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (onMessageOpenedApp != null) {
        onMessageOpenedApp(message);
      }
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (getInitialMessage != null) {
        getInitialMessage(message);
      }
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

  // TODO: v2 - callback
  // @pragma('vm:entry-point')
  // static Future<void> _registerToCallkitEvent() async {
  //   FlutterCallkitIncoming.onEvent.listen((event) async {
  //     final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
  //     if (event!.event == Event.ACTION_CALL_CALLBACK) {
  //       final SharedPreferences prefs = await SharedPreferences.getInstance();
  //       prefs.setString("CALL_BACK_PHONE_NUMBER", "101" ?? '');
  //     }
  //   });
  // }

  static void _setCountNotif() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final countNotif = prefs.getInt("NOTIF_COUNT");

    if (countNotif == null) {
      await prefs.setInt("NOTIF_COUNT", 1);
    } else {
      // FlutterAppBadger.updateBadgeCount(countNotifInt);
      await prefs.setInt("NOTIF_COUNT", countNotif + 1);
    }
    // Future.delayed(const Duration(seconds: 1));
    // await logicNotif.getCountNotif();
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // _setCountNotif();

    handleNotification(message);
  }

  static Future<void> handleNotification(RemoteMessage message) async {
    // TODO: v2 - callback
    // if (Platform.isAndroid) {
    //   _registerToCallkitEvent();
    // }
    switch (message.data['callType']) {
      case "RE_REGISTER":
        await registerWhenReceiveNotif();
        break;
      case "CANCEL_ALL":
      case "CANCEL_GROUP":
        // if (Platform.isAndroid) {
        //   handleShowMissedCall(message);
        // }
        FlutterCallkitIncoming.endAllCalls();
        Eraser.clearAllAppNotifications();
        break;
      case "CALL":
        handleShowCallKit(message);
        break;
      default:
        break;
    }
  }

  static void handleShowCallKit(RemoteMessage message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("NAME_CALLER", message.data['nameCaller'] ?? '');

    AndroidConnectionService.showCallkitIncoming(CallkitParamsModel(
      uuid: message.messageId ?? '',
      nameCaller: message.data['nameCaller'] ?? '',
      avatar: message.data['avatar'] ?? '',
      phoneNumber: message.data['phoneNumber'] ?? '',
      appName: message.data['appName'] ?? '',
      backgroundColor: message.data['backgroundColor'] ?? '#0955fa',
    ));
  }

  static void handleShowMissedCall(RemoteMessage message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("NAME_CALLER", message.data['nameCaller'] ?? '');

    AndroidConnectionService.showMissedCall(CallkitParamsModel(
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
