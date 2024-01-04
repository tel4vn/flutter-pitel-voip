import 'package:flutter/foundation.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'dart:async';

class VoipNotifService {
  static Future<void> listenerEvent({
    Function? callback,
    Function? onCallAccept,
    Function(CallEvent event)? onCallDecline,
    Function(CallEvent event)? onIncomingCall,
    Function(CallEvent event)? onCallTimeOut,
    Function? swipeInLockscreen,
    Function? onCallEnd,
  }) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        switch (event!.event) {
          case Event.actionCallIncoming:
            if (onIncomingCall != null) {
              onIncomingCall(event);
            }
            break;
          case Event.actionCallStart:
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            break;
          case Event.actionCallAccept:
            if (onCallAccept != null) {
              onCallAccept();
            }
            break;
          case Event.actionCallDecline:
            if (onCallDecline != null) {
              onCallDecline(event);
            }
            break;
          case Event.actionCallEnded:
            if (onCallEnd != null) {
              onCallEnd();
            }
            break;
          case Event.actionCallTimeout:
            if (onCallTimeOut != null) {
              onCallTimeOut(event);
            }
            break;
          case Event.actionCallCallback:
            // TODO: only Android - click action `Call back` from missed call notification
            break;
          case Event.actionCallToggleHold:
            // TODO: only iOS
            break;
          case Event.actionCallToggleMute:
            // TODO: only iOS
            break;
          case Event.actionCallToggleDmtf:
            // TODO: only iOS
            break;
          case Event.actionCallToggleGroup:
            // TODO: only iOS
            break;
          case Event.actionCallToggleAudioSession:
            if (swipeInLockscreen != null) {
              swipeInLockscreen();
            }
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            // TODO: only iOS
            break;
          case Event.actionCallCustom:
            // TODO: Handle this case.
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });

      CallKeep.instance.onEvent.listen((event) async {
        // TODO: Implement other events
        if (event == null) return;
        switch (event.type) {
          case CallKeepEventType.callAccept:
            final data = event.data as CallKeepCallData;
            print('call answered: ${data.toMap()}');
            if (onCallAccept != null) {
              onCallAccept();
            }
            break;
          case CallKeepEventType.callDecline:
            final data = event.data as CallKeepCallData;
            print('call declined: ${data.toMap()}');
            // if (onCallDecline != null) {
            //   onCallDecline(event);
            // }
            break;
          default:
            break;
        }
      });
    } on Exception {
      if (kDebugMode) {
        print('=================Exception===============');
      }
    }
  }
}
