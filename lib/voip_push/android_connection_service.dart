import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class CallkitParamsModel {
  final String uuid;
  final String nameCaller;
  final String avatar;
  final String phoneNumber;
  final String appName;
  final String? backgroundColor;

  CallkitParamsModel({
    required this.uuid,
    required this.nameCaller,
    required this.avatar,
    required this.phoneNumber,
    required this.appName,
    this.backgroundColor,
  });
}

class AndroidConnectionService {
  static Future<void> showCallkitIncoming(
      CallkitParamsModel callKitParams) async {
    // final params = CallKitParams(
    //   id: callKitParams.uuid,
    //   nameCaller: callKitParams.nameCaller,
    //   appName: callKitParams.appName,
    //   avatar: callKitParams.avatar,
    //   handle: callKitParams.phoneNumber,
    //   type: 0,
    //   duration: 30000,
    //   textAccept: 'Accept',
    //   textDecline: 'Decline',
    //   textMissedCall: 'Missed call',
    //   textCallback: 'Call back',
    //   android: AndroidParams(
    //     isCustomNotification: true,
    //     isShowLogo: false,
    //     isShowCallback: false,
    //     isShowMissedCallNotification: true,
    //     ringtonePath: 'system_ringtone_default',
    //     backgroundColor: callKitParams.backgroundColor ?? '#0955fa',
    //     backgroundUrl: 'assets/test.png',
    //     actionColor: '#4CAF50',
    //   ),
    // );
    // await FlutterCallkitIncoming.showCallkitIncoming(params);
    final config = CallKeepIncomingConfig(
      uuid: "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      callerName: 'Quang Duong',
      appName: callKitParams.appName,
      avatar: 'https://i.pravatar.cc/100',
      handle: callKitParams.phoneNumber,
      hasVideo: false,
      duration: 30000,
      acceptText: 'Accept',
      declineText: 'Decline',
      missedCallText: 'Missed call',
      callBackText: 'Call back',
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      androidConfig: CallKeepAndroidConfig(
        logo: "ic_logo",
        showCallBackAction: true,
        showMissedCallNotification: true,
        ringtoneFileName: 'system_ringtone_default',
        accentColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        incomingCallNotificationChannelName: 'Incoming Calls',
        missedCallNotificationChannelName: 'Missed Calls',
      ),
      iosConfig: CallKeepIosConfig(
        iconName: 'CallKitLogo',
        handleType: CallKitHandleType.generic,
        isVideoSupported: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtoneFileName: 'system_ringtone_default',
      ),
    );
    await CallKeep.instance.displayIncomingCall(config);
  }
}
