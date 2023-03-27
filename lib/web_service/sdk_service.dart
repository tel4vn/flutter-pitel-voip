import 'package:plugin_pitel/config/pitel_config.dart';
import 'package:plugin_pitel/web_service/http_service.dart';

class SDKService extends HttpService {
  static SDKService? _instance;
  static SDKService getInstance() {
    if (_instance == null) {
      _instance = SDKService();
    }
    return _instance!;
  }

  @override
  String get domain => PitelConfigure.domainSDK;
}
