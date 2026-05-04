class LogoutPbxRes {
  String? message;

  LogoutPbxRes({
    this.message,
  });

  LogoutPbxRes.fromJson(Map<String, dynamic> json) {
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['message'] = message;
    return json;
  }
}
