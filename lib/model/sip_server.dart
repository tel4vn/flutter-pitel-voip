class SipServer {
  int id;
  String domain;
  int port;
  String outboundProxy;
  String wss;
  int transport;
  String createdAt;
  String project;

  SipServer(
      {required this.id,
      required this.domain,
      required this.port,
      required this.outboundProxy,
      required this.wss,
      required this.transport,
      required this.createdAt,
      required this.project});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'domain': domain,
      'port': port,
      'outbound_proxy': outboundProxy,
      'wss': wss,
      'transport': transport,
      'created_at': createdAt,
      'project': project,
    };
  }

  factory SipServer.fromMap(Map<String, dynamic> map) {
    return SipServer(
      id: map['id'] is String
          ? int.parse(map['id'] as String)
          : map['id'] as int,
      domain: map['domain'] as String,
      port: map['port'] is String
          ? int.parse(map['port'] as String)
          : map['port'] as int,
      outboundProxy: map['outbound_proxy'] as String,
      wss: map['wss'] as String,
      transport: map['transport'] is String
          ? int.parse(map['transport'] as String)
          : map['transport'] as int,
      createdAt: map['created_at'] as String,
      project: map['project'] is int
          ? (map['project'] as int).toString()
          : map['project'] as String,
    );
  }

  @override
  String toString() {
    return 'id - $id \n'
        'domain $domain \n'
        'port $port \n'
        'outboundProxy $outboundProxy \n'
        'wss $wss \n'
        'transport $transport \n';
  }
}
