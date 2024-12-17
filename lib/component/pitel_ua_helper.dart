import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:plugin_pitel/sip/sip_ua.dart';
import 'package:plugin_pitel/sip/src/config.dart';
import 'package:plugin_pitel/sip/src/constants.dart' as DartSIP_C;
import 'package:plugin_pitel/sip/src/event_manager/event_manager.dart';
import 'package:plugin_pitel/sip/src/logger.dart';
import 'package:plugin_pitel/sip/src/message.dart';
import 'package:plugin_pitel/sip/src/rtc_session.dart';
import 'package:plugin_pitel/sip/src/stack_trace_nj.dart';
import 'package:plugin_pitel/sip/src/transports/websocket_interface.dart';
import 'package:plugin_pitel/sip/src/ua.dart';

class PitelUAHelper extends EventManager {
  PitelUA? _ua;
  PitelSipSettings? _settings;
  late PitelSettings _uaSettings;
  final Map<String?, Call> _calls = <String?, Call>{};

  RegistrationState _registerState =
      RegistrationState(state: RegistrationStateEnum.NONE);

  set loggingLevel(Level loggingLevel) => Log.loggingLevel = loggingLevel;

  bool get registered {
    if (_ua != null) {
      return _ua!.isRegistered() ?? false;
    }
    return false;
  }

  bool get connected {
    if (_ua != null) {
      return _ua!.isConnected();
    }
    return false;
  }

  RegistrationState get registerState => _registerState;

  void stop() async {
    if (_ua != null) {
      _ua!.stop();
    } else {
      Log.w('ERROR: stop called but not started, call start first.');
    }
  }

  void register() {
    assert(_ua != null,
        'register called but not started, you must call start first.');
    _ua!.register();
  }

  void unregister([bool all = true]) {
    if (_ua != null) {
      assert(registered, 'ERROR: you must call register first.');
      _ua!.unregister(all: all);
    } else {
      Log.e('ERROR: unregister called, you must call start first.');
    }
  }

  Future<bool> call(String target,
      {bool voiceonly = false,
      MediaStream? mediaStream,
      List<String>? headers}) async {
    if (_ua != null && _ua!.isConnected()) {
      Map<String, dynamic> options = buildCallOptions(voiceonly);
      if (mediaStream != null) {
        options['mediaStream'] = mediaStream;
      }
      List<dynamic> extHeaders = options['extraHeaders'] as List<dynamic>;
      extHeaders.addAll(headers ?? <String>[]);
      _ua!.call(target, options);
      return true;
    } else {
      logger.error(
          'Not connected, you will need to register.', null, StackTraceNJ());
    }
    return false;
  }

  Call? findCall(String id) {
    return _calls[id];
  }

