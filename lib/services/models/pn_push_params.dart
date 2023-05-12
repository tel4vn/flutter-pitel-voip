class PnPushParams {
  final String pnProvider;
  final String pnPrid;
  final String pnParam;
  final String fcmToken;

  PnPushParams({
    required this.pnProvider,
    required this.pnPrid,
    required this.pnParam,
    required this.fcmToken,
  });

  factory PnPushParams.fromJson(Map<String, dynamic> data) {
    return PnPushParams(
      pnProvider: data['pnProvider'],
      pnPrid: data['pnPrid'],
      pnParam: data['pnParam'],
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pnProvider': pnProvider,
      'pnPrid': pnPrid,
      'pnParam': pnParam,
      'fcmToken': fcmToken,
    };
  }
}
