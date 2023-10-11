import 'package:plugin_pitel/sip/sip_ua.dart';
import 'package:plugin_pitel/sip/src/event_manager/events.dart';
import 'package:plugin_pitel/sip/src/message.dart';

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
      case RegistrationStateEnum.none:
        return PitelRegistrationStateEnum.none;
      case RegistrationStateEnum.registered:
        return PitelRegistrationStateEnum.registered;
      case RegistrationStateEnum.registrationFailed:
        return PitelRegistrationStateEnum.registrationFailed;
      case RegistrationStateEnum.unregistered:
        return PitelRegistrationStateEnum.unregistered;
    }
  }
}

class PitelSIPMessageRequest extends SIPMessageRequest {
  PitelSIPMessageRequest(Message message, String originator, dynamic request)
      : super(message, originator, request);
}
