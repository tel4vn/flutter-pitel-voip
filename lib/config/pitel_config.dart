class PitelConfigure {
  static String _apiKey = '742014be-ed40-402e-ae81-b89fff3e228f';
  static String get domainSDK => 'https://sdkdemo.tel4vn.com';
  static String get domainPortal => 'https://portal.tel4vn.com';
  static String get API_KEY => _apiKey;
  static bool isDebug = true;

  static void setApiKey(String key) {
    _apiKey = key;
  }
}
