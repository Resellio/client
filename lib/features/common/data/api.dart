import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';

class ApiService {
  ApiService({
    required String baseUrl,
    required this.client,
  }) : _baseUrl = baseUrl;

  final String _baseUrl;
  final http.Client client;

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required String method,
    Map<String, String> headers = defaultHeaders,
    String? body,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');

      switch (method.toUpperCase()) {
        case 'GET':
          final response = await client
              .get(
                uri,
                headers: headers,
              )
              .timeout(const Duration(seconds: 10));

          return _handleResponse(response);
        case 'POST':
          final response = await client
              .post(
                uri,
                headers: headers,
                body: body,
              )
              .timeout(const Duration(seconds: 10));

          return _handleResponse(response);
        default:
          throw ApiException.unknown('Unsupported method: $method');
      }
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException.failedToConnect();
    } on TimeoutException {
      throw ApiException.timeout();
    } on FormatException {
      throw ApiException.invalidResponse();
    } on http.ClientException {
      throw ApiException.networkError();
    } catch (err) {
      throw ApiException.unknown(err.toString());
    }
  }

  Future<Map<String, dynamic>> googleLogin({
    required String accessToken,
    required String endpoint,
  }) async {
    return makeRequest(
      endpoint: endpoint,
      method: 'POST',
      body: jsonEncode({'accessToken': accessToken}),
    );
  }

  Future<Map<String, dynamic>> createOrganizer({
    required String token,
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.organizers,
      method: 'POST',
      headers: {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
      }),
    );
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw ApiException.invalidResponse();
        }
        return decoded;
      case 401:
        throw ApiException.unauthorized();
      case 403:
        throw ApiException.forbidden();
      case 404:
        throw ApiException.notFound();
      case 500:
        throw ApiException.unknown('Internal server error');
      default:
        throw ApiException.http(response.statusCode, response.body);
    }
  }

  void dispose() {
    client.close();
  }
}
