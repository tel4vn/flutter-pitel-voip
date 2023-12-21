import 'package:plugin_pitel/config/pitel_config.dart';
import 'package:plugin_pitel/web_service/http_service.dart';

class PushNotifService extends HttpService {
  static PushNotifService? _instance;
  static PushNotifService getInstance() {
    _instance ??= PushNotifService();
    return _instance!;
  }

  @override
  String get domain => PitelConfigure.apiPushUrl;

  String get token => PitelConfigure.token;
}
