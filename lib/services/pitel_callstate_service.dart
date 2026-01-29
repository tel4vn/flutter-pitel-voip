import 'package:flutter/foundation.dart';

// Dùng enum state của bạn
import 'package:flutter_pitel_voip/sip/src/sip_ua_helper.dart';

class PitelCallStateService with ChangeNotifier {
  // 1. Tạo instance Singleton
  static final PitelCallStateService _instance =
      PitelCallStateService._internal();
  factory PitelCallStateService() => _instance;
  PitelCallStateService._internal();

  // 2. Khai báo biến state
  PitelCallStateEnum _state = PitelCallStateEnum.NONE;
  // 3. Getter để lấy state hiện tại
  PitelCallStateEnum get state => _state;
  DateTime? _callStartTime;
  DateTime? get callStartTime => _callStartTime;

  void updateState(PitelCallStateEnum newState) {
    if (_state != newState) {
      _state = newState;
      if (newState == PitelCallStateEnum.CONFIRMED && _callStartTime == null) {
        _callStartTime = DateTime.now();
      }

      if (newState == PitelCallStateEnum.ENDED ||
          newState == PitelCallStateEnum.FAILED ||
          newState == PitelCallStateEnum.NONE) {
        _callStartTime = null;
      }
      notifyListeners();
    }
  }
}
