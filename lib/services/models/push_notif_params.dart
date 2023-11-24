class PushNotifParams {
  final String teamId;
  final String bundleId;

  PushNotifParams({
    required this.teamId,
    required this.bundleId,
  });

  factory PushNotifParams.fromJson(Map<String, dynamic> data) {
    return PushNotifParams(
      teamId: data['teamId'],
      bundleId: data['bundleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'bundleId': bundleId,
    };
  }
}