  void start(PitelSettings uaSettings) async {
    //! WARNING
    if (_ua != null) {
      logger.warn(
          'UA instance already exist!, stopping UA and creating a one...');
      _ua!.stop();
    }

    _uaSettings = uaSettings;

    _settings = PitelSipSettings();
    WebSocketInterface socket = WebSocketInterface(
        uaSettings.webSocketUrl, uaSettings.webSocketSettings);
    _settings!.sockets = <WebSocketInterface>[socket];
    _settings!.uri = uaSettings.uri;
    _settings!.contact_uri = uaSettings.contactUri;
    _settings!.password = uaSettings.password;
    //! sip_domain
    _settings!.sip_domain = uaSettings.sipDomain;
    //! outbound_server
    _settings!.outbound_server = uaSettings.outboundServer;
    _settings!.ha1 = uaSettings.ha1;
    _settings!.display_name = uaSettings.displayName;
    _settings!.authorization_user = uaSettings.authorizationUser;
    _settings!.user_agent = uaSettings.userAgent ?? DartSIP_C.USER_AGENT;
    _settings!.register = uaSettings.register;
    _settings!.register_expires = uaSettings.register_expires;
    _settings!.register_extra_contact_uri_params =
        uaSettings.registerParams.extraContactUriParams;
    _settings!.dtmf_mode = uaSettings.dtmfMode;
    _settings!.session_timers = uaSettings.sessionTimers;
    _settings!.ice_gathering_timeout = uaSettings.iceGatheringTimeout;

    try {
      _ua = PitelUA(_settings);
      List<String> extraHeaders = [];
      uaSettings.webSocketSettings.extraHeaders.forEach((key, value) {
        extraHeaders.add('$key: $value');
      });
      _ua!.registrator()?.setExtraHeaders(extraHeaders);
      _ua!.on(EventSocketConnecting(), (EventSocketConnecting event) {
        logger.debug('connecting => ' + event.toString());
        _notifyTransportStateListeners(
            PitelTransportState(TransportStateEnum.CONNECTING));
      });

      _ua!.on(EventSocketConnected(), (EventSocketConnected event) {
        logger.debug('connected => ' + event.toString());
        _notifyTransportStateListeners(
            PitelTransportState(TransportStateEnum.CONNECTED));
      });

      _ua!.on(EventSocketDisconnected(), (EventSocketDisconnected event) {
        logger.debug('disconnected => ' + (event.cause.toString()));
        _notifyTransportStateListeners(PitelTransportState(
            TransportStateEnum.DISCONNECTED,
            cause: event.cause));
      });

      _ua!.on(EventRegistered(), (EventRegistered event) {
        logger.debug('registered => ' + event.cause.toString());
        _registerState = RegistrationState(
            state: RegistrationStateEnum.REGISTERED, cause: event.cause);
        _notifyRegsistrationStateListeners(_registerState);
      });

      _ua!.on(EventUnregister(), (EventUnregister event) {
        logger.debug('unregistered => ' + event.cause.toString());
        _registerState = RegistrationState(
            state: RegistrationStateEnum.UNREGISTERED, cause: event.cause);
        _notifyRegsistrationStateListeners(_registerState);
      });

      _ua!.on(EventRegistrationFailed(), (EventRegistrationFailed event) {
        logger.debug('registrationFailed => ' + (event.cause.toString()));
        _registerState = RegistrationState(
            state: RegistrationStateEnum.REGISTRATION_FAILED,
            cause: event.cause);
        _notifyRegsistrationStateListeners(_registerState);
      });

      _ua!.on(EventNewRTCSession(), (EventNewRTCSession event) {
        logger.debug('newRTCSession => ' + event.toString());
        RTCSession session = event.session!;
        if (session.direction == 'incoming') {
          // Set event handlers.
          session.addAllEventHandlers(
              buildCallOptions()['eventHandlers'] as EventManager);
        }
        _calls[event.id] =
            Call(event.id, session, PitelCallStateEnum.CALL_INITIATION);
        _notifyCallStateListeners(
            event, PitelCallState(PitelCallStateEnum.CALL_INITIATION));
      });

      _ua!.on(EventNewMessage(), (EventNewMessage event) {
        logger.debug('newMessage => ' + event.toString());
        //Only notify incoming message to listener
        if (event.message!.direction == 'incoming') {
          SIPMessageRequest message =
              SIPMessageRequest(event.message, event.originator, event.request);
          _notifyNewMessageListeners(message);
        }
      });

      _ua!.start();
    } catch (event, s) {
      logger.error(event.toString(), null, s);
    }
  }

  /// Build the call options.
  /// You may override this method in a custom SIPUAHelper class in order to
  /// modify the options to your needs.
  Map<String, dynamic> buildCallOptions([bool voiceonly = false]) =>
      _options(voiceonly);

