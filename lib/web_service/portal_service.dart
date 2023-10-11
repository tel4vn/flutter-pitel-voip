import 'package:plugin_pitel/config/pitel_config.dart';
import 'package:plugin_pitel/web_service/http_service.dart';

class PortalService extends HttpService {
  static PortalService? _instance;
  static PortalService getInstance() {
    _instance ??= PortalService();
    return _instance!;
  }

  @override
  String get domain => PitelConfigure.domainPortal;
}
