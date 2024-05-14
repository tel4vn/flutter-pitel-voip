# Pitel Voip Push notification

> **Warning**
> IOS only working on real device, not on simulator (Callkit framework not working on simulator)

## Pitel Connect Flow

When user make call from Pitel Connect app, Pitel Server pushes a notification for all user login (who receives the call). When user "Accept" call, extension will re-register to receive call.
![Pitel Connect Flow](assets/images/pitel_connect_flow.png)

## Image callkit

<table>
  <tr>
    <td>iOS(Alert)</td>
    <td>iOS(Lockscreen)</td>
    <td>iOS(full screen)</td>
  </tr>
  <tr>
    <td>
      <img src="assets/images/call_kit_1.png" width="220">
    </td>
    <td>
      <img src="assets/images/call_kit_2.png" width="220">
    </td>
    <td>
      <img src="assets/images/call_kit_3.png" width="220">
    </td>
  </tr>
  <tr>	  
    <td>Android(Alert) - Audio</td>
    <td>Android(Lockscreen | Fullscreen) - Audio</td>
  </tr>
  <tr>
    <td>
      <img src="assets/images/call_kit_android_1.png" width="220">
    </td>
    <td>
      <img src="assets/images/call_kit_android_2.png" width="220">
    </td>
  </tr>
 </table>
 
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
- **Export the .p12 file and config in [pitel portal](https://github.com/anhquangmobile/react-native-pitel-voip/blob/main/PORTAL_GUIDE.md)**
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

##### Installing your Firebase configuration file

- Next you must add the file to the project using Xcode (adding manually via the filesystem won't link the file to the project). Using Xcode, open the project's ios/{projectName}.xcworkspace file. Right click Runner from the left-hand side project navigation within Xcode and select "Add files", as seen below:
  ![ios_google_service_1](assets/push_img/ios_google_service_1.png)
- Select the GoogleService-Info.plist file you downloaded, and ensure the "Copy items if needed" checkbox is enabled:
  ![ios_google_service_2](assets/push_img/ios_google_service_2.png)

#### Android

Using FCM (Firebase Cloud Message) to handle push notification wake up app when app run on Background or Terminate

> **Warning**
> Popup request permission only working with targetSdkVersion >= 33

- Access link [https://console.firebase.google.com/u/0/project/\_/notification](https://console.firebase.google.com/u/0/project/_/notification)
- Create your packageId for android app
  ![push_img_4](assets/push_img/push_img_4.png)
- Download & copy file google_service.json -> replace file google_service.json in path: `android/app/google_service.json`

##### Firebase Project

- Go to Project settings > Cloud Messaging and select Manage API in Google Cloud Console to open Google Cloud Console.
  ![fcm1](assets/push_img/fcm1.png)
- Go to API Library using the back button as shown below.
  ![fcm2](assets/push_img/fcm2.png)
- Search "cloud messaging" -> Select "Cloud Messaging"
  ![fcm3](assets/push_img/fcm3.png)
- Click Enable to start using the Cloud Messaging API.
  ![fcm4](assets/push_img/fcm4.png)

##### Service Account

- Go to [sevice account](https://console.cloud.google.com/apis/credentials)
- In tab "Credentials", scroll to "Service Accounts", click button edit with name "firebase-adminsdk".
  ![fcm5](assets/push_img/fcm5.png)
- Choose tab KEYS, click "Add key" -> "Create new key" and download json file.
  ![fcm6](assets/push_img/fcm6.png)

> **Note**
> After complete all step Setup. Please send information to dev of Tel4vn in [here](https://portal-sdk.tel4vn.com/)

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

[https://github.com/tel4vn/pitel-ui-kit/blob/1.0.7/ios/Runner/AppDelegate.swift](https://github.com/tel4vn/pitel-ui-kit/blob/1.0.7/ios/Runner/AppDelegate.swift)

## **Usage**

- Before handle Incoming call, you should import package in home screen

```dart
import "package:flutter_pitel_voip/flutter_pitel_voip.dart";
```

- Initialize firebase

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotifAndroid.initFirebase(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // add here

  runApp(MyApp());
}
```

- Config firebase_options.dart. [example](https://github.com/tel4vn/pitel-ui-kit/blob/1.0.7/lib/firebase_options.dart).

- Get device push token VoIP.

```dart
await PushVoipNotif.getDeviceToken();
```

- Get fcm token.

```dart
await PushVoipNotif.getFcmToken();
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
curl --location 'https://fcm.googleapis.com/v1/projects/pitel-87bff/messages:send' \
--header 'Content-Type: application/json' \
--data '{
    "message": {
        "notification": {
            "title": "FCM Message",
            "body": "This is an FCM Message"
        },
        "data": {
            "uuid": "77712f3-9b56-4e26-96ea-382ea1206477",
            "nameCaller": "Anh Quang",
            "avatar": "Anh Quang",
            "phoneNumber": "0375624006",
            "appName": "Pitel Connnect",
            "callType": "CALL"

        },
        "apns": {
            "headers": {
                "apns-priority": "10",

                "sound": ""
            },
            "payload": {
                "aps": {
                    "mutable-content": 1,
                    "content-available": 1
                }
            }
        },
        "android": {
            "priority": "high"
        },
        "token": "fcm_token is here"
    }
}'
```
