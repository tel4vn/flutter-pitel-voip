##### flutter_pitel_voip

# Integrate VoIP call to your project

[![N|Solid](https://documents.tel4vn.com/img/pitel-logo.png)](https://documents.tel4vn.com/)

`flutter_pitel_voip` is package support for voip call. Please contact [pitel](https://www.pitel.vn/) to use the service.

## Demo

![Register extension](assets/images/pitel_img_1.png)
![call](assets/images/pitel_img_call.png)

## Pitel Connect Flow

When user make call from Pitel Connect app, Pitel Server pushes a notification for all user login (who receives the call). When user "Accept" call, extension will re-register to receive call.
![Pitel Connect Flow](assets/images/pitel_connect_flow.png)

## Features

- Register Extension
- Call
- Hangup
- Turn on/off micro
- Turn on/of speaker

## Summary

- [Config Pushkit](https://github.com/tel4vn/flutter-pitel-voip/blob/main/PUSH_NOTIF.md).
- [Portal Guide](https://github.com/tel4vn/flutter-pitel-voip/blob/main/PORTAL_GUIDE.md).

## Installation

1. Install Packages

- Run this command:

```dart
flutter pub add flutter_pitel_voip
```

- Or add pubspec.yaml:

```pubspec.yaml
flutter_pitel_voip: ^latest
```

2. Get package

```
flutter pub get
```

3. Import

```
import 'package:flutter_pitel_voip/flutter_pitel_voip.dart';
```

4. Configure Project

- In file app.dart config pitel loading

```dart
import 'package:flutter_pitel_voip/services/pitel_navigation_service.dart';
  // ....
  return MaterialApp(
    navigatorKey: NavigationService.navigatorKey,
  )

  // or use with go_router
  final router = GoRouter(
    navigatorKey: NavigationService.navigatorKey, 
    routes: [ ... ],
  );

  return MaterialApp.router(
    routerConfig: router,
  )
```

#### Android:

- In file `android/app/src/main/AndroidManifest.xml`

```xml
 <manifest...>
    ...
    // Request permission
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
 </manifest>
```

- Request full screen intent permission (Android 14+)

For Android 14 (API level 34) and above, you need to request the full screen intent permission to show incoming call notifications when the app is locked or in the background:

```dart
import 'package:flutter_callkit_incoming_timer/flutter_callkit_incoming.dart';
// Request permission in your app initialization or before making/receiving calls
await FlutterCallkitIncoming.requestFullIntentPermission();
```

This permission allows the app to launch a full-screen intent for incoming calls, ensuring users can see and answer calls even when the device is locked.

- In file `android/app/proguard-rules.pro`. Proguard Rules: The following rule needs to be added in the proguard-rules.pro to avoid obfuscated keys:

```
# KEEP plugin Android classes 
-keep class com.hiennv.flutter_callkit_incoming.** { *; }

# Keep Gson classes & TypeToken if plugin uses Gson
-keep class com.google.gson.** { *; }
-keepclassmembers class com.google.gson.reflect.TypeToken { *; }

# Fix Conscrypt missing classes for OkHttp
-dontwarn org.conscrypt.**
```

#### IOS

- Request permission in file `Info.plist`

```
<key>NSMicrophoneUsageDescription</key>
<string>Use microphone</string>
<key>UIBackgroundModes</key>
<array>
	<string>fetch</string>
	<string>processing</string>
	<string>remote-notification</string>
	<string>voip</string>
</array>
```

- Make sure platform ios `13.0` in `Podfile`

```
platform :ios, '13.0'
```

5. Pushkit/ Push notification - Received VoIP and Wake app from Terminated State.
   > **Note**
   > Please check [PUSH_NOTIF.md](https://github.com/tel4vn/flutter-pitel-voip/blob/main//PUSH_NOTIF.md). setup Pushkit (for IOS), push notification (for Android).

## Example

Please checkout repo github to get [example](https://github.com/tel4vn/pitel-ui-kit/tree/main)

## Usage

- In file `app.dart`, Wrap MaterialApp with PitelVoip widget
  Please follow [example](https://github.com/tel4vn/pitel-ui-kit/blob/main/lib/app.dart)

> Note: 
- handleRegister, registerFunc in [here](https://github.com/tel4vn/pitel-ui-kit/blob/main/lib/app.dart)
- Wrap the `PitelVoip` and `PitelVoipCall` widgets around your application's root widget (e.g., `MaterialApp` or `CupertinoApp`).

```dart
Widget build(BuildContext context) {
    return PitelVoip(                           // Wrap with PitelVoip
      handleRegister: handleRegister,           // Handle register
      child: MaterialApp.router(
        ...
      ),
    );
  }
```

- In file `home_screen.dart`.
  Please follow [example](https://github.com/tel4vn/pitel-ui-kit/blob/main/lib/features/home/home_screen.dart).
  Add WidgetsBindingObserver to handle AppLifecycleState change

```dart
...
Widget build(BuildContext context) {
    // Wrap with PitelVoipCall
    return PitelVoipCall(
        goBack: () {
            // go back function
        },
        goToCall: () {
            // go to call screen
        },
        onCallState: (callState) {},
        onRegisterState: (String registerState) {
            // get Register Status in here
        },
      child: ...,
    );
  }
```

#### Properties

| Prop            | Description                     | Type                      | Default  |
| --------------- | ------------------------------- | ------------------------- | -------- |
| goBack          | goback navigation               | () {}                     | Required |
| goToCall        | navigation, go to call screen   | () {}                     | Required |
| onCallState     | set call status                 | (callState) {}            | Required |
| onRegisterState | get extension register status   | (String registerState) {} | Required |
| child           | child widget                    | Widget                    | Required |

Register extension from data of Tel4vn provide. Example: 101, 102,… Create 1 button to fill data to register extension.

```dart
      ElevatedButton(
        onPressed: () asyns {
          PitelClient pitelClient = PitelClient.getInstance();

          final PushNotifParams pushNotifParams = PushNotifParams(
            teamId: '${APPLE_TEAM_ID}',
            bundleId: '${BUNDLE_ID}',
          );
          final sipInfoData = SipInfoData.fromJson({
            "accountName": "${Extension}",      // Example 101
            "authPass": "${Password}",
            "registerServer": "${Domain}",
            "outboundServer": "${Domain}",
            "port": PORT,                       // Default 50061
            "displayName": "${Display Name}",   // John, Kate
            "wssUrl": "${WSS Mobile}"
          });

          await pitelClient.registerExtension(
              sipInfoData: sipInfoData,
              pushNotifParams: pushNotifParams,
              appMode: 'dev',                   // 'dev' for debug mode, 'production' for release mode
              shouldRegisterDeviceToken: true); // Set shouldRegisterDeviceToken to true when the user presses the Register button.
        },
        child: const Text("Register"),
      ),
```

| Prop           | Description            | Type   | Default  |
| -------------- | ---------------------- | ------ | -------- |
| accountName    | Extension number       | String | Required |
| authPass       | Extension password     | String | Required |
| registerServer | Sip domain             | String | Required |
| outboundServer | Sip domain             | String | Required |
| port           | Port                   | String | Required |
| displayName    | Extension display name | String | Required |

- Logout extension

```dart
await pitelClient.logoutExtension(
  sipInfoData: sipInfoData,
  pushNotifParams: pushNotifParams,
);
```

- In file `call_screen.dart`
  [Example](https://github.com/tel4vn/pitel-ui-kit/blob/main/lib/features/call_screen/call_page.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_pitel_voip/flutter_pitel_voip.dart';
class CallPage extends StatelessWidget {
  const CallPage({super.key});
  @override
  Widget build(BuildContext context) {
    return CallScreen(
      bgColor: Colors.cyan,
    );
  }
}
```

#### Properties

| Prop               | Description                          | Type      | Default  |
| ------------------ | ------------------------------------ | --------- | -------- |
| goBack             | go back navigation                   | () {}     | Required |
| bgColor            | background color                     | Color     | Required |
| txtMute            | Text display of micro mute           | String    | Optional |
| txtUnMute          | Text display of micro unmute         | String    | Optional |
| txtSpeaker         | Text display speaker                 | String    | Optional |
| txtOutgoing        | Text display direction outgoing call | String    | Optional |
| txtIncoming        | Text display direction incoming call | String    | Optional |
| textStyle          | Style for mic/speaker text           | TextStyle | Optional |
| titleTextStyle     | Style for display phone number text  | TextStyle | Optional |
| timerTextStyle     | Style for timer text                 | TextStyle | Optional |
| directionTextStyle | Style for direction text             | TextStyle | Optional |
| showHoldCall       | Show action button hold call         | bool      | Optional |

- Outgoing call

```dart
pitelCall.outGoingCall(
  phoneNumber: "",
  handleRegister: () {
    // handle register function
    await pitelClient.registerExtension(
        sipInfoData: sipInfoData,
        pushNotifParams: pushNotifParams,
        appMode: 'dev',                    // 'dev' for debug mode, 'production' for release mode
        shouldRegisterDeviceToken: false); // Set shouldRegisterDeviceToken to false during an outgoing call.
  }, 
);
```

#### Properties

| Prop               | Description               | Type   | Default  |
| ------------------ | ------------------------- | ------ | -------- |
| phoneNumber        | phone number for call out | String | Required |
| handleRegisterCall | re-register when call out | () {}  | Required |
| nameCaller         | set name caller           | String | Optional |