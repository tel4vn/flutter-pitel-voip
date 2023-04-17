import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'dart:async';

class VoipNotifService {
  static Future<void> listenerEvent({
    Function? callback,
    Function? onCallAccept,
    Function? onCallDecline,
  }) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        // inspect(event);
        // var _timer = Timer(Duration(seconds: 3), () {
        //   print('done');
        //   await FlutterCallkitIncoming.endAllCalls();
        // });
        switch (event!.event) {
          case Event.ACTION_CALL_INCOMING:
            // TODO: received an incoming call
            break;
          case Event.ACTION_CALL_START:
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            break;
          case Event.ACTION_CALL_ACCEPT:
            if (onCallAccept != null) {
              onCallAccept();
            }
            break;
          case Event.ACTION_CALL_DECLINE:
            if (onCallDecline != null) {
              onCallDecline();
            }
            break;
          case Event.ACTION_CALL_ENDED:
            // TODO: ended an incoming/outgoing call
            break;
          case Event.ACTION_CALL_TIMEOUT:
            // TODO: missed an incoming call
            break;
          case Event.ACTION_CALL_CALLBACK:
            // TODO: only Android - click action `Call back` from missed call notification
            break;
          case Event.ACTION_CALL_TOGGLE_HOLD:
            // TODO: only iOS
            break;
          case Event.ACTION_CALL_TOGGLE_MUTE:
            // TODO: only iOS
            break;
          case Event.ACTION_CALL_TOGGLE_DMTF:
            // TODO: only iOS
            break;
          case Event.ACTION_CALL_TOGGLE_GROUP:
            // TODO: only iOS
            break;
          case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
            // TODO: only iOS
            break;
          case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
            // TODO: only iOS
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
