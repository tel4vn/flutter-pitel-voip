class LogoutPbxReq {
  bool? unregister;
  String? userAgent;

  LogoutPbxReq({this.unregister, this.userAgent});

  LogoutPbxReq.fromJson(Map<String, dynamic> json) {
    unregister = json['unregister'];
    userAgent = json['user_agent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unregister'] = this.unregister;
    data['user_agent'] = this.userAgent;
    return data;
  }
}
