import 'constants.dart';
import 'data.dart';
import 'digest_authentication.dart';
import 'event_manager/event_manager.dart';
import 'event_manager/internal_events.dart';
import 'logger.dart';
import 'sip_message.dart';
import 'transactions/ack_client.dart';
import 'transactions/invite_client.dart';
import 'transactions/non_invite_client.dart';
import 'transactions/transaction_base.dart';
import 'ua.dart' as uac;
import 'ua.dart';

// Default event handlers.

class RequestSender {
  RequestSender(
      PitelUA ua, OutgoingRequest request, EventManager eventHandlers) {
    _ua = ua;
    _eventHandlers = eventHandlers;
    _method = request.method;
    _request = request;
    _auth = null;
    _challenged = false;
    _staled = false;

    // If ua is in closing process or even closed just allow sending Bye and ACK.
    if (ua.status == uac.C.STATUS_USER_CLOSED &&
        (_method != SipMethod.BYE || _method != SipMethod.ACK)) {
      _eventHandlers.emit(EventOnTransportError());
    }
  }
  late PitelUA _ua;
  late EventManager _eventHandlers;
  SipMethod? _method;
  OutgoingRequest? _request;
  DigestAuthentication? _auth;
  late bool _challenged;
  late bool _staled;
  late TransactionBase clientTransaction;

  /// Create the client transaction and send the message.
  void send() {
    EventManager handlers = EventManager();
    handlers.on(EventOnRequestTimeout(), (EventOnRequestTimeout event) {
      _eventHandlers.emit(event);
    });
    handlers.on(EventOnTransportError(), (EventOnTransportError event) {
      _eventHandlers.emit(event);
    });
    handlers.on(EventOnAuthenticated(), (EventOnAuthenticated event) {
      _eventHandlers.emit(event);
    });
    handlers.on(EventOnReceiveResponse(), (EventOnReceiveResponse event) {
      _receiveResponse(event.response!);
    });

    switch (_method) {
      case SipMethod.INVITE:
        clientTransaction =
            InviteClientTransaction(_ua, _ua.transport!, _request!, handlers);
        break;
      case SipMethod.ACK:
        clientTransaction =
            AckClientTransaction(_ua, _ua.transport!, _request!, handlers);
        break;
      default:
        clientTransaction = NonInviteClientTransaction(
            _ua, _ua.transport!, _request!, handlers);
    }

    clientTransaction.send();
  }

  /// Called from client transaction when receiving a correct response to the request.
  /// Authenticate request if needed or pass the response back to the applicant.
  void _receiveResponse(IncomingResponse response) {
    ParsedData? challenge;
    String authorizationHeaderName;
    int? statusCode = response.status_code;

    /*
    * Authentication
    * Authenticate once. _challenged_ flag used to avoid infinite authentications.
    */
    if ((statusCode == 401 || statusCode == 407) &&
        (_ua.configuration!.password != null ||
            _ua.configuration!.ha1 != null)) {
      // Get and parse the appropriate WWW-Authenticate or Proxy-Authenticate header.
      if (response.status_code == 401) {
        challenge = response.parseHeader('www-authenticate');
        authorizationHeaderName = 'authorization';
      } else {
        challenge = response.parseHeader('proxy-authenticate');
        authorizationHeaderName = 'proxy-authorization';
      }

      // Verify it seems a valid challenge.
      if (challenge == null) {
        logger.debug(
            '${response.status_code} with wrong or missing challenge, cannot authenticate');
        _eventHandlers.emit(EventOnReceiveResponse(response: response));

        return;
      }

      if (!_challenged || (!_staled && challenge.stale == true)) {
        _auth ??= DigestAuthentication(Credentials.fromMap(<String, dynamic>{
          'username': _ua.configuration!.authorizationUser,
          'password': _ua.configuration!.password,
          'realm': _ua.configuration!.realm,
          'ha1': _ua.configuration!.ha1
        }));

        // Verify that the challenge is really valid.
        if (!_auth!.authenticate(
            _request!.method!,
            Challenge.fromMap(<String, dynamic>{
              'algorithm': challenge.algorithm,
              'realm': challenge.realm,
              'nonce': challenge.nonce,
              'opaque': challenge.opaque,
              'stale': challenge.stale,
              'qop': challenge.qop,
            }),
            _request!.ruri)) {
          _eventHandlers.emit(EventOnReceiveResponse(response: response));
          return;
        }
        _challenged = true;

        // Update ha1 and realm in the UA.
        _ua.set('realm', _auth!.get('realm'));
        _ua.set('ha1', _auth!.get('ha1'));

        if (challenge.stale != null) {
          _staled = true;
        }

        _request = _request!.clone();
        _request!.cseq = _request!.cseq! + 1;
        _request!.setHeader(
            'cseq', '${_request!.cseq} ${SipMethodHelper.getName(_method)}');
        _request!.setHeader(authorizationHeaderName, _auth.toString());

        _eventHandlers.emit(EventOnAuthenticated(request: _request));
        send();
      } else {
        _eventHandlers.emit(EventOnReceiveResponse(response: response));
      }
    } else {
      _eventHandlers.emit(EventOnReceiveResponse(response: response));
    }
  }
}
