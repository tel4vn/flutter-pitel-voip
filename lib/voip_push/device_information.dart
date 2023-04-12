import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInformation {
  static Future<bool> checkIsPhysicalDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice;
    }
    if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice;
    }

    return false;
  }
}
