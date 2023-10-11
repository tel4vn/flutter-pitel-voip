import 'package:flutter_pitel_voip/model/sip_server.dart';

class GetExtensionInfoRequest {
  String number;

  GetExtensionInfoRequest({required this.number});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'number': number,
    };
  }

  factory GetExtensionInfoRequest.fromMap(Map<String, dynamic> map) {
    return GetExtensionInfoRequest(
      number: map['number'] as String,
    );
  }
}

class GetExtensionInfoHeaders {
  String xPitelToken;

  GetExtensionInfoHeaders({required this.xPitelToken});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'X-PITEL-TOKEN': xPitelToken,
    };
  }

  factory GetExtensionInfoHeaders.fromMap(Map<String, dynamic> map) {
    return GetExtensionInfoHeaders(
      xPitelToken: map['xPitelToken'] as String,
    );
  }
}

class GetExtensionResponse {
  int id;
  SipServer sipServer;
  String username;
  String password;
  String displayName;
  bool enabled;

  GetExtensionResponse({
    required this.id,
    required this.sipServer,
    required this.username,
    required this.password,
    required this.displayName,
    required this.enabled,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sip_server': sipServer.toMap(),
      'username': username,
      'password': password,
      'display_name': displayName,
      'enabled': enabled,
    };
  }

  factory GetExtensionResponse.fromMap(Map<String, dynamic> map) {
    return GetExtensionResponse(
      id: map['id'] is String
          ? int.parse(map['id'] as String)
          : map['id'] as int,
      sipServer: SipServer.fromMap(map['sip_server'] as Map<String, dynamic>),
      username: map['username'] as String,
      password: map['password'] as String,
      displayName: map['display_name'] as String,
      enabled: map['enabled'] is String
          ? map['enabled'].toLowerCase() == 'true'
          : map['enabled'] as bool,
    );
  }
}
