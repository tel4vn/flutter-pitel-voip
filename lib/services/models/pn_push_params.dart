class PnPushParams {
  final String pnProvider;
  final String pnPrid;
  final String pnParam;

  PnPushParams({
    required this.pnProvider,
    required this.pnPrid,
    required this.pnParam,
  });

  factory PnPushParams.fromJson(Map<String, dynamic> data) {
    return PnPushParams(
      pnProvider: data['pnProvider'],
      pnPrid: data['pnPrid'],
      pnParam: data['pnParam'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pnProvider': pnProvider,
      'pnPrid': pnPrid,
      'pnParam': pnParam,
    };
  }
}
