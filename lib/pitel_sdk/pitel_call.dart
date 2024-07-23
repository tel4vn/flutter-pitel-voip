import 'dart:io';
import 'dart:developer';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:plugin_pitel/component/pitel_call_state.dart';
import 'package:plugin_pitel/component/pitel_rtc_video_renderer.dart';
import 'package:plugin_pitel/component/pitel_ua_helper.dart';
import 'package:plugin_pitel/component/sip_pitel_helper_listener.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_log.dart';
import 'package:plugin_pitel/sip/sip_ua.dart';
import 'package:uuid/uuid.dart';

import 'pitel_client.dart';
import 'package:throttling/throttling.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final thr = Throttling(duration: const Duration(milliseconds: 2000));

class PitelCall implements SipUaHelperListener {
  final PitelLog _logger = PitelLog(tag: 'PitelCall');
  PitelRTCVideoRenderer? _localRenderer;
  PitelRTCVideoRenderer? _remoteRenderer;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final List<SipPitelHelperListener> _sipPitelHelperListener = [];
  final Map<String, PitelCallState> _states = {};
  final PitelUAHelper _sipuaHelper = PitelUAHelper();
  bool _audioMuted = false;
  bool _videoIsOff = false;
  bool hold = false;
  String? _holdOriginator;
  bool _isListen = false;

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  PitelRTCVideoRenderer? get localRenderer => _localRenderer;
  PitelRTCVideoRenderer? get remoteRenderer => _remoteRenderer;
  String? get remoteIdentity => _callIdCurrent != null
      ? _sipuaHelper.findCall(_callIdCurrent!)?.remote_identity
      : "";
  String? get localIdentity => _callIdCurrent != null
      ? _sipuaHelper.findCall(_callIdCurrent!)?.local_identity
      : "";
  String? get direction => _callIdCurrent != null
      ? _sipuaHelper.findCall(_callIdCurrent!)?.direction
      : "";
  String? get remoteDisplayName => _callIdCurrent != null
      ? _sipuaHelper.findCall(_callIdCurrent!)?.remote_display_name
      : "";
  bool get videoIsOff => _videoIsOff;
  bool get audioMuted => _audioMuted;
  String? get holdOriginator => _holdOriginator;
  bool get isConnected => _sipuaHelper.connected;
  bool get isHaveCall => _callIdCurrent?.isNotEmpty ?? false;
  String? _callIdCurrent;
  bool isBusy = false;
  String _outPhone = "";
  String _nameCaller = "";
  ConnectivityResult _checkConnectivity = ConnectivityResult.none;
  ConnectivityResult get checkConnectivity => _checkConnectivity;
  String? _wifiIP;
  bool _isTransferCall = false;
  bool _reconnect = false;

  bool get isTransferCall => _isTransferCall;
  String get outPhone => _outPhone;
  String get nameCaller => _nameCaller;
  bool get reconnect => _reconnect;
  final checkIsNumber = RegExp(r'^[+,*]?\d+[#]?$');

  void setTransferCall(bool value) {
    _isTransferCall = value;
  }

  void resetOutPhone() {
    _outPhone = "";
  }

  void resetNameCaller() {
    _nameCaller = "";
  }

  void setReconnect() {
    _reconnect = !_reconnect;
  }

  void resetConnectivity() {
    _checkConnectivity = ConnectivityResult.none;
  }

  void setCallCurrent(String? id) {
    _callIdCurrent = id;
  }

  Future<void> initializeLocal() async {
    _localRenderer ??= PitelRTCVideoRenderer();
    await _localRenderer?.initialize();
  }

  Future<void> initializeRemote() async {
    _remoteRenderer ??= PitelRTCVideoRenderer();
    await _remoteRenderer?.initialize();
  }

  Future<void> disposeLocalRenderer() async {
    if (_localRenderer != null) {
      await _localRenderer?.dispose();
      _localRenderer = null;
    }
  }

  Future<void> disposeRemoteRenderer() async {
    if (_remoteRenderer != null) {
      await _remoteRenderer?.dispose();
      _remoteRenderer = null;
    }
  }

  void addListener(SipPitelHelperListener listener) {
    if (!_sipPitelHelperListener.contains(listener)) {
      _sipPitelHelperListener.add(listener);
    }
    if (!_isListen) {
      _isListen = true;
      _sipuaHelper.addSipUaHelperListener(this);
    }
  }

  void removeListener(SipPitelHelperListener listener) {
    if (_sipPitelHelperListener.contains(listener)) {
      _sipPitelHelperListener.remove(listener);
    }
    if (_isListen && _sipPitelHelperListener.isEmpty) {
      _sipuaHelper.removeSipUaHelperListener(this);
    }
  }

