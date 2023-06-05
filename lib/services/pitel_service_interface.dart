import 'package:plugin_pitel/sip/src/sip_ua_helper.dart';

import 'models/pn_push_params.dart';
import 'sip_info_data.dart';

abstract class PitelService {
  Future<void> setExtensionInfo(
    SipInfoData sipInfoData,
    PnPushParams pnPushParams,
  );
  Future<PitelSettings> registerSipWithoutFCM(
    PnPushParams pnPushParams,
  );
}
