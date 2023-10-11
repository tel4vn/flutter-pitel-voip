import 'package:plugin_pitel/component/pitel_call_state.dart';
import 'package:plugin_pitel/sip/sip_ua.dart';

abstract class SipPitelHelperListener {
  void onCallInitiated(String callId);
  void onCallReceived(String callId);
  void callStateChanged(String callId, PitelCallState state);

  void transportStateChanged(PitelTransportState state);
  void registrationStateChanged(PitelRegistrationState state);
  //For SIP messaga coming
  void onNewMessage(PitelSIPMessageRequest msg);
}
