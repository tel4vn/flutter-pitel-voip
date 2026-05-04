import 'package:flutter_pitel_voip/config/pitel_config.dart';
import 'package:flutter_pitel_voip/web_service/http_service.dart';

class MobileApiService extends HttpService {
  static MobileApiService? _instance;
  static MobileApiService getInstance() {
    _instance ??= MobileApiService();
    return _instance!;
  }

  String? _dynamicDomain;

  set dynamicDomain(String domain) {
    _dynamicDomain = domain;
  }

  @override
  String get domain => _dynamicDomain ?? PitelConfigure.apiMobileUrl;
}
