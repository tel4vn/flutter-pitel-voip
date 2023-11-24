import 'package:flutter_pitel_voip/model/http/get_extension_info.dart';
import 'package:flutter_pitel_voip/model/sip_server.dart';

class SipInfoData {
  final String authPass;
  final String registerServer;
  final String outboundServer;
  final int? port;
  final int? userID;
  final int? authID;
  final String accountName;
  final String displayName;
  final String? dialPlan;
  final String? randomPort;
  final String? voicemail;
  final String wssUrl;
  final String? userName;
  final String? apiDomain;
  final String? userAgent;

  SipInfoData({
    required this.authPass,
    required this.registerServer,
    required this.outboundServer,
    this.port,
    this.userID,
    this.authID,
    required this.accountName,
    this.displayName = '',
    this.dialPlan,
    this.randomPort,
    this.voicemail,
    required this.wssUrl,
    this.userName,
    this.apiDomain,
    this.userAgent,
  });

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
          apiDomain: "",
          userAgent: "",
        );

  factory SipInfoData.fromJson(Map<String, dynamic> data) {
    return SipInfoData(
      authPass: data['authPass'],
      userID: data['userID'],
      authID: data['authID'],
      registerServer: data['registerServer'],
      outboundServer: data['outboundServer'],
      port: data['port'],
      accountName: data['accountName'],
      displayName: data['displayName'],
      dialPlan: data['dialPlan'],
      randomPort: data['randomPort'],
      voicemail: data['voicemail'],
      wssUrl: data['wssUrl'],
      userName: data['userName'],
      apiDomain: data['apiDomain'],
      userAgent: data['userAgent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authPass': authPass,
      'registerServer': registerServer,
      'outboundServer': outboundServer,
      'port': port,
      'userID': userID,
      'authID': authID,
      'accountName': accountName,
      'displayName': displayName,
      'dialPlan': dialPlan,
      'randomPort': randomPort,
      'voicemail': voicemail,
      'wssUrl': wssUrl,
      'userName': userName,
      'apiDomain': apiDomain,
      'userAgent': userAgent
    };
  }

  GetExtensionResponse toGetExtensionResponse() {
    final sipServer = SipServer(
      id: 1,
      domain: registerServer,
      port: port ?? 5060,
      outboundProxy: outboundServer,
      wss: wssUrl,
      transport: 0,
      createdAt: '',
      project: '',
      userAgent: userAgent ?? '',
    );

    final getExtResponse = GetExtensionResponse(
      id: 1,
      sipServer: sipServer,
      username: accountName,
      password: authPass,
      displayName: displayName,
      enabled: true,
    );

    return getExtResponse;
  }
}
