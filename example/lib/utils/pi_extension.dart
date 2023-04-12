import 'package:plugin_pitel/component/pitel_call_state.dart';

extension PitelRegistrationStateEnumStringEx on PitelRegistrationStateEnum {
  String convertToString() {
    switch (this) {
      case PitelRegistrationStateEnum.NONE:
        return "None";
      case PitelRegistrationStateEnum.REGISTRATION_FAILED:
        return "Registration Failed";
      case PitelRegistrationStateEnum.REGISTERED:
        return "Registered";
      case PitelRegistrationStateEnum.UNREGISTERED:
        return "Unregistered";
    }
  }
}