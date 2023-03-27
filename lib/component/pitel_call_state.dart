import 'package:plugin_pitel/sip/sip_ua.dart';
import 'package:plugin_pitel/sip/src/event_manager/events.dart';
import 'package:plugin_pitel/sip/src/message.dart';

// class PitelCallState {
//   late bool video;
//   late bool audio;
//   late PitelCallStateEnum state;
//   late String originator;
//
//   PitelCallState(PitelCallState callState) {
//     video = callState.video ?? false;
//     audio = callState.audio ?? false;
//     state = callState.state.convertCallState(callState)!;
//     originator = callState.originator ?? "";
//   }
// }

// enum PitelCallStateEnum {
//   NONE,
//   STREAM,
//   UNMUTED,
//   MUTED,
//   CONNECTING,
//   PROGRESS,
//   FAILED,
//   ENDED,
//   ACCEPTED,
//   CONFIRMED,
//   REFER,
//   HOLD,
//   UNHOLD,
//   CALL_INITIATION
// }

// extension PitelCallStateEnumExtension on CallStateEnum {
//   PitelCallStateEnum? convertCallState(PitelCallState callState) {
//     switch (callState.state) {
//       case CallStateEnum.NONE:
//         return PitelCallStateEnum.NONE;
//       case CallStateEnum.STREAM:
//         return PitelCallStateEnum.STREAM;
//       case CallStateEnum.UNMUTED:
//         return PitelCallStateEnum.UNMUTED;
//       case CallStateEnum.MUTED:
//         return PitelCallStateEnum.MUTED;
//       case CallStateEnum.CONNECTING:
//         return PitelCallStateEnum.CONNECTING;
//       case CallStateEnum.PROGRESS:
//         return PitelCallStateEnum.PROGRESS;
//       case CallStateEnum.FAILED:
//         return PitelCallStateEnum.FAILED;
//       case CallStateEnum.ENDED:
//         return PitelCallStateEnum.ENDED;
//       case CallStateEnum.ACCEPTED:
//         return PitelCallStateEnum.ACCEPTED;
//       case CallStateEnum.CONFIRMED:
//         return PitelCallStateEnum.CONFIRMED;
//       case CallStateEnum.REFER:
//         return PitelCallStateEnum.REFER;
//       case CallStateEnum.HOLD:
//         return PitelCallStateEnum.HOLD;
//       case CallStateEnum.UNHOLD:
//         return PitelCallStateEnum.UNHOLD;
//       case CallStateEnum.CALL_INITIATION:
//         return PitelCallStateEnum.CALL_INITIATION;
//     }
//   }
// }

class PitelRegistrationState {
  late PitelRegistrationStateEnum state;
  late ErrorCause cause;

  PitelRegistrationState(RegistrationState registerState) {
    state = registerState.state!.convertToPitelRegistrationStateEnum();
    cause = registerState.cause!;
  }
}

enum PitelRegistrationStateEnum {
  NONE,
  REGISTRATION_FAILED,
  REGISTERED,
  UNREGISTERED,
}

extension RegistrationStateEnumExt on RegistrationStateEnum {
  PitelRegistrationStateEnum convertToPitelRegistrationStateEnum() {
    switch (this) {
      case RegistrationStateEnum.NONE:
        return PitelRegistrationStateEnum.NONE;
      case RegistrationStateEnum.REGISTERED:
        return PitelRegistrationStateEnum.REGISTERED;
      case RegistrationStateEnum.REGISTRATION_FAILED:
        return PitelRegistrationStateEnum.REGISTRATION_FAILED;
      case RegistrationStateEnum.UNREGISTERED:
        return PitelRegistrationStateEnum.UNREGISTERED;
    }
  }
}

class PitelSIPMessageRequest extends SIPMessageRequest {
  PitelSIPMessageRequest(Message message, String originator, dynamic request)
      : super(message, originator, request);
}