  Map<String, dynamic> _options([bool voiceonly = false]) {
    // Register callbacks to desired call events
    EventManager handlers = EventManager();
    handlers.on(EventCallConnecting(), (EventCallConnecting event) {
      logger.debug('call connecting');
      _notifyCallStateListeners(
          event, PitelCallState(PitelCallStateEnum.CONNECTING));
    });
    handlers.on(EventCallProgress(), (EventCallProgress event) {
      logger.debug('call is in progress');
      _notifyCallStateListeners(
          event,
          PitelCallState(PitelCallStateEnum.PROGRESS,
              originator: event.originator));
    });
    handlers.on(EventCallFailed(), (EventCallFailed event) {
      logger.debug('call failed with cause: ' + (event.cause.toString()));
      _notifyCallStateListeners(
          event,
          PitelCallState(PitelCallStateEnum.FAILED,
              originator: event.originator, cause: event.cause));
      _calls.remove(event.id);
    });
    handlers.on(EventCallEnded(), (EventCallEnded event) {
      logger.debug('call ended with cause: ' + (event.cause.toString()));
      _notifyCallStateListeners(
          event,
          PitelCallState(PitelCallStateEnum.ENDED,
              originator: event.originator, cause: event.cause));
      _calls.remove(event.id);
    });
    handlers.on(EventCallAccepted(), (EventCallAccepted event) {
      logger.debug('call accepted');
      _notifyCallStateListeners(
          event, PitelCallState(PitelCallStateEnum.ACCEPTED));
    });
    handlers.on(EventCallConfirmed(), (EventCallConfirmed event) {
      logger.debug('call confirmed');
      _notifyCallStateListeners(
          event, PitelCallState(PitelCallStateEnum.CONFIRMED));
    });
    handlers.on(EventCallHold(), (EventCallHold event) {
      logger.debug('call hold');
      _notifyCallStateListeners(
          event,
          PitelCallState(PitelCallStateEnum.HOLD,
              originator: event.originator));
    });
    handlers.on(EventCallUnhold(), (EventCallUnhold event) {
      logger.debug('call unhold');
      _notifyCallStateListeners(
          event,
          PitelCallState(PitelCallStateEnum.UNHOLD,
              originator: event.originator));
    });
    handlers.on(EventCallMuted(), (EventCallMuted event) {
      logger.debug('call muted');
      _notifyCallStateListeners(
          event,
          PitelCallState(PitelCallStateEnum.MUTED,
              audio: event.audio ?? false, video: event.video ?? false));
    });
    handlers.on(EventCallUnmuted(), (EventCallUnmuted event) {
      logger.debug('call unmuted');
      _notifyCallStateListeners(
          event,
          PitelCallState(PitelCallStateEnum.UNMUTED,
              audio: event.audio ?? false, video: event.video ?? false));
    });
    handlers.on(EventStream(), (EventStream event) async {
      // Wating for callscreen ready.
      Timer(Duration(milliseconds: 100), () {
        _notifyCallStateListeners(
            event,
            PitelCallState(PitelCallStateEnum.STREAM,
                stream: event.stream, originator: event.originator));
      });
    });
    handlers.on(EventCallRefer(), (EventCallRefer refer) async {
      logger.debug('Refer received, Transfer current call to => ${refer.aor}');
      _notifyCallStateListeners(
          refer, PitelCallState(PitelCallStateEnum.REFER, refer: refer));
      //Always accept.
      refer.accept((RTCSession session) {
        logger.debug('session initialized.');
      }, buildCallOptions(true));
    });

    Map<String, dynamic> _defaultOptions = <String, dynamic>{
      'eventHandlers': handlers,
      'extraHeaders': <dynamic>[],
      'pcConfig': <String, dynamic>{
        'sdpSemantics': 'unified-plan',
        'iceServers': _uaSettings.iceServers
      },
      'mediaConstraints': <String, dynamic>{
        'audio': {
          'echoCancellation': true,
          'googEchoCancellation': true,
          'googEchoCancellation2': true,
          'googDAEchoCancellation': true,
          'googNoiseSuppression': true,
          'googNoiseSuppression2': true,
          'googHighpassFilter': true,
        },
        'video': voiceonly
            ? false
            : <String, dynamic>{
                'mandatory': <String, dynamic>{
                  'minWidth': '640',
                  'minHeight': '480',
                  'minFrameRate': '30',
                },
                'facingMode': 'user',
                'optional': <dynamic>[],
              }
      },
      'rtcOfferConstraints': <String, dynamic>{
        'mandatory': <String, dynamic>{
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': !voiceonly,
        },
        'optional': <dynamic>[],
      },
      'rtcAnswerConstraints': <String, dynamic>{
        'mandatory': <String, dynamic>{
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': true,
        },
        'optional': <dynamic>[],
      },
      'rtcConstraints': <String, dynamic>{
        'mandatory': <dynamic, dynamic>{},
        'optional': <Map<String, dynamic>>[
          <String, dynamic>{'DtlsSrtpKeyAgreement': true},
        ],
      },
      'sessionTimersExpires': 120
    };
    return _defaultOptions;
  }

  Message sendMessage(String target, String body,
      [Map<String, dynamic>? options]) {
    return _ua!.sendMessage(target, body, options);
  }

  void terminateSessions(Map<String, dynamic> options) {
    _ua!.terminateSessions(options as Map<String, Object>);
  }

  final Set<SipUaHelperListener> _sipUaHelperListeners =
      <SipUaHelperListener>{};

  void addSipUaHelperListener(SipUaHelperListener listener) {
    _sipUaHelperListeners.add(listener);
  }

  void removeSipUaHelperListener(SipUaHelperListener listener) {
    _sipUaHelperListeners.remove(listener);
  }

  void _notifyTransportStateListeners(PitelTransportState state) {
    // Copy to prevent concurrent modification exception
    List<SipUaHelperListener> listeners = _sipUaHelperListeners.toList();
    for (SipUaHelperListener listener in listeners) {
      listener.transportStateChanged(state);
    }
  }

  void _notifyRegsistrationStateListeners(RegistrationState state) {
    // Copy to prevent concurrent modification exception
    List<SipUaHelperListener> listeners = _sipUaHelperListeners.toList();
    for (SipUaHelperListener listener in listeners) {
      listener.registrationStateChanged(state);
    }
  }

  void _notifyCallStateListeners(CallEvent event, PitelCallState state) {
    Call? call = _calls[event.id];
    if (call == null) {
      logger.e('Call ${event.id} not found!');
      return;
    }
    call.state = state.state;
    for (var listener in _sipUaHelperListeners) {
      listener.callStateChanged(call, state);
    }
  }

  void _notifyNewMessageListeners(SIPMessageRequest msg) {
    for (var listener in _sipUaHelperListeners) {
      listener.onNewMessage(msg);
    }
  }
}
