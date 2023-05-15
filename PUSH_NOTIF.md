# Pitel Voip Push notification
> **Warning**
> IOS only working on real device, not on simulator (Callkit framework not working on simulator)
# Setup & Certificate
#### IOS
If you are making VoIP application than you definitely want to update your application in the background & terminate state as well as wake your application when any VoIP call is being received.

**1. Create Apple Push Notification certificate.**
- Access [https://developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list)
- In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources), click Certificates in the sidebar.
- On the top left, click the add button (+).The certificate type should be Apple Push Notification service SSL (Sandbox & Production) under Services.

![push_img_10](assets/push_img/push_img_10.png)

**2. Choose an App ID from the pop-up menu, then click Continue.**
![push_img_9](assets/push_img/push_img_9.png)

**3. Upload Certificate Signing Request → Continue**
![push_img_8](assets/push_img/push_img_8.png)

Follow the instructions to [create a certificate signing request](https://developer.apple.com/help/account/create-certificates/create-a-certificate-signing-request).

- **Install certificate.**
Download the certificate and install it into the Keychain Access app(download .cer and double click to install).
    
- **Export the .p12 file and send it to Tel4vn (or using test)**
![push_img_7](assets/push_img/push_img_7.png)

# Setup Pushkit & Callkit
#### IOS
- Open Xcode Project → Capabilities
- In Tab Signing & Capabilities. Enable Push notifications & Background Modes

![push_img_5](assets/push_img/push_img_5.png)
- Create APNs key and upload in firebase project. In your apple developer account.
![apns_key](assets/push_img/apns_key.png)
- Upload APNs key to your firebase
    - Create new your IOS App in Firebase project.
    ![ios_app](assets/push_img/ios_app.png)
    - Download file .p8 to upload to firebase
    ![download_apns_key](assets/push_img/download_apns_key.png)
    - Select IOS app -> upload Apns key
    ![upload_key_firebase](assets/push_img/upload_key_firebase.png)
    - Fill information in upload Apns key popup
    ![upload_key_firebase_popup](assets/push_img/upload_key_firebase_popup.png)

#### Android
Using FCM (Firebase Cloud Message) to handle push notification wake up app when app run on Background or Terminate
> **Warning**
> Popup request permission only working with targetSdkVersion >= 33

- Access link [https://console.firebase.google.com/u/0/project/_/notification](https://console.firebase.google.com/u/0/project/_/notification)
- Create your packageId for android app
![push_img_4](assets/push_img/push_img_4.png)
- Download & copy file google_service.json -> replace file google_service.json in path: ```android/app/google_service.json```

- Go to Project Setting → Cloud Messaging → Enable Cloud Messaging API (Legacy)
![push_img_3](assets/push_img/push_img_3.png)

> **Note**
> After complete all step Setup. Please send information to dev of Tel4vn, about:
> - Bunlde/package Id: example com.company.app
> - File certificate .p12 for IOS.
> - Server key for Android

# Installation (your project)
- Install Packages

```xml
flutter pub add flutter_callkit_incoming
```

- Add pubspec.yaml:
```xml
dependencies:
      flutter_callkit_incoming: any
```
**Config your project**
- Android
In android/app/src/main/AndroidManifest.xml
```xml
<manifest...>
     ...
     <!-- 
         Using for load image from internet
     -->
     <uses-permission android:name="android.permission.INTERNET"/>
 </manifest>
```

- IOS
In ios/Runner/Info.plist
```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
    <string>remote-notification</string>
    <string>voip</string>
</array>
```

Replace your file ios/Runner/AppDelegate.swift with

[https://github.com/tel4vn/pitel-ui-kit/blob/dev/ios/Runner/AppDelegate.swift](https://github.com/tel4vn/pitel-ui-kit/blob/dev/ios/Runner/AppDelegate.swift)

## **Usage**
- Before handle Incoming call, you should import package in home screen
```dart
import 'package:plugin_pitel/voip_push/push_notif.dart';
import 'package:plugin_pitel/voip_push/voip_notif.dart';
```
- Get device push token VoIP. 
```dart
void _getDeviceToken() async {
    final deviceToken = await PushVoipNotif.getDeviceToken();
    print(deviceToken);
  }
```
- Get fcm token VoIP. 
```dart
void _getFcmToken() async {
    final fcmToken = await PushVoipNotif.getFcmToken();
    print(fcmToken);
  }
```
- Register device token after user login success
```dart
void _registerDeviceToken() async {
    final fcmToken = await PushVoipNotif.getFCMToken();
    final response = await pitelClient.registerDeviceToken(
      deviceToken:
          '56357b057da09ba1c8a069c06a0f0232f7a1d80bf743f757c290a20b42dce55c',
      platform: 'ios',
      bundleId: 'com.pitel.uikit.demo',     // BundleId/packageId
      domain: 'mobile.tel4vn.com',
      extension: '101',
      appMode: kReleaseMode ? 'production' : 'dev', // check APNs certificate of Apple run production or dev mode
      fcmToken: fcmToken,
    );
  }
```
- Remove Device toke  when user logout success
```dart
    void _removeDeviceToken() async {
        final response = await pitelClient.removeDeviceToken(
          deviceToken:
          '56357b057da09ba1c8a069c06a0f0232f7a1d80bf743f757c290a20b42dce55c', // Device token
          domain: 'mobile.tel4vn.com',
          extension: '101',
      );
  }
  
    void _logout() {
        _removeDeviceToken();      // Remove device token
        pitelCall.unregister();    // Disconnect SIP call when user logout
  }
```
- Listen events from Push notification for wake up app (top level function. Example app.dart)
```dart
final pitelService = PitelServiceImpl();
final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
  
@override
  void initState() {
    super.initState();
    VoipNotifService.listenerEvent(
      callback: (event) {},
      onCallAccept: () {
        //! Re-register when user accept call
        handleRegister();
      },
      onCallDecline: () {},
      onCallEnd: () {
        pitelCall.hangup();
      },
    );
  }
```

## How to test
- Download & install app from link https://github.com/onmyway133/PushNotifications/releases

![push_img_2](assets/push_img/push_img_2.png)


- Fill information and click Send to Test Push Notification

Note: Add .voip after your bundleId to send voip push notification

Example: 
```
Your app bundleId: com.pitel.uikit.demo
Voip push Bundle Id: com.pitel.uikit.demo.voip
```
- IOS

![push_img_1](assets/push_img/push_img_1.png)

- Android: using above app or test from Postman

cURL

```dart
curl --location 'https://fcm.googleapis.com/fcm/send' \
--header 'Content-Type: application/json' \
--header 'Authorization: key=${server_key}' \
--data '{
    "registration_ids": [${device_token}],
    "data":{
        "uuid": "call_id",
        "nameCaller": "Anh Quang",
        "avatar": "Anh Quang",
        "phoneNumber": "0341111111",
        "appName": "Pitel Connnect"
    },
    "content_available": true,
    "priority": "high"
}'
```
