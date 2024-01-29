import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:plugin_pitel/sip/src/rtc_session/refer_subscriber.dart';

import 'event_manager/event_manager.dart';
import 'message.dart';
import 'rtc_session.dart';

enum PitelCallStateEnum {
  NONE,
  STREAM,
  UNMUTED,
  MUTED,
  CONNECTING,
  PROGRESS,
  FAILED,
  ENDED,
  ACCEPTED,
  CONFIRMED,
  REFER,
  HOLD,
  UNHOLD,
  CALL_INITIATION
}

class Call {
  Call(this._id, this._session, this.state);
  final String? _id;
  final RTCSession _session;

  String? get id => _id;
  RTCPeerConnection? get peerConnection => _session.connection;
  RTCSession get session => _session;
  PitelCallStateEnum state;

  void answer(Map<String, dynamic> options, {MediaStream? mediaStream = null}) {
    assert(_session != null, 'ERROR(answer): rtc session is invalid!');
    if (mediaStream != null) {
      options['mediaStream'] = mediaStream;
    }
    _session.answer(options);
  }

  void refer(String target, Map<String, dynamic>? options) {
    assert(_session != null, 'ERROR(refer): rtc session is invalid!');
    ReferSubscriber refer = _session.refer(target, options)!;
    refer.on(EventReferTrying(), (EventReferTrying data) {});
    refer.on(EventReferProgress(), (EventReferProgress data) {});
    refer.on(EventReferAccepted(), (EventReferAccepted data) {
      _session.terminate();
    });
    refer.on(EventReferFailed(), (EventReferFailed data) {});
  }

  void hangup([Map<String, dynamic>? options]) {
    assert(_session != null, 'ERROR(hangup): rtc session is invalid!');
    _session.terminate(options);
  }

  void hold() {
    assert(_session != null, 'ERROR(hold): rtc session is invalid!');
    _session.hold();
  }

  void unhold() {
    assert(_session != null, 'ERROR(unhold): rtc session is invalid!');
    _session.unhold();
  }

  void mute([bool audio = true, bool video = true]) {
    assert(_session != null, 'ERROR(mute): rtc session is invalid!');
    _session.mute(audio, video);
  }

  void unmute([bool audio = true, bool video = true]) {
    assert(_session != null, 'ERROR(umute): rtc session is invalid!');
    _session.unmute(audio, video);
  }

  void renegotiate(Map<String, dynamic> options) {
    assert(_session != null, 'ERROR(renegotiate): rtc session is invalid!');
    _session.renegotiate(options);
  }

  void sendDTMF(String tones, [Map<String, dynamic>? options]) {
    assert(_session != null, 'ERROR(sendDTMF): rtc session is invalid!');
    _session.sendDTMF(tones, options);
  }

  void sendInfo(String contentType, String body, Map<String, dynamic> options) {
    assert(_session != null, 'ERROR(sendInfo): rtc session is invalid');
    _session.sendInfo(contentType, body, options);
  }

  String? get remote_display_name {
    assert(_session != null,
        'ERROR(get remote_identity): rtc session is invalid!');
    if (_session.remote_identity != null &&
        _session.remote_identity!.display_name != null) {
      return _session.remote_identity!.display_name;
    }
    return '';
  }

  String? get remote_identity {
    assert(_session != null,
        'ERROR(get remote_identity): rtc session is invalid!');
    if (_session.remote_identity != null &&
        _session.remote_identity!.uri != null &&
        _session.remote_identity!.uri!.user != null) {
      return _session.remote_identity!.uri!.user;
    }
    return '';
  }

  String? get local_identity {
    assert(
        _session != null, 'ERROR(get local_identity): rtc session is invalid!');
    if (_session.local_identity != null &&
        _session.local_identity!.uri != null &&
        _session.local_identity!.uri!.user != null) {
      return _session.local_identity!.uri!.user;
    }
    return '';
  }

  String get direction {
    assert(_session != null, 'ERROR(get direction): rtc session is invalid!');
    if (_session.direction != null) {
      return _session.direction!.toUpperCase();
    }
    return '';
  }

  bool get remote_has_audio => _peerHasMediaLine('audio');

  bool get remote_has_video => _peerHasMediaLine('video');

