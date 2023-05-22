##### plugin_pitel

# Integrate Voip call to your project

[![N|Solid](https://documents.tel4vn.com/img/pitel-logo.png)](https://documents.tel4vn.com/)

`plugin_pitel` is package support for voip call.

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

## Installation

1. Install Packages
   Add pubspec.yaml:

```pubspec.yaml
plugin_pitel:
    git:
      url: https://github.com/tel4vn/flutter-pitel-voip.git
      ref: 1.0.2 # branch name
```

2. Get package

```
flutter pub get
```

3. Import

```
import 'package:plugin_pitel/flutter_pitel_voip.dart';
```

4. Configure Project

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
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
 </manifest>
```

#### IOS

- Request permission in file `Info.plist`

```
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
<key>NSMicrophoneUsageDescription</key>
<string>Use microphone</string>
<key>UIBackgroundModes</key>
<array>
	<string>external-accessory</string>
	<string>fetch</string>
	<string>processing</string>
	<string>remote-notification</string>
	<string>voip</string>
</array>
```

- Make sure platform ios `12.0` in `Podfile`

```
platform :ios, '12.0'
```

5. Pushkit - Received VoIP and Wake app from Terminated State (only for IOS).
   > **Note**
   > Please check [PUSH_NOTIF.md](https://github.com/tel4vn/flutter-pitel-voip/blob/main/PUSH_NOTIF.md). setup Pushkit for IOS

## Example

Please checkout repo github to get [example](https://github.com/tel4vn/pitel-ui-kit)

## Usage

- In file `app.dart`, listen incoming call
  Please follow [example](https://github.com/tel4vn/pitel-ui-kit/blob/feature/v1.0.2/lib/features/home/home_screen.dart)

> Note: handleRegisterCall, handleRegister in [here](https://github.com/tel4vn/pitel-ui-kit/blob/feature/v1.0.2/lib/features/home/home_screen.dart)

```dart
void initState() {
    super.initState();
    VoipNotifService.listenerEvent(
      callback: (event) {},
      onCallAccept: () {
        //! Re-register when user accept call, please check example above
        handleRegisterCall();
      },
      onCallDecline: () {},
      onCallEnd: () {
        pitelCall.hangup();
      },
    );
  }
```

Wrap MaterialApp with PitelVoip widget

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

#### Properties

| Prop          | Description               | Default |
| ------------- | ------------------------- | ------- |
| onCallAccept  | Accepted an incoming call | () {}   |
| onCallDecline | Decline an incoming call  | () {}   |
| onCallEnd     | End an incoming call      | () {}   |

- In file `home_screen.dart`.
  Please follow [example](https://github.com/tel4vn/pitel-ui-kit/blob/feature/v1.0.2/lib/features/home/home_screen.dart).
  Add WidgetsBindingObserver to handle AppLifecycleState change

```dart
...
class _MyHomeScreen extends State<HomeScreen>
    with WidgetsBindingObserver {           // add WidgetsBindingObserver

    @override
    initState() {
        super.initState();
        WidgetsBinding.instance.addObserver(this);      // Add this line
    }
    @override
    void dispose() {
        WidgetsBinding.instance.removeObserver(this);   // Add this line
        super.dispose();
    }
    ...
    @override
    void didChangeAppLifecycleState(AppLifecycleState state) async {   // Add this function
        super.didChangeAppLifecycleState(state);
        if (state == AppLifecycleState.inactive) {
          final isLock = await isLockScreen();
          setState(() {
            lockScreen = isLock ?? false;
          });
        }
    }
    ...
}
```

Register extension from data of Tel4vn provide. Example: 101, 102,… Create 1 button to fill data to register extension.

```dart
ElevatedButton(
        onPressed: () asyns {
          final fcmToken = await PushVoipNotif.getFCMToken();
          final pnPushParams = PnPushParams(
            pnProvider: Platform.isAndroid ? 'fcm' : 'apns',
            pnParam: Platform.isAndroid
                ? '${bundleId}' // Example com.company.app
                : '${apple_team_id}.${bundleId}.voip', // Example com.company.app
            pnPrid: '${deviceToken}',
            fcmToken: fcmToken,
          );
          final sipInfo = SipInfoData.fromJson({
            "authPass": "${Password}",
            "registerServer": "${Domain}",
            "outboundServer": "${Outbound Proxy}",
            "userID": UUser,                // Example 101
            "authID": UUser,                // Example 101
            "accountName": "${UUser}",      // Example 101
            "displayName": "${UUser}@${Domain}",
            "dialPlan": null,
            "randomPort": null,
            "voicemail": null,
            "wssUrl": "${URL WSS}",
            "userName": "${username}@${Domain}",
            "apiDomain": "${URL API}"
          });

          final pitelClient = PitelServiceImpl();
          pitelClient.setExtensionInfo(sipInfo, pnPushParams);
        },
        child: const Text("Register"),),
```

- In file `call_screen.dart`
  [Example](https://github.com/tel4vn/pitel-ui-kit/blob/main/lib/features/call_screen/call_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:plugin_pitel/flutter_pitel_voip.dart';
class CallPage extends StatelessWidget {
  const CallPage({super.key});
  @override
  Widget build(BuildContext context) {
    return CallScreen(
      goBack: () {
        // Call your go back function in here
      },
      bgColor: Colors.cyan,
    );
  }
}
```

#### Properties

| Prop        | Description                          | Type      |
| ----------- | ------------------------------------ | --------- |
| txtMute     | Text display of micro mute           | String    |
| txtUnMute   | Text display of micro unmute         | String    |
| txtSpeaker  | Text display speaker                 | String    |
| txtOutgoing | Text display direction outgoing call | String    |
| txtIncoming | Text display direction incoming call | String    |
| textStyle   | Custom text style                    | TextStyle |

## How to test

Using tryit to test voip call connection & conversation
Link: https://tryit.jssip.net/
Setting:

1. Access to link https://tryit.jssip.net/
2. Enter extension: example 102
3. Click Setting icon
4. Enter information to input field
   ![tryit](assets/images/pitel_img_3.png)
5. Save
6. Click icon -> to connect
