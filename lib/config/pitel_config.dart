class PitelConfigure {
  static String _apiKey = '742014be-ed40-402e-ae81-b89fff3e228f';
  static String get domainSDK => 'https://sdkdemo.tel4vn.com';
  static String get domainPortal => 'https://portal.tel4vn.com';
  //! PROD
  // static String get apiPushUrl => 'https://api-pusher.tel4vn.com/v1';
  static String get apiPushUrl => 'https://api.pitel-pusher.dev.tel4vn.com/v1';
  static String get token => 'Pitel@@2023!Mobile!PitelConnect';
  static String get API_KEY => _apiKey;
  static bool isDebug = true;

  static void setApiKey(String key) {
    _apiKey = key;
  }
}
