class BaseHeaders {
  String authorization;

  BaseHeaders({required this.authorization});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'authorization': authorization,
    };
  }

  factory BaseHeaders.fromMap(Map<String, dynamic> map) {
    return BaseHeaders(
      authorization: map['authorization'] as String,
    );
  }
}
