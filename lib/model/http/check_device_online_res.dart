class CheckDeviceOnlineData {
  final int totalDeviceOnline;

  CheckDeviceOnlineData({required this.totalDeviceOnline});

  factory CheckDeviceOnlineData.fromJson(Map<String, dynamic> json) {
    return CheckDeviceOnlineData(
      totalDeviceOnline: json['total_device_online'] as int? ?? 0,
    );
  }
}

class CheckDeviceOnlineRes {
  final String code;
  final String message;
  final CheckDeviceOnlineData data;

  CheckDeviceOnlineRes({
    required this.code,
    required this.message,
    required this.data,
  });

  factory CheckDeviceOnlineRes.fromJson(Map<String, dynamic> json) {
    return CheckDeviceOnlineRes(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: CheckDeviceOnlineData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CheckDeviceOnlineReq {
  final String domain;
  final String extension;

  CheckDeviceOnlineReq({required this.domain, required this.extension});

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'extension': extension,
    };
  }
}
