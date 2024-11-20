# Changelog

## 1.0.8+4 - 2024-11-19

- Feature hold call.
- Fix RECEIVER_EXPORTED on Android 14.

## 1.0.8+3 - 2024-11-14

- Remove code no use.

## 1.0.8+2 - 2024-11-06

- Update new documentation.

## 1.0.8+1 - 2024-10-31

- Update flutter_webrtc to version 0.11.5.

## 1.0.8 - 2024-09-09

- Support audio output selected for android device.

## 1.0.7+13 - 2024-06-07

- Remove custom options onBackgroundMessage.
- Update new documentation.

## 1.0.7+12 - 2024-05-14

- Add new function for initFirebase.

## 1.0.7+11 - 2024-04-08

- Fix encode name caller.

## 1.0.7+10 - 2024-04-04

- Update readme.
- Encode name caller.
- Support Bluetooth for audio.

## 1.0.7+8 - 2024-03-26

- Add name caller.
- Update guide for fcm v1.

## 1.0.7+5 - 2024-01-20

- Add loading when accept incoming call.

## 1.0.7+4 - 2024-01-17

- Fix bug change network wifi <-> mobile data.
- Add function outGoingCall.

## 1.0.7+3 - 2024-01-09

- Remove re-register when reopen app.
- Add count time IOS callkit.
- Refactor function outgoing call.

## 1.0.6+4 - 2023-12-25

- Fix bug IPv6

## 1.0.6+3 - 2023-11-27

- Fix bug remove device token

## 1.0.6+2 - 2023-11-27

- Update new push notification documentation.

## 1.0.6+1 - 2023-11-27

- Fixed some bugs.

## 1.0.6 - 2023-11-02

- Optimize register params (remove some field not use).
- Change package name from plugin_pitel to flutter_pitel_voip.

## 1.0.5 - 2023-10-11

- Update package to pub.dev
- Fixed bug callId null when hang up
- Update dependency flutter_webrtc: ^0.9.40
- Support flutter version 3.10.x

## 1.0.4 - 2023-10-2

- Add field sip domain.
- BLE support.

## 1.0.2 - 2023-06-10

- Minimize package import.
- Customize UI for Call screen.
- Update new widget PitelVoip (for app.dart), PitelVoipCall (for home_screen.dart), CallScreen (for call_screen).
- Feature cancel incoming call for IOS, for Android (stable in new version, waiting dependency flutter_callkit_incoming stable).
- Optimize websocket connection.
- Incoming call in lock screen.
- Re-register when open, re-open app: terminate, background, foreground app state.
- Fixed some bug: duplicate call, reconnect websocket,...
