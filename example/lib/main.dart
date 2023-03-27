import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:callkeep/callkeep.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plugin_pitel/pitel_plugin/pitel_plugin.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_client.dart';
import 'package:plugin_pitel_example/color.dart';
import 'package:plugin_pitel_example/local_store.dart';
import 'package:plugin_pitel_example/navigator.dart';
import 'package:plugin_pitel_example/src/login.dart';

import 'src/callscreen.dart';
import 'src/dialpad.dart';

AndroidNotificationChannel? channel;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
final FlutterCallkeep _callKeep = FlutterCallkeep();

_observeActionStream(ReceivedAction action) async {
  var localStorage = LocalStorage();
  if (action.buttonKeyPressed == 'accept') {
    await localStorage.saveStateCall();
    _callKeep.backToForeground();
  } else {
    startForegroundService();
    var account = await localStorage.getAccountLocal();
    if (account != null) {
      var pitelClient = PitelClient.getInstance();
      pitelClient.login(account.username, account.password).then((success) {
        if (success) {
          pitelClient.pitelCall.busyNow();
        } else {
          stopForegroundService();
        }
      });
    } else {
      stopForegroundService();
    }
  }
}

//use an async method so we can await
void startForegroundService() async {
  await FlutterForegroundPlugin.startForegroundService(
    holdWakeLock: false,
    onStarted: () {
      debugPrint('FlutterForegroundPlugin onStarted');
    },
    onStopped: () {
      debugPrint("FlutterForegroundPlugin on Stopped");
    },
    title: "Flutter Foreground Service",
    content: "This is Content",
    iconName: "ic_launcher",
  );
}

void stopForegroundService() {
  FlutterForegroundPlugin.stopForegroundService();
}

createNotificationWithButtonAcceptAndDeny() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: 'high_importance_channel',
      title: 'Simple title',
      body: 'Simple body ',
      // icon: 'ic_launcher',
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'accept',
        label: 'Accept',
        buttonType: ActionButtonType.KeepOnTop,
      ),
      NotificationActionButton(
        key: 'cancel',
        label: 'Cancel',
        buttonType: ActionButtonType.KeepOnTop,
      ),
    ],
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
  if (message.data.isNotEmpty) {
    var data = message.data;
    if (data['event'] == 'CALLING') {
      await createNotificationWithButtonAcceptAndDeny();
      // runApp(MyApp());
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  var stateCall = await LocalStorage().getStateCall();
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'High Importance Notifications',
          channelDescription:
              'This channel awesome is used for important notifications.',
        )
      ],
      backgroundClickAction: _observeActionStream);
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      ?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp(
    stateCall: stateCall,
  ));
}

class MyApp extends StatefulWidget {
  final bool stateCall;

  const MyApp({Key? key, required this.stateCall}) : super(key: key);

  Route _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<Route>(builder: (context) {
          return LoginWidget();
        });
      case '/main':
        final args = settings.arguments as DialPadArguments;
        return MaterialPageRoute<Route>(builder: (context) {
          return DialPadWidget(
            arguments: args,
          );
        });
      case '/callscreen':
        return MaterialPageRoute<Route>(builder: (context) {
          return CallScreenWidget(
            receivedBackground: stateCall,
          );
        });
      default:
        return MaterialPageRoute<Route>(builder: (context) {
          return LoginWidget();
        });
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  Future<void> registerDeviceFirebase() async {
    await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
    if (Platform.isIOS) {
      debugPrint('FlutterFire Messaging Example: Getting APNs token...');
      var token = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('FlutterFire Messaging Example: Got APNs token: $token');
    } else {
      debugPrint('FlutterFire Messaging Example: Getting APNs token...');
      var token = await FirebaseMessaging.instance.getToken();
      debugPrint('FlutterFire Messaging Example: Got Firebase token: $token');
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint(
          'FlutterFire Messaging Example: Got new Firebase token: $token');
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // if (widget.stateCall) {
      //   final account = await LocalStorage().getAccountLocal();
      //   if (account != null) {
      //     PitelClient.getInstance().login(account.username, account.password);
      //   }
      // }
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        if (message.data.isNotEmpty) {
          debugPrint('message');
          debugPrint(message.data.toString());
        }
      }
    });
    registerDeviceFirebase();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var notification = message.notification;
      var android = message.notification?.android;
      if (flutterLocalNotificationsPlugin != null && channel != null) {
        if (notification != null && android != null && Platform.isAndroid) {
          flutterLocalNotificationsPlugin?.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel!.id,
                  channel!.name,
                  channelDescription: channel!.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                ),
              ));
        } else {}
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      if (message.data.isNotEmpty) {
        debugPrint(message.data.toString());
      }
    });

    PitelPlugin.platformVersion.then((version) {
      debugPrint('PLatform $version');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: NavigatorSerivce.getInstance().navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: ColorApp.primaryColor,
        secondaryHeaderColor: ColorApp.secondaryHeaderColor,
        fontFamily: 'Roboto',
      ),
      initialRoute: widget.stateCall ? '/callscreen' : '/',
      // initialRoute: widget.stateCall ? '/' : '/',
      onGenerateRoute: widget._onGenerateRoute,
    );
  }
}
