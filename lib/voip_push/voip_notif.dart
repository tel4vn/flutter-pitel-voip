import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming_timer/entities/call_event.dart';
import 'package:flutter_callkit_incoming_timer/flutter_callkit_incoming.dart';
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
          case Event.ACTION_CALL_INCOMING:
            if (onIncomingCall != null) {
              onIncomingCall(event);
            }
            break;
          case Event.ACTION_CALL_START:
            break;
          case Event.ACTION_CALL_ACCEPT:
            if (onCallAccept != null) {
              onCallAccept();
            }
            break;
          case Event.ACTION_CALL_DECLINE:
            if (onCallDecline != null) {
              onCallDecline(event);
            }
            break;
          case Event.ACTION_CALL_ENDED:
            if (onCallEnd != null) {
              onCallEnd();
            }
            break;
          case Event.ACTION_CALL_TIMEOUT:
            if (onCallTimeOut != null) {
              onCallTimeOut(event);
            }
            break;
          case Event.ACTION_CALL_CALLBACK:
            break;
          case Event.ACTION_CALL_TOGGLE_HOLD:
            break;
          case Event.ACTION_CALL_TOGGLE_MUTE:
            break;
          case Event.ACTION_CALL_TOGGLE_DMTF:
            break;
          case Event.ACTION_CALL_TOGGLE_GROUP:
            break;
          case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
            if (swipeInLockscreen != null) {
              swipeInLockscreen();
            }
            break;
          case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    } on Exception {
      if (kDebugMode) {
        print('=================Exception===============');
      }
    }
  }
}
