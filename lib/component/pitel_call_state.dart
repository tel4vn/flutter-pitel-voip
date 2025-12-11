import 'package:flutter_pitel_voip/sip/sip_ua.dart';
import 'package:flutter_pitel_voip/sip/src/event_manager/events.dart';
import 'package:flutter_pitel_voip/sip/src/message.dart';

class PitelRegistrationState {
  late PitelRegistrationStateEnum state;
  late ErrorCause cause;

  PitelRegistrationState(RegistrationState registerState) {
    state = registerState.state!.convertToPitelRegistrationStateEnum();
    cause = registerState.cause!;
  }
}

enum PitelRegistrationStateEnum {
  none,
  registrationFailed,
  registered,
  unregistered,
}

extension RegistrationStateEnumExt on RegistrationStateEnum {
  PitelRegistrationStateEnum convertToPitelRegistrationStateEnum() {
    switch (this) {
      case RegistrationStateEnum.NONE:
        return PitelRegistrationStateEnum.none;
      case RegistrationStateEnum.REGISTRATION_FAILED:
        return PitelRegistrationStateEnum.registrationFailed;
      case RegistrationStateEnum.REGISTERED:
        return PitelRegistrationStateEnum.registered;
      case RegistrationStateEnum.UNREGISTERED:
        return PitelRegistrationStateEnum.unregistered;
    }
  }
}

class PitelSIPMessageRequest extends SIPMessageRequest {
  PitelSIPMessageRequest(
      Message message, Originator originator, dynamic request)
      : super(message, originator, request);
}
