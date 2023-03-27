abstract class ApiWebService {
  Future<Map<String, dynamic>> post(
      String api, Map<String, dynamic>? headers, Map<String, dynamic> body);
  Future<Map<String, dynamic>> get(
      String api, Map<String, dynamic>? headers, Map<String, dynamic>? params);
}
