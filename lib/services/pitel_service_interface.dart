import 'sip_info_data.dart';

abstract class PitelService {
  Future<void> setExtensionInfo(SipInfoData sipInfoData);
  bool registerSipWithoutFCM();
}
