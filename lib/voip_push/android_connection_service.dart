import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class CallkitParamsModel {
  final String uuid;
  final String nameCaller;
  final String avatar;
  final String phoneNumber;
  final String appName;

  CallkitParamsModel({
    required this.uuid,
    required this.nameCaller,
    required this.avatar,
    required this.phoneNumber,
    required this.appName,
  });
}

class AndroidConnectionService {
  static Future<void> showCallkitIncoming(
      CallkitParamsModel callKitParams) async {
    final params = CallKitParams(
      id: callKitParams.uuid,
      nameCaller: callKitParams.nameCaller,
      appName: callKitParams.appName,
      avatar: callKitParams.avatar,
      handle: callKitParams.phoneNumber,
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      textMissedCall: 'Missed call',
      textCallback: 'Call back',
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        isShowCallback: true,
        isShowMissedCallNotification: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}
