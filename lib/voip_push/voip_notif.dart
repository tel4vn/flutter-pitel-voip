import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'dart:async';

class VoipNotifService {
  static Future<void> listenerEvent({
    Function? callback,
    Function? onCallAccept,
    Function? onCallDecline,
    Function? swipeInLockscreen,
    Function? onCallEnd,
  }) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        switch (event!.event) {
          case Event.actionCallAccept:
            if (onCallAccept != null) {
              onCallAccept();
            }
            break;
          case Event.actionCallDecline:
            if (onCallDecline != null) {
              onCallDecline();
            }
            break;
          case Event.actionCallEnded:
            if (onCallEnd != null) {
              onCallEnd();
            }
            break;
          case Event.actionCallToggleAudioSession:
            if (swipeInLockscreen != null) {
              swipeInLockscreen();
            }
            break;
          case Event.actionCallTimeout:
            // TODO: Handle this case.
            break;
          case Event.actionCallCallback:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleHold:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleMute:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleDmtf:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleGroup:
            // TODO: Handle this case.
            break;
          case Event.actionCallCustom:
            // TODO: Handle this case.
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            // TODO: Handle this case.
            break;
          case Event.actionCallIncoming:
            // TODO: Handle this case.
            break;
          case Event.actionCallStart:
            // TODO: Handle this case.
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    } on Exception {
      print('=================Exception===============');
    }
  }
}
