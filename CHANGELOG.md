# Changelog

## 1.0.10+7

- Improve content-length handling in SIP message parsing.
- Simplify display name assignment and clean up debug logs in RTCSession.

## 1.0.10+6

- Upgrade AGP.
- Support flutter 3.38.1
- Upgrade package logger: ^2.6.2

## 1.0.10+2

- Support full screen intent android 13+.
- By pass lock screen.

## 1.0.9+1

- Update SDK for support AGP 8.6.1.
- Support flutter sdk lasted version.

## 1.0.8+4

- Feature hold call.
- Fix RECEIVER_EXPORTED on Android 14.

## 1.0.8+3

- Remove code no use.

## 1.0.8+2

- Update new documentation.

## 1.0.8+1

- Update flutter_webrtc to version 0.11.5.

## 1.0.8

- Support audio output selected for android device.

## 1.0.7+13

- Remove custom options onBackgroundMessage.
- Update new documentation.

## 1.0.7+12

- Add new function for initFirebase.

## 1.0.7+11

- Fix encode name caller.

## 1.0.7+10

- Update readme.
- Encode name caller.
- Support Bluetooth for audio.

## 1.0.7+8

- Add name caller.
- Update guide for fcm v1.

## 1.0.7+5

- Add loading when accept incoming call.

## 1.0.7+4

- Fix bug change network wifi <-> mobile data.
- Add function outGoingCall.

## 1.0.7+3

- Remove re-register when reopen app.
- Add count time IOS callkit.
- Refactor function outgoing call.

## 1.0.6+4

- Fix bug IPv6

## 1.0.6+3

- Fix bug remove device token

## 1.0.6+2

- Update new push notification documentation.

## 1.0.6+1

- Fixed some bugs.

## 1.0.6

- Optimize register params (remove some field not use).
- Change package name from plugin_pitel to flutter_pitel_voip.

## 1.0.5

- Update package to pub.dev
- Fixed bug callId null when hang up
- Update dependency flutter_webrtc: ^0.9.40
- Support flutter version 3.10.x

## 1.0.4

- Add field sip domain.
- BLE support.

## 1.0.2

- Minimize package import.
- Customize UI for Call screen.
- Update new widget PitelVoip (for app.dart), PitelVoipCall (for home_screen.dart), CallScreen (for call_screen).
- Feature cancel incoming call for IOS, for Android (stable in new version, waiting dependency flutter_callkit_incoming stable).
- Optimize websocket connection.
- Incoming call in lock screen.
- Re-register when open, re-open app: terminate, background, foreground app state.
- Fixed some bug: duplicate call, reconnect websocket,...
