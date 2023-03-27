import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final String _USER_NAME = 'username';
  static final String _PASSWORD = 'username';
  static final String _STATE_CALL = 'state-call';
  static final LocalStorage _localStorage = LocalStorage._internal();

  factory LocalStorage() => _localStorage;

  LocalStorage._internal();

  // LocalStorage getInstance() => _localStorage;

  _getSharedPreference() async {
    return await SharedPreferences.getInstance();
  }

  saveAccount(Account account) async {
    SharedPreferences sharedPreferences = await _getSharedPreference();
    await sharedPreferences.setString(_USER_NAME, account.username);
    await sharedPreferences.setString(_PASSWORD, account.password);
  }

  Future<Account?> getAccountLocal() async {
    SharedPreferences sharedPreferences = await _getSharedPreference();
    String? username = sharedPreferences.getString(_USER_NAME);
    String? password = sharedPreferences.getString(_PASSWORD);
    if (username != null && password != null) {
      return Account(username, password);
    }
    return null;
  }

  saveStateCall() async {
    SharedPreferences sharedPreferences = await _getSharedPreference();
    await sharedPreferences.setBool(_STATE_CALL, true);
  }

  Future<bool> getStateCall() async {
    SharedPreferences sharedPreferences = await _getSharedPreference();
    bool stateCall = sharedPreferences.getBool(_STATE_CALL) ?? false;
    return stateCall;
  }
}

class Account {
  final String username;
  final String password;

  Account(this.username, this.password);
}