  bool isVoiceOnly() {
    if (_localStream == null) {
      if (_remoteStream == null) {
        return true;
      } else if (_remoteStream!.getVideoTracks().isEmpty) {
        return true;
      }
    } else if (_localStream!.getVideoTracks().isEmpty) {
      if (_remoteStream == null) {
        return true;
      } else if (_remoteStream!.getVideoTracks().isEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  void callStateChanged(Call call, PitelCallState pitelCallState) {
    _logger.info('callStateChanged  ${pitelCallState.state.toString()}');
    _logger.info('callLocal ${call.local_identity}');
    _logger.info('callRemoter ${call.remote_identity}');
    _logger.info('callDirection ${call.direction}');
    switch (pitelCallState.state) {
      case PitelCallStateEnum.CALL_INITIATION:
        print(_sipPitelHelperListener);
        switch (call.direction) {
          case 'OUTGOING':
            for (var element in _sipPitelHelperListener) {
              element.onCallInitiated(call.id!);
            }
            break;
          case 'INCOMING':
            for (var element in _sipPitelHelperListener) {
              if (isBusy) {
                _releaseCall(callId: call.id);
              } else {
                element.onCallReceived(call.id!);
              }
            }
            break;
        }
        break;
      case PitelCallStateEnum.HOLD:
      case PitelCallStateEnum.UNHOLD:
        hold = pitelCallState.state == PitelCallStateEnum.HOLD;
        _holdOriginator = pitelCallState.originator;
        break;
      case PitelCallStateEnum.STREAM:
        _handelStreams(pitelCallState);
        for (var element in _sipPitelHelperListener) {
          element.callStateChanged(call.id!, pitelCallState);
        }
        break;
      case PitelCallStateEnum.MUTED:
        if (pitelCallState.audio) _audioMuted = true;
        if (pitelCallState.video) _videoIsOff = true;
        for (var element in _sipPitelHelperListener) {
          element.callStateChanged(call.id!, pitelCallState);
        }
        break;
      case PitelCallStateEnum.UNMUTED:
        if (pitelCallState.audio) _audioMuted = false;
        if (pitelCallState.video) _videoIsOff = false;
        for (var element in _sipPitelHelperListener) {
          element.callStateChanged(call.id!, pitelCallState);
        }
        break;
      default:
        for (var element in _sipPitelHelperListener) {
          element.callStateChanged(call.id!, pitelCallState);
        }
    }
  }

  String? getState({String? callId}) {
    if (callId == null) {
      if (!callCurrentIsEmpty()) {
        return _states[_callIdCurrent]?.state.toString();
      } else {
        _logger.error('You have to set callIdCurrent or pass param callId');
        return 'UNKNOWN';
      }
    } else {
      return _states[callId]?.state.toString();
    }
  }

  void _releaseCall({String? callId}) {
    _audioMuted = false;
    if (callId == null) {
      // _sipuaHelper.findCall(_callIdCurrent!)?.hangup({'status_code': 603});
      setCallCurrent(null);
    } else {
      _sipuaHelper.findCall(callId)?.hangup({'status_code': 603});
      setCallCurrent(null);
    }
  }

  String getRegisterState() {
    return EnumHelper.getName(_sipuaHelper.registerState.state);
  }

  void _handelStreams(PitelCallState event) {
    final stream = event.stream;
    if (event.originator == 'local') {
      if (_localRenderer != null) {
        _localRenderer?.srcObject = stream;
      }
      // TODO: bluetooth
      // Helper.setSpeakerphoneOn(false);
      // enableSpeakerphone(false);
      _localStream = stream;
    }
    if (event.originator == 'remote') {
      if (_remoteRenderer != null) {
        _remoteRenderer?.srcObject = stream;
      }
      _remoteStream = stream;
    }
  }

  bool mute({String? callId}) {
    if (callId == null) {
      if (!callCurrentIsEmpty()) {
        Call? call = _sipuaHelper.findCall(_callIdCurrent!);
        if (call != null) {
          if (_audioMuted) {
            call.unmute(true, false);
            Helper.setMicrophoneMute(false, _localStream!.getAudioTracks()[0]);
          } else {
            call.mute(true, false);
            Helper.setMicrophoneMute(true, _localStream!.getAudioTracks()[0]);
          }
          return true;
        }
        return false;
      } else {
        _logger.error('You have to set callIdCurrent or pass param callId');
        return false;
      }
    } else {
      Call? call = _sipuaHelper.findCall(callId);
      if (call != null) {
        if (_audioMuted) {
          call.unmute(true, false);
          Helper.setMicrophoneMute(false, _localStream!.getAudioTracks()[0]);
        } else {
          call.mute(true, false);
          Helper.setMicrophoneMute(true, _localStream!.getAudioTracks()[0]);
        }
        return true;
      }
      return false;
    }
  }

  void enableSpeakerphone(bool enable) async {
    // Helper.setSpeakerphoneOn(enable);
    final audioOutput = await Helper.audiooutputs;
    inspect(audioOutput);

    if (enable) {
      Helper.selectAudioOutput('speaker');
    } else {
      Helper.selectAudioOutput('earpiece');
    }
  }

  bool toggleCamera({String? callId}) {
    if (callId == null) {
      if (!callCurrentIsEmpty()) {
        Call? call = _sipuaHelper.findCall(_callIdCurrent!);
        if (call != null) {
          if (_videoIsOff) {
            call.unmute(false, true);
          } else {
            call.mute(false, true);
          }
          return true;
        }
        return false;
      } else {
        _logger.error('You have to set callIdCurrent or pass param callId');
        return false;
      }
    } else {
      Call? call = _sipuaHelper.findCall(callId);
      if (call != null) {
        if (_videoIsOff) {
          call.unmute(false, true);
        } else {
          call.mute(false, true);
        }
        return true;
      }
      return false;
    }
  }

  bool sendDTMF(String tone, {String? callId}) {
    print('Dtmf tone => $tone');
    if (callId == null) {
      if (!callCurrentIsEmpty()) {
        Call? call = _sipuaHelper.findCall(_callIdCurrent!);
        if (call != null) {
          call.sendDTMF(tone);
          return true;
        }
        return false;
      } else {
        _logger.error('You have to set callIdCurrent or pass param callId');
        return false;
      }
    } else {
      Call? call = _sipuaHelper.findCall(callId);
      if (call != null) {
        call.sendDTMF(tone);
        return true;
      }
      return false;
    }
  }

  bool refer(String target, {String? callId}) {
    if (callId == null) {
      if (!callCurrentIsEmpty()) {
        Call? call = _sipuaHelper.findCall(_callIdCurrent!);
        if (call != null) {
          Map<String, dynamic> options = _sipuaHelper.buildCallOptions(true);
          call.refer(target, options);
          return true;
        }
        return false;
      } else {
        _logger.error('You have to set callIdCurrent or pass param callId');
        return false;
      }
    } else {
      Call? call = _sipuaHelper.findCall(callId);
      if (call != null) {
        Map<String, dynamic> options = _sipuaHelper.buildCallOptions(true);
        call.refer(target, options);
        return true;
      }
      return false;
    }
  }

  bool toggleHold({String? callId}) {
    UnimplementedError('Hold not implement yet');
    return false;
    // if (callId == null) {
    //   if (!callCurrentIsEmpty()) {
    //     if (_calls[_callIdCurrent] != null) {
    //       if (hold) {
    //         _calls[_callIdCurrent]!.unhold();
    //       } else {
    //         _calls[_callIdCurrent]!.hold();
    //       }
    //       return true;
    //     }
    //     return false;
    //   } else {
    //     _logger.error('You have to set callIdCurrent or pass param callId');
    //     return false;
    //   }
    // } else {
    //   if (_calls[callId] != null) {
    //     if (hold) {
    //       _calls[callId]!.unhold();
    //     } else {
    //       _calls[callId]!.hold();
    //     }
    //     return true;
    //   }
    //   return false;
    // }
  }

  Future<bool> call(String dest, [bool voiceonly = true]) async {
    return _sipuaHelper.call(dest, voiceonly: voiceonly);
  }

  bool hangup({String? callId}) {
    if (callId == null) {
      if (!callCurrentIsEmpty() &&
          _sipuaHelper.findCall(_callIdCurrent!) != null) {
        _releaseCall(callId: _callIdCurrent);
        return true;
      } else {
        _releaseCall(callId: null); //! WARNING: check releaseCall
        // _logger.error('You have to set callIdCurrent or pass param callId');
        return true;
      }
    } else {
      if (_sipuaHelper.findCall(callId) != null) {
        _releaseCall(callId: callId);
        return true;
      }
      return false;
    }
  }

  bool answer({String? callId}) {
    if (callId == null) {
      if (!callCurrentIsEmpty() &&
          _sipuaHelper.findCall(_callIdCurrent!) != null) {
        _sipuaHelper
            .findCall(_callIdCurrent!)!
            .answer(_sipuaHelper.buildCallOptions());
        return true;
      } else {
        _logger.error('You have to set callIdCurrent or pass param callId');
        return false;
      }
    } else {
      if (_sipuaHelper.findCall(callId) != null) {
        _sipuaHelper.findCall(callId)!.answer(_sipuaHelper.buildCallOptions());
        return true;
      }
      return false;
    }
  }

  bool callCurrentIsEmpty() {
    return _callIdCurrent == null || _callIdCurrent!.isEmpty;
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    _sipPitelHelperListener.forEach((element) {
      final message = PitelSIPMessageRequest(
          msg.message!, msg.originator ?? "", msg.request);
      element.onNewMessage(message);
    });
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    _sipPitelHelperListener.forEach((element) {
      final registerState = PitelRegistrationState(state);
      element.registrationStateChanged(registerState);
    });
  }

  @override
  void transportStateChanged(PitelTransportState state) {
    _sipPitelHelperListener.forEach((element) {
      element.transportStateChanged(state);
    });
  }

  void register(PitelSettings settings) {
    _sipuaHelper.start(settings);
  }

  void unregister() {
    _sipuaHelper.stop();
    if (_sipuaHelper.registered) {
      _sipuaHelper.unregister();
    }
  }

  void busyNow() {
    isBusy = true;
  }

  void outGoingCall({
    required String phoneNumber,
    required VoidCallback handleRegisterCall,
    String nameCaller = '',
    String domainUrl = 'google.com',
    bool enableLoading = true,
  }) {
    thr.throttle(() async {
      _dismissLoading();
      if (enableLoading) {
        EasyLoading.show(status: "Connecting...");
      }
      if (!checkIsNumber.hasMatch(phoneNumber)) {
        EasyLoading.showToast(
          'Invalid phone number',
          toastPosition: EasyLoadingToastPosition.center,
        );
        return;
      }
      _outPhone = phoneNumber;
      _nameCaller = nameCaller;

      // final pingRes = await Ping(domainUrl, count: 1).stream.first;
      // if (pingRes.response != null) {
      //   final Duration time = pingRes.response!.time!;
      //   final miliTime = time.inMilliseconds;
      //   if (miliTime > 5000) {
      //     EasyLoading.showToast(
      //       'Network connection is unstable. Please try again later!',
      //       duration: const Duration(seconds: 2),
      //     );
      //     return;
      //   }
      // }

      //! CALL WAITING
      if (Platform.isIOS) {
        FlutterCallkitIncoming.endAllCalls();
        var newUUID = const Uuid().v4();
        CallKitParams params = CallKitParams(
          id: newUUID,
          nameCaller: phoneNumber,
          handle: phoneNumber,
          type: 0,
          ios: IOSParams(handleType: 'generic'),
        );
        await FlutterCallkitIncoming.startCall(params);
      }

      final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
      final PitelClient pitelClient = PitelClient.getInstance();
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _checkConnectivity = ConnectivityResult.none;
        EasyLoading.showToast(
          'Please check your network',
          toastPosition: EasyLoadingToastPosition.center,
        );
        return;
      }
      if (connectivityResult != _checkConnectivity) {
        _checkConnectivity = connectivityResult;
        // EasyLoading.show(status: "Connecting...");
        handleRegisterCall();
        return;
      }

      if (connectivityResult == ConnectivityResult.wifi) {
        try {
          final wifiIP = await NetworkInfo().getWifiIP();
          if (wifiIP != _wifiIP) {
            _wifiIP = wifiIP;
            // EasyLoading.show(status: "Connecting...");
            handleRegisterCall();
            return;
          }
        } catch (error) {
          // EasyLoading.show(status: "Connecting...");
          handleRegisterCall();
          return;
        }
      }

      final isRegistered = pitelCall.getRegisterState();
      if (isRegistered == 'Registered') {
        //! CALL WAITING
        EasyLoading.dismiss();
        if (Platform.isIOS) {
          // EasyLoading.show(status: "Connecting...");
          await Future.delayed(const Duration(milliseconds: 500));
        }
        pitelClient
            .call(phoneNumber, true)
            .then((value) => value.fold((succ) => "OK", (err) {
                  FlutterCallkitIncoming.endAllCalls();
                  EasyLoading.showToast(
                    err.toString(),
                    toastPosition: EasyLoadingToastPosition.center,
                  );
                }));
      } else {
        // EasyLoading.show(status: "Connecting...");
        handleRegisterCall();
      }
    });
  }

  void _dismissLoading() async {
    await Future.delayed(const Duration(seconds: 10));
    EasyLoading.dismiss();
  }
}
