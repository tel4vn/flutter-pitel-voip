import 'package:flutter_pitel_voip/model/http/get_profile.dart';
import 'package:flutter_pitel_voip/model/sip_account.dart';

class PitelProfileUser {
  String email;
  String username;
  String firstName;
  String lastName;
  String name;
  SipAccount sipAccount;

  PitelProfileUser(
      {required this.email,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.name,
      required this.sipAccount});

  factory PitelProfileUser.convertFrom(GetProfileResponse profileResponse) {
    return PitelProfileUser(
      email: profileResponse.email,
      username: profileResponse.username,
      firstName: profileResponse.firstName,
      lastName: profileResponse.lastName,
      name: profileResponse.name,
      sipAccount: profileResponse.sipAccount,
    );
  }

  @override
  String toString() {
    return 'email $email \n'
        'username $username \n'
        'firstName $firstName \n'
        'lastName $lastName \n'
        'name $name \n'
        'sipAccount username ${sipAccount.sipUserName} \n'
        'sipAccount pass ${sipAccount.sipPassword}';
  }
}
