import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:plugin_pitel/component/pitel_call_state.dart';
import 'package:plugin_pitel/component/pitel_rtc_video_renderer.dart';
import 'package:plugin_pitel/component/pitel_ua_helper.dart';
import 'package:plugin_pitel/component/sip_pitel_helper_listener.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_log.dart';
import 'package:plugin_pitel/sip/sip_ua.dart';

import 'pitel_client.dart';

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
  String? get direction => _callIdCurrent != null
      ? _sipuaHelper.findCall(_callIdCurrent!)?.direction
      : "";
  bool get videoIsOff => _videoIsOff;
  bool get audioMuted => _audioMuted;
  String? get holdOriginator => _holdOriginator;
  bool get isConnected => _sipuaHelper.connected;
  bool get isHaveCall => _callIdCurrent?.isNotEmpty ?? false;
  String? _callIdCurrent;
  bool isBusy = false;

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
        print('================_sipPitelHelperListener================');
        print(_sipPitelHelperListener);
        print('==================================');
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
                print(
                    '================register===========CALL_INITIATION=====');
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
      Helper.setSpeakerphoneOn(false);
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

  void enableSpeakerphone(bool enable) {
    Helper.setSpeakerphoneOn(enable);
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
    UnimplementedError('not implment yet');
    return false;
    // if (callId == null) {
    //   if (!callCurrentIsEmpty()) {
    //     if (_calls[_callIdCurrent] != null) {
    //       _calls[_callIdCurrent]!.refer(target);
    //       return true;
    //     }
    //     return false;
    //   } else {
    //     _logger.error('You have to set callIdCurrent or pass param callId');
    //     return false;
    //   }
    // } else {
    //   if (_calls[callId] != null) {
    //     _calls[callId]!.refer(target);
    //     return true;
    //   }
    //   return false;
    // }
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

  Future<String> outgoingCall(
    String phoneNumber,
    VoidCallback onRegister,
  ) async {
    try {
      final isRegistered = getRegisterState();
      if (isRegistered == 'Registered') {
        final res = await _handleCall(phoneNumber);
        return res;
      } else {
        onRegister();
        await Future.delayed(const Duration(milliseconds: 1000));
        final res = await _handleCall(phoneNumber);
        return res;
      }
    } catch (error) {
      return error.toString();
    }
  }

  Future<String> _handleCall(String phoneNumber) async {
    final PitelClient pitelClient = PitelClient.getInstance();
    return pitelClient
        .call(phoneNumber, true)
        .then((value) => value.fold((succ) => "OK", (err) => err.toString()));
  }
}
