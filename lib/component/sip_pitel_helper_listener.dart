import 'package:flutter_pitel_voip/component/pitel_call_state.dart';
import 'package:flutter_pitel_voip/sip/sip_ua.dart';

abstract class SipPitelHelperListener {
  void onCallInitiated(String callId);
  void onCallReceived(String callId);
  void callStateChanged(String callId, PitelCallState state);

  void transportStateChanged(PitelTransportState state);
  void registrationStateChanged(PitelRegistrationState state);
  //For SIP messaga coming
  void onNewMessage(PitelSIPMessageRequest msg);
}
