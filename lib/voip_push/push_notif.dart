import 'dart:developer';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'android_connection_service.dart';
import 'firebase_options.dart';

class PushNotifAndroid {
  static initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
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
    inspect(message);
    AndroidConnectionService.showCallkitIncoming(CallkitParamsModel(
      uuid: message.messageId ?? '',
      nameCaller: message.data['nameCaller'] ?? '',
      avatar: message.data['avatar'] ?? '',
      phoneNumber: message.data['phoneNumber'] ?? '',
      appName: message.data['appName'] ?? '',
    ));
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
