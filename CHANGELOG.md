# Changelog

## 1.0.7 - 2024-12-02

- Update package flutter_callkit_incoming to 2.0.0+2
- Fix error cancel fullscreen notifcation when call out cancel call.

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
