import 'sip_info_data.dart';
import 'models/pn_push_params.dart';

abstract class PitelService {
  Future<void> setExtensionInfo(
    SipInfoData sipInfoData,
    PnPushParams pnPushParams,
  );
  void registerSipWithoutFCM(
    PnPushParams pnPushParams,
  );
}
