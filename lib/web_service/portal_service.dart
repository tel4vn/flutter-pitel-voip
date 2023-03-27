import 'package:plugin_pitel/config/pitel_config.dart';
import 'package:plugin_pitel/web_service/http_service.dart';

class PortalService extends HttpService {
  static PortalService? _instance;
  static PortalService getInstance() {
    if (_instance == null) {
      _instance = PortalService();
    }
    return _instance!;
  }

  @override
  String get domain => PitelConfigure.domainPortal;
}
