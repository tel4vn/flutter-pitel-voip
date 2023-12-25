import 'package:flutter_pitel_voip/config/pitel_config.dart';
import 'package:flutter_pitel_voip/web_service/http_service.dart';

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
