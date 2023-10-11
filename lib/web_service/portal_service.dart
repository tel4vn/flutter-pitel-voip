import 'package:flutter_pitel_voip/config/pitel_config.dart';
import 'package:flutter_pitel_voip/web_service/http_service.dart';

class PortalService extends HttpService {
  static PortalService? _instance;
  static PortalService getInstance() {
    _instance ??= PortalService();
    return _instance!;
  }

  @override
  String get domain => PitelConfigure.domainPortal;
}
