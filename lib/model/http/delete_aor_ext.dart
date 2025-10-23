// Remove Device Token Model
class DeleteAorExtReq {
  String contact;
  String aor;
  String tenantName;

  DeleteAorExtReq({
    required this.contact,
    required this.aor,
    required this.tenantName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenant_name': tenantName,
      'contact': contact,
      'aor': aor,
    };
  }

  factory DeleteAorExtReq.fromMap(Map<String, dynamic> map) {
    return DeleteAorExtReq(
      tenantName: map['tenant_name'] as String,
      contact: map['contact'] as String,
      aor: map['aor'] as String,
    );
  }
}

class DeleteAorExtRes {
  String code;
  String message;

  DeleteAorExtRes({
    required this.code,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'message': message,
    };
  }

  factory DeleteAorExtRes.fromMap(Map<String, dynamic> map) {
    return DeleteAorExtRes(
      code: map['code'] as String,
      message: map['message'] as String,
    );
  }
}
