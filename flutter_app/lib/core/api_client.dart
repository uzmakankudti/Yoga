import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'api_exception.dart';
import 'token_store.dart';

class ApiClient {
  final TokenStore tokenStore;
  final http.Client _http;
  bool _refreshing = false;

  ApiClient({TokenStore? tokenStore, http.Client? client})
      : tokenStore = tokenStore ?? TokenStore(),
        _http = client ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool auth = true,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('${Env.apiBaseUrl}$path')
        .replace(queryParameters: query?.isNotEmpty == true ? query : null);

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await tokenStore.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    final encodedBody = body != null ? jsonEncode(body) : null;
    http.Response response;
    switch (method) {
      case 'GET':
        response = await _http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await _http.post(uri, headers: headers, body: encodedBody);
        break;
      case 'PATCH':
        response = await _http.patch(uri, headers: headers, body: encodedBody);
        break;
      case 'DELETE':
        response = await _http.delete(uri, headers: headers);
        break;
      default:
        throw ArgumentError('Unsupported method $method');
    }

    if (response.statusCode == 401 && auth && !isRetry) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(method, path, query: query, body: body, auth: auth, isRetry: true);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'] as String;
        }
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<bool> _tryRefresh() async {
    if (_refreshing) return false;
    _refreshing = true;
    try {
      final refreshToken = await tokenStore.getRefreshToken();
      if (refreshToken == null) return false;
      final uri = Uri.parse('${Env.apiBaseUrl}/auth/refresh');
      final response = await _http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      await tokenStore.saveTokens(
        accessToken: decoded['accessToken'] as String,
        refreshToken: decoded['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }
}
