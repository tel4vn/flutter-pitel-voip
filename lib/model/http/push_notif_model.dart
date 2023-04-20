class RegisterDeviceTokenReq {
  String deviceToken;
  String bundleId;
  String domain;
  String extension;
  String platform;
  String appMode;

  RegisterDeviceTokenReq({
    required this.deviceToken,
    required this.bundleId,
    required this.domain,
    required this.extension,
    required this.platform,
    required this.appMode,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "pn_token": deviceToken,
      "pn_type": platform,
      "app_id": bundleId,
      "domain": domain,
      "extension": extension,
      "app_mode": appMode,
    };
  }

  factory RegisterDeviceTokenReq.fromMap(Map<String, dynamic> map) {
    return RegisterDeviceTokenReq(
      deviceToken: map['pn_token'] as String,
      platform: map['pn_type'] as String,
      bundleId: map['app_id'] as String,
      domain: map['domain'] as String,
      extension: map['extension'] as String,
      appMode: map['app_mode'] as String,
    );
  }
}

class RegisterDeviceTokenRes {
  String domain;
  String extension;
  String pnToken;
  String pnType;

  RegisterDeviceTokenRes({
    required this.domain,
    required this.extension,
    required this.pnToken,
    required this.pnType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'domain': domain,
      'extension': extension,
      'pn_token': pnToken,
      'pn_type': pnType,
    };
  }

  factory RegisterDeviceTokenRes.fromMap(Map<String, dynamic> map) {
    return RegisterDeviceTokenRes(
      domain: map['domain'] as String,
      extension: map['extension'] as String,
      pnToken: map['pn_token'] as String,
      pnType: map['pn_type'] as String,
    );
  }
}

// Remove Device Token Model
class RemoveDeviceTokenReq {
  String domain;
  String extension;
  String deviceToken;

  RemoveDeviceTokenReq({
    required this.domain,
    required this.extension,
    required this.deviceToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pn_token': deviceToken,
      'domain': domain,
      'extension': extension,
    };
  }

  factory RemoveDeviceTokenReq.fromMap(Map<String, dynamic> map) {
    return RemoveDeviceTokenReq(
      deviceToken: map['pn_token'] as String,
      domain: map['domain'] as String,
      extension: map['extension'] as String,
    );
  }
}
