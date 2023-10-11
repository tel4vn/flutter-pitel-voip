import 'dart:convert';
import 'dart:io';

import 'api_web_service.dart';

abstract class HttpService implements ApiWebService {
  late HttpClient _httpClient;

  HttpService() {
    _httpClient = HttpClient();
  }

  String get domain;

  @override
  Future<Map<String, dynamic>> post(String api, Map<String, dynamic>? headers,
      Map<String, dynamic> body) async {
    try {
      final request = await _httpClient.postUrl(_makeUri(api, null));
      _addHeader(request, headers);
      request.add(
        utf8.encode(
          jsonEncode(
            body,
          ),
        ),
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        return json.decode(responseBody) as Map<String, dynamic>;
      }
      throw (response.statusCode);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> get(String api, Map<String, dynamic>? headers,
      Map<String, dynamic>? params) async {
    try {
      final request = await _httpClient.getUrl(_makeUri(api, params));
      _addHeader(request, headers);
      request.headers.contentType = ContentType('application', 'json');
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        return json.decode(responseBody) as Map<String, dynamic>;
      }
      throw (response.statusCode);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> delete(String api, Map<String, dynamic>? headers,
      Map<String, dynamic> body) async {
    try {
      final request = await _httpClient.deleteUrl(_makeUri(api, null));
      _addHeader(request, headers);
      request.add(
        utf8.encode(
          jsonEncode(
            body,
          ),
        ),
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        return json.decode(responseBody) as Map<String, dynamic>;
      }
      throw (response.statusCode);
    } catch (error) {
      rethrow;
    }
  }

  void _addHeader(HttpClientRequest request, Map<String, dynamic>? headers) {
    // ignore: avoid_function_literals_in_foreach_calls
    headers?.keys.forEach((key) {
      request.headers.set(key, headers[key]);
    });
    request.headers.contentType = ContentType('application', 'json');
  }

  Uri _makeUri(String api, Map<String, dynamic>? params) {
    final url = StringBuffer(domain)..write(api);
    if (params != null) {
      url.write('?');
      final stringParams = StringBuffer('');
      params.forEach((key, dynamic value) {
        if (stringParams.toString() != '') {
          stringParams.write('&');
        }
        stringParams.write('$key=$value');
      });
      url.write(stringParams);
    }
    return Uri.parse(url.toString());
  }
}
