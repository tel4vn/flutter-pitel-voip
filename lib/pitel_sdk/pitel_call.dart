import 'dart:io';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming_timer/entities/entities.dart';
import 'package:flutter_callkit_incoming_timer/flutter_callkit_incoming.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:plugin_pitel/component/loading/pitel_loading.dart';
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
  bool _isHoldCall = false;
  bool _holdCall = false;

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
  bool get holdCall => _holdCall;
  bool get isHoldCall => _isHoldCall;
  String? get holdOriginator => _holdOriginator;
  bool get isConnected => _sipuaHelper.connected;
  bool get isHaveCall => _callIdCurrent?.isNotEmpty ?? false;
  String? _callIdCurrent;
  bool isBusy = false;
  String _outPhone = "";
  String _nameCaller = "";
  List<ConnectivityResult> _checkConnectivity = [ConnectivityResult.none];
  List<ConnectivityResult> get checkConnectivity => _checkConnectivity;
  String? _wifiIP;
  bool _isTransferCall = false;
  bool _reconnect = false;

  bool get isTransferCall => _isTransferCall;
  String get outPhone => _outPhone;
  String get nameCaller => _nameCaller;
  bool get reconnect => _reconnect;

  String _audioSelected = 'earpiece';
  String get audioSelected => _audioSelected;

  final checkIsNumber = RegExp(r'^[+,*]?\d+[#]?$');

  void setTransferCall(bool value) {
    _isTransferCall = value;
  }

  void setIsHoldCall(bool value) {
    _isHoldCall = value;
    _holdCall = false;
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
    _checkConnectivity = [ConnectivityResult.none];
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
        _holdCall = pitelCallState.state == PitelCallStateEnum.HOLD;
        _holdOriginator = pitelCallState.originator;
        break;
      case PitelCallStateEnum.STREAM:
        _handleStreams(pitelCallState);
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

  void _handleStreams(PitelCallState event) {
    final stream = event.stream;
    if (event.originator == 'local') {
      if (_localRenderer != null) {
        _localRenderer?.srcObject = stream;
      }
      if (Platform.isIOS) {
        Helper.setSpeakerphoneOn(false);
      } else {
        // Helper.selectAudioInput("microphone-bottom");
        // Helper.selectAudioOutput('speaker');
        selectPreferHeadphone();
      }

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
    Helper.setSpeakerphoneOn(enable);
  }

  void setAudioPlatform() {
    if (Platform.isIOS) {
      Helper.setSpeakerphoneOn(false);
    } else {
      selectPreferHeadphone();
    }
  }

  void selectPreferHeadphone() async {
    final audioOutput = await Helper.audiooutputs;
    final preferBluetooth =
        audioOutput.where((item) => item.deviceId == 'bluetooth');
    if (preferBluetooth.isNotEmpty) {
      Helper.selectAudioOutput('bluetooth');
      Helper.selectAudioInput("bluetooth");
      _audioSelected = 'bluetooth';
      return;
    }
    final preferWiredHeadset =
        audioOutput.where((item) => item.deviceId == 'wired-headset');
    if (preferWiredHeadset.isNotEmpty) {
      Helper.selectAudioOutput('wired-headset');
      Helper.selectAudioInput("wired-headset");
      _audioSelected = 'wired-headset';
      return;
    }

    final devices = await navigator.mediaDevices.enumerateDevices();
    final audioInput =
        devices.where((device) => device.kind == 'audioinput').toList();

    final preferMicro =
        audioInput.where((item) => item.deviceId == 'microphone-bottom');

    if (preferMicro.isNotEmpty) {
      Helper.selectAudioInput("microphone-bottom");
    } else {
      Helper.setSpeakerphoneOn(false);
    }

    Helper.selectAudioOutput('earpiece');
    _audioSelected = 'earpiece';
  }

  void selectAudioRoute({
    required String speakerSelected,
  }) async {
    switch (speakerSelected) {
      case 'speaker':
        Helper.selectAudioOutput('speaker');
        Helper.selectAudioInput("microphone-back");
        _audioSelected = 'speaker';
        break;
      case 'earpiece':
        Helper.selectAudioOutput('earpiece');
        Helper.selectAudioInput("microphone-bottom");
        _audioSelected = 'earpiece';

        break;
      case 'bluetooth':
        Helper.selectAudioOutput('bluetooth');
        Helper.selectAudioInput("bluetooth");
        _audioSelected = 'bluetooth';
        break;
      case 'wired-headset':
        Helper.selectAudioOutput('wired-headset');
        Helper.selectAudioInput("wired-headset");
        _audioSelected = 'wired-headset';
        break;
      default:
        Helper.selectAudioOutput('earpiece');
        Helper.selectAudioInput("microphone-bottom");
        _audioSelected = 'earpiece';
        break;
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

  bool attendedRefer(String target, {String? callId}) {
    if (callId == null) {
      if (!callCurrentIsEmpty()) {
        Call? call = _sipuaHelper.findCall(_callIdCurrent!);
        inspect(call);
        if (call != null) {
          Map<String, dynamic> options = _sipuaHelper.buildCallOptions(true);
          Map<String, dynamic> attendedTransferReplace = {
            "replaces": {
              "call_id": call.id,
              "to_tag": call.session.to_tag ?? "",
              "from_tag": call.session.from_tag ?? "",
            }
          };
          options.addAll(attendedTransferReplace);

          inspect(options);
          log(options.toString(), name: 'options');
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
    if (callId == null) {
      if (!callCurrentIsEmpty()) {
        Call? call = _sipuaHelper.findCall(_callIdCurrent!);
        if (call != null) {
          if (_holdCall) {
            call.unhold();
          } else {
            call.hold();
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
        if (_holdCall) {
          call.unhold();
        } else {
          call.hold();
        }
        return true;
      }
      return false;
    }
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
    bool enableStartCall = true,
  }) {
    thr.throttle(() async {
      _dismissLoading();
      if (!checkIsNumber.hasMatch(phoneNumber)) {
        EasyLoading.showToast(
          'Invalid phone number',
          toastPosition: EasyLoadingToastPosition.center,
        );
        return;
      }
      _outPhone = phoneNumber;
      _nameCaller = nameCaller;

      //! CALL WAITING
      if (Platform.isIOS && enableStartCall) {
        var newUUID = const Uuid().v4();
        CallKitParams params = CallKitParams(
          id: newUUID,
          nameCaller: nameCaller.isNotEmpty ? nameCaller : phoneNumber,
          handle: phoneNumber,
          type: 0,
          ios: IOSParams(handleType: 'generic'),
        );
        await FlutterCallkitIncoming.startCall(params);
      }

      final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
      final PitelClient pitelClient = PitelClient.getInstance();
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.first == ConnectivityResult.none) {
        _checkConnectivity = [ConnectivityResult.none];
        EasyLoading.showToast(
          'Please check your network',
          toastPosition: EasyLoadingToastPosition.center,
        );
        return;
      }
      if (!listEquals(connectivityResult, _checkConnectivity)) {
        _checkConnectivity = connectivityResult;
        PitelLoading.instance.show();
        handleRegisterCall();
        return;
      }

      if (connectivityResult.first == ConnectivityResult.wifi) {
        try {
          final wifiIP = await NetworkInfo().getWifiIP();
          if (wifiIP != _wifiIP) {
            _wifiIP = wifiIP;
            PitelLoading.instance.show();
            handleRegisterCall();
            return;
          }
        } catch (error) {
          PitelLoading.instance.show();
          handleRegisterCall();
          return;
        }
      }

      final isRegistered = pitelCall.getRegisterState();
      if (isRegistered == 'Registered') {
        //! CALL WAITING
        PitelLoading.instance.hide();
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
        handleRegisterCall();
      }
    });
  }

  void _dismissLoading() async {
    await Future.delayed(const Duration(seconds: 10));
    PitelLoading.instance.hide();
  }
}
