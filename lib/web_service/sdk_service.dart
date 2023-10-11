import 'package:flutter_pitel_voip/config/pitel_config.dart';
import 'package:flutter_pitel_voip/web_service/http_service.dart';

class SDKService extends HttpService {
  static SDKService? _instance;
  static SDKService getInstance() {
    _instance ??= SDKService();
    return _instance!;
  }

  @override
  String get domain => PitelConfigure.domainSDK;
}
