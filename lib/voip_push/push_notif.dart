import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

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
      handleNotification(message);
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

  static Future<void> handleNotification(RemoteMessage message) async {
    if (message.data['callType'] == "CALL") {
      handleShowCallKit(message);
    }
  }

  static void handleShowCallKit(RemoteMessage message) {
    AndroidConnectionService.showCallkitIncoming(CallkitParamsModel(
      uuid: message.messageId ?? '',
      nameCaller: message.data['nameCaller'] ?? '',
      avatar: message.data['avatar'] ?? '',
      phoneNumber: message.data['phoneNumber'] ?? '',
      appName: message.data['appName'] ?? '',
      backgroundColor: message.data['backgroundColor'] ?? '#0955fa',
    ));
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    handleNotification(message);
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
}
