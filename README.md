##### plugin_pitel
# Integrate Voip call to your project

[![N|Solid](https://documents.tel4vn.com/img/pitel-logo.png)](https://documents.tel4vn.com/)

```plugin_pitel``` is package support for voip call.

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
- In file ```android/app/src/main/AndroidManifest.xml```
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
- Request permission in file ```Info.plist```
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
- Make sure platform ios ```12.0``` in ```Podfile```
```
platform :ios, '12.0'
```
5. Pushkit - Received VoIP and Wake app from Terminated State (only for IOS).

Please check [PUSH_NOTIF.md](https://github.com/tel4vn/flutter-pitel-voip/blob/main/PUSH_NOTIF.md). setup Pushkit for IOS

## Usage
#### How to use call screen.
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
#### Implement SipPitelHelperListener in your Home screen,
In your Home screen, please implement SipPitelHelperListener to use plugin_pitel.[Example](https://github.com/tel4vn/pitel-ui-kit/blob/main/lib/features/home/home_screen.dart)
```dart
class HomeScreen extends StatefulWidget {
  final PitelCall _pitelCall = PitelClient.getInstance().pitelCall;
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<HomeScreen>
    implements SipPitelHelperListener {    // Implement SipPitelHelperListener in here
    PitelClient pitelClient = PitelClient.getInstance();
    PitelCall get pitelCall => widget._pitelCall;
    ...
}
```
#### Register extension
Register extension from data of Tel4vn provide. Example: 101, 102,…
- Create 1 button to fill data to register extension.
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
- Register status
```dart
@override
  void registrationStateChanged(PitelRegistrationState state) {
    switch (state.state) {
      case PitelRegistrationStateEnum.REGISTRATION_FAILED:
        goBack();
        break;
      case PitelRegistrationStateEnum.NONE:
      case PitelRegistrationStateEnum.UNREGISTERED:
      case PitelRegistrationStateEnum.REGISTERED:
        setState(() {
          receivedMsg = 'REGISTERED';
        });
        break;
    }
  }
```

#### Initialize call screen
- Initialize state & listener function
```dart
    @override
    initState() {
        super.initState();
        pitelCall.addListener(this);
        _initRenderers();
    }
    
    // INIT: Initialize Pitel
    void _initRenderers() async {
        await pitelCall.initializeLocal();
        await pitelCall.initializeRemote();
    }
```
- Dispose & Deactive function
```dart
  // Dispose pitelcall
  void _disposeRenderers() {
    pitelCall.disposeLocalRenderer();
    pitelCall.disposeRemoteRenderer();
  }
  // Deactive When call end
  @override
  deactivate() {
    super.deactivate();
    _handleHangup();
    pitelCall.removeListener(this);
    _disposeRenderers();
  }
```
- Hangup function
```dart
  // Handle hangup and reset timer
  pitelCall.hangup();
```
- Accept call function
```dart
  // Handle accept call
  pitelCall.answer();
```
- onCallInitiated: start outgoing call, this function will set current call id & navigate to call screen
```dart
  @override
  void onCallInitiated(String callId) {
    pitelCall.setCallCurrent(callId);
    context.pushNamed(AppRoute.callScreen.name);
  }
```
- onCallReceived: this function will active when have incoming call.
```dart
  @override
  void onCallReceived(String callId) async {
    pitelCall.setCallCurrent(callId);
    if (Platform.isIOS) {
      pitelCall.answer();
    }
    if (Platform.isAndroid) {
      context.pushNamed(AppRoute.callScreen.name);
    }
    //! Handle lock screen in IOS
    if (!lockScreen && Platform.isIOS) {
      context.pushNamed(AppRoute.callScreen.name);
    }
  }
```
- Listen state function

When call begin, this callStateChanged function will return state of call.
| PitelCallStateEnum      | Description                                         |
| ----------------------  | ----------------------                              |
| NONE                    | Call has not been made.                             |
| PROGRESS                | Initiate call.                                      |
| CONNECTING              | Connecting Extension to call.                       |
| STREAM                  | Conversation is in progress.                        |
| MUTED/UNMUTED           | Get state when micro is off/on.                     |
| ACCEPTED & CONFIRMED    | When Extension is called accept & join conversation.|
| FAILED                  | When the call is interrupted due to a problem.      |
| ENDED    		            | When Extension is called hang up.                   |

```dart
  // STATUS: Handle call state
  @override
  void callStateChanged(String callId, PitelCallState callState) {
    setState(() {
        // setState for callState
      _state = callState.state;
    });
    switch (callState.state) {
      case PitelCallStateEnum.HOLD:
      case PitelCallStateEnum.UNHOLD:
        break;
      case PitelCallStateEnum.MUTED:
      case PitelCallStateEnum.UNMUTED:
        break;
      case PitelCallStateEnum.STREAM:
        break;
      case PitelCallStateEnum.ENDED:
      case PitelCallStateEnum.FAILED:
        _backToDialPad();
        break;
      case PitelCallStateEnum.CONNECTING:
      case PitelCallStateEnum.PROGRESS:
      case PitelCallStateEnum.ACCEPTED:
      case PitelCallStateEnum.CONFIRMED:
      case PitelCallStateEnum.NONE:
      case PitelCallStateEnum.CALL_INITIATION:
      case PitelCallStateEnum.REFER:
        break;
    }
  }
```

## Example
Please checkout repo github to get [example](https://github.com/tel4vn/pitel-ui-kit)

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