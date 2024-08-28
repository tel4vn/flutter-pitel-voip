import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioHelper {
  static String audioOutputText(String audioValue) {
    switch (audioValue) {
      case 'speaker':
        return 'Speaker';
      case 'earpiece':
        return 'Earpiece';
      case 'bluetooth':
        return 'Bluetooth';
      case 'wired-headset':
        return 'Wired headset';
      default:
        return 'Earpiece';
    }
  }

  static IconData audioOutputIcon(String audioValue) {
    switch (audioValue) {
      case 'speaker':
        return Icons.volume_up;
      case 'earpiece':
        return Icons.volume_down;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'wired-headset':
        return Icons.headphones;
      default:
        return Icons.volume_down;
    }
  }

  static IconData audioOutputIconIOS(bool isSpeakerOn) {
    if (isSpeakerOn) {
      return Icons.volume_up;
    } else {
      return Icons.volume_off;
    }
  }

  static Future<String> audioPrefer() async {
    final audioOutput = await Helper.audiooutputs;
    final preferBluetooth =
        audioOutput.where((item) => item.deviceId == 'bluetooth');
    if (preferBluetooth.isNotEmpty) {
      return 'bluetooth';
    }
    final preferWiredHeadset =
        audioOutput.where((item) => item.deviceId == 'wired-headset');
    if (preferWiredHeadset.isNotEmpty) {
      return 'wired-headset';
    }
    return 'earpiece';
  }

  static Future<bool?> isMicroValid() async {
    if (Platform.isIOS) return null;
    final devices = await navigator.mediaDevices.enumerateDevices();
    final audioInput =
        devices.where((device) => device.kind == 'audioinput').toList();
    final preferMicro =
        audioInput.where((item) => item.deviceId == 'microphone-bottom');

    if (preferMicro.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
