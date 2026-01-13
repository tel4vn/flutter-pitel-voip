import 'dart:io' show Platform;

import 'package:eraser/eraser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming_timer/flutter_callkit_incoming.dart';

import 'android_connection_service.dart';

@pragma('vm:entry-point')
class PushNotifAndroid {
  static initFirebase({
    FirebaseOptions? options,
    Function(RemoteMessage message)? onMessage,
    Function(RemoteMessage message)? onMessageOpenedApp,
  }) async {
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
      if (onMessage != null) {
        onMessage(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (onMessageOpenedApp != null) {
        onMessageOpenedApp(message);
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

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    handleNotification(message);
  }

  static Future<void> handleNotification(RemoteMessage message) async {
    switch (message.data['callType']) {
      case "CANCEL_ALL":
      case "CANCEL_GROUP":
        print(
            '===============message.data==========${message.data['callType']}=======');
        // FlutterCallkitIncoming.endAllCalls();
        Eraser.clearAllAppNotifications();
        break;
      case "CALL":
        handleShowCallKit(message);
        break;
      default:
        break;
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
