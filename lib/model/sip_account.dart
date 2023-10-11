class SipAccount {
  String sipUserName;
  String sipPassword;

  SipAccount({required this.sipUserName, required this.sipPassword});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sip_username': sipUserName,
      'sip_password': sipPassword
    };
  }

  factory SipAccount.fromMap(Map<String, dynamic> map) {
    return SipAccount(
        sipUserName: map['sip_username'] as String,
        sipPassword: map['sip_password'] as String);
  }
}