  bool _peerHasMediaLine(String media) {
    assert(
        _session != null, 'ERROR(_peerHasMediaLine): rtc session is invalid!');
    if (_session.request == null) {
      return false;
    }

    bool peerHasMediaLine = false;
    Map<String, dynamic> sdp = _session.request.parseSDP();
    // Make sure sdp['media'] is an array, not the case if there is only one media.
    if (sdp['media'] is! List) {
      sdp['media'] = <dynamic>[sdp['media']];
    }
    // Go through all medias in SDP to find offered capabilities to answer with.
    for (Map<String, dynamic> m in sdp['media']) {
      if (media == 'audio' && m['type'] == 'audio') {
        peerHasMediaLine = true;
      }
      if (media == 'video' && m['type'] == 'video') {
        peerHasMediaLine = true;
      }
    }
    return peerHasMediaLine;
  }
}

class PitelCallState {
  PitelCallState(this.state,
      {this.originator,
      this.audio = false,
      this.video = false,
      this.stream,
      this.cause,
      this.refer});
  PitelCallStateEnum state;
  ErrorCause? cause;
  String? originator;
  bool audio;
  bool video;
  MediaStream? stream;
  EventCallRefer? refer;
}

enum RegistrationStateEnum {
  NONE,
  REGISTRATION_FAILED,
  REGISTERED,
  UNREGISTERED,
}

class RegistrationState {
  RegistrationState({this.state, this.cause});
  RegistrationStateEnum? state;
  ErrorCause? cause;
}

enum TransportStateEnum {
  NONE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
}

class PitelTransportState {
  PitelTransportState(this.state, {this.cause});
  TransportStateEnum state;
  ErrorCause? cause;
}

class SIPMessageRequest {
  SIPMessageRequest(this.message, this.originator, this.request);
  dynamic request;
  String? originator;
  Message? message;
}

abstract class SipUaHelperListener {
  void transportStateChanged(PitelTransportState state);
  void registrationStateChanged(RegistrationState state);
  void callStateChanged(Call call, PitelCallState state);
  //For SIP messaga coming
  void onNewMessage(SIPMessageRequest msg);
}

class RegisterParams {
  /// Allow extra headers and Contact Params to be sent on REGISTER
  /// Mainly used for RFC8599 Support
  /// https://github.com/cloudwebrtc/dart-sip-ua/issues/89
  Map<String, dynamic> extraContactUriParams = <String, dynamic>{};
}

class WebSocketSettings {
  /// Add additional HTTP headers, such as:'Origin','Host' or others
  Map<String, dynamic> extraHeaders = <String, dynamic>{};

  /// `User Agent` field for dart http client.
  String? userAgent;

  /// Don‘t check the server certificate
  /// for self-signed certificate.
  bool allowBadCertificate = false;

  /// Custom transport scheme string to use.
  /// Otherwise the used protocol will be used (for example WS for ws://
  /// or WSS for wss://, based on the given web socket URL).
  String? transport_scheme;
}

enum DtmfMode {
  INFO,
  RFC2833,
}

class PitelSettings {
  late String webSocketUrl;
  WebSocketSettings webSocketSettings = WebSocketSettings();

  /// May not need to register if on a static IP, just Auth
  /// Default is true
  bool? register;

  /// Default is 600 secs in config.dart
  int? register_expires;

  /// Mainly used for RFC8599 Push Notification Support
  RegisterParams registerParams = RegisterParams();

  /// `User Agent` field for sip message.
  String? userAgent;
  String? uri;
  String? contactUri;
  String? authorizationUser;
  String? password;
  String? ha1;
  String? displayName;
  //! sip_domain
  String? sipDomain;

  /// DTMF mode, in band (rfc2833) or out of band (sip info)
  DtmfMode dtmfMode = DtmfMode.INFO;

  /// Session Timers
  bool sessionTimers = true;

  /// ICE Gathering Timeout, default 500ms
  int iceGatheringTimeout = 500;

  List<Map<String, String>> iceServers = <Map<String, String>>[
    <String, String>{'url': 'stun:stun.tel4vn.com:3478'},
    <String, String>{'url': 'stun:stun.l.google.com:19302'},

// turn server configuration example.
//    {
//      'url': 'turn:123.45.67.89:3478',
//      'username': 'change_to_real_user',
//      'credential': 'change_to_real_secret'
//    },
  ];
}
