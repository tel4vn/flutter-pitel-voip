import 'package:plugin_pitel/component/pitel_call_state.dart';
import 'package:plugin_pitel/component/sip_pitel_helper_listener.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_client.dart';
import 'package:plugin_pitel/sip/src/sip_ua_helper.dart';

import 'pitel_service_interface.dart';
import 'sip_info_data.dart';

class PitelServiceImpl implements PitelService, SipPitelHelperListener {
  final pitelClient = PitelClient.getInstance();

  SipInfoData? sipInfoData;

  PitelServiceImpl() {
    pitelClient.pitelCall.addListener(this);
  }

  @override
  bool registerSipWithoutFCM() {
    return pitelClient.registerSipWithoutFCM();
  }

  @override
  Future<void> setExtensionInfo(SipInfoData sipInfoData) async {
    this.sipInfoData = sipInfoData;
    pitelClient.setExtensionInfo(sipInfoData.toGetExtensionResponse());
    pitelClient.registerSipWithoutFCM();
  }

  @override
  void callStateChanged(String callId, PitelCallState state) {
    print('❌ ❌ ❌ callStateChanged ${callId} state ${state.state.toString()}');
  }

  @override
  void onCallInitiated(String callId) {
    print('❌ ❌ ❌ onCallInitiated ${callId}');
  }

  @override
  void onCallReceived(String callId) {
    print('❌ ❌ ❌ onCallReceived ${callId}');
  }

  @override
  void onNewMessage(PitelSIPMessageRequest msg) {
    print('❌ ❌ ❌ transportStateChanged ${msg.message}');
  }

  @override
  void registrationStateChanged(PitelRegistrationState state) {
    print('❌ ❌ ❌ registrationStateChanged ${state.state.toString()}');
  }

  @override
  void transportStateChanged(PitelTransportState state) {
    print('❌ ❌ ❌ transportStateChanged ${state.state.toString()}');
  }
}
