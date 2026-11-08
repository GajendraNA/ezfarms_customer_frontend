import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;

const _timeout = Duration(seconds: 15);
const _jsonHeaders = {'Content-Type': 'application/json; charset=UTF-8'};

/// An error with a message that is safe to show to the user.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

Future<http.Response> _send(Future<http.Response> request) async {
  try {
    return await request.timeout(_timeout);
  } on TimeoutException {
    throw ApiException('The server took too long to respond.');
  } catch (_) {
    throw ApiException(
        "Can't reach the server. Check the connection and server address.");
  }
}

/// GETs a JSON list and returns each entry as a map.
Future<List<Json>> getJsonList(String url) async {
  final response = await _send(http.get(Uri.parse(url)));
  if (response.statusCode != 200) {
    throw ApiException('Server error (${response.statusCode}).');
  }
  final data = json.decode(response.body);
  if (data is! List) throw ApiException('Unexpected response from server.');
  return data.whereType<Map>().map((e) => Json.from(e)).toList();
}

Future<http.Response> postJson(String url, Object body) {
  return _send(http.post(Uri.parse(url),
      headers: _jsonHeaders, body: jsonEncode(body)));
}

Future<http.Response> putJson(String url, Object body) {
  return _send(
      http.put(Uri.parse(url), headers: _jsonHeaders, body: jsonEncode(body)));
}
