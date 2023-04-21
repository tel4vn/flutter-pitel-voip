import 'package:plugin_pitel/model/http/get_extension_info.dart';
import 'package:plugin_pitel/model/sip_server.dart';

class SipInfoData {
  final String authPass;
  final String registerServer;
  final String outboundServer;
  final int userID;
  final int authID;
  final String accountName;
  final String displayName;
  final String? dialPlan;
  final String? randomPort;
  final String? voicemail;
  final String wssUrl;
  final String? userName;
  final String? apiDomain;

  SipInfoData(
      {required this.authPass,
      required this.registerServer,
      required this.outboundServer,
      required this.userID,
      required this.authID,
      required this.accountName,
      required this.displayName,
      this.dialPlan,
      this.randomPort,
      this.voicemail,
      required this.wssUrl,
      this.userName,
      this.apiDomain});

  SipInfoData.defaultSipInfo()
      : this(
            wssUrl: "",
            userID: 0,
            authID: 0,
            accountName: "",
            displayName: "",
            registerServer: "",
            outboundServer: "",
            authPass: "",
            userName: "",
            apiDomain: "");

  factory SipInfoData.fromJson(Map<String, dynamic> data) {
    return SipInfoData(
        authPass: data['authPass'],
        userID: data['userID'],
        authID: data['authID'],
        registerServer: data['registerServer'],
        outboundServer: data['outboundServer'],
        accountName: data['accountName'],
        displayName: data['displayName'],
        dialPlan: data['dialPlan'],
        randomPort: data['randomPort'],
        voicemail: data['voicemail'],
        wssUrl: data['wssUrl'],
        userName: data['userName'],
        apiDomain: data['apiDomain']);
  }

  Map<String, dynamic> toJson() {
    return {
      'authPass': authPass,
      'registerServer': registerServer,
      'outboundServer': outboundServer,
      'userID': userID,
      'authID': authID,
      'accountName': accountName,
      'displayName': displayName,
      'dialPlan': dialPlan,
      'randomPort': randomPort,
      'voicemail': voicemail,
      'wssUrl': wssUrl,
      'userName': userName,
      'apiDomain': apiDomain
    };
  }

  GetExtensionResponse toGetExtensionResponse() {
    final sipServer = SipServer(
      id: 1,
      domain: registerServer,
      port: 50061,
      outboundProxy: outboundServer,
      wss: wssUrl,
      transport: 0,
      createdAt: '',
      project: '',
      pnProvider: 'tel4vn',
      pnParam: 'tel4vn',
      pnPrid: 'tel4vn',
    );

    final getExtResponse = GetExtensionResponse(
      id: 1,
      sipServer: sipServer,
      username: accountName,
      password: authPass,
      display_name: displayName,
      enabled: true,
    );

    return getExtResponse;
  }
}
