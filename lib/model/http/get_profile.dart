import 'package:plugin_pitel/model/http/base_header.dart';
import 'package:plugin_pitel/model/sip_account.dart';

class GetProfileRequest {}

class GetProfileHeaders extends BaseHeaders {
  GetProfileHeaders({required String token})
      : super(authorization: 'JWT $token');
}

class GetProfileResponse {
  int id;
  String email;
  String username;
  String firstName;
  String lastName;
  String name;
  SipAccount sipAccount;

  GetProfileResponse(
      {required this.id,
      required this.email,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.name,
      required this.sipAccount});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'sip_account': sipAccount.toMap(),
    };
  }

  factory GetProfileResponse.fromMap(Map<String, dynamic> map) {
    return GetProfileResponse(
      id: map['id'] is String
          ? int.parse(map['id'] as String)
          : map['id'] as int,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      sipAccount:
          SipAccount.fromMap(map['sip_account'] as Map<String, dynamic>),
    );
  }
}
