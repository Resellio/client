import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, String> headers = defaultHeaders,
    String? body,
  }) async {
    try {
      final Map<String, String>? stringQueryParameters =
          queryParameters?.map((key, value) => MapEntry(key, value.toString()));

      final uri = Uri.parse('$_baseUrl/$endpoint')
          .replace(queryParameters: stringQueryParameters);

      print('Making request to: $uri');
      print('Method: $method');
      print('Headers: $headers');
      if (body != null) print('Body: $body');

      http.Response response;

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
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw ApiException.failedToConnect();
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw ApiException.timeout();
    } on FormatException catch (e) {
      print('FormatException: $e');
      throw ApiException.invalidResponse();
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw ApiException.networkError();
    } catch (err) {
      print('Unknown Error in makeRequest: $err');
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

  Future<Map<String, dynamic>> organizerAboutMe({
    required String token,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.organizerAboutMe,
      method: 'GET',
      headers: {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> getEvents({
    required String token,
    required int page,
    required int pageSize,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? city,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }
    if (startDate != null) {
      queryParams['minEndDate'] = startDate.toString();
    }
    if (endDate != null) {
      queryParams['maxStartDate'] = endDate.toString();
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice.toString();
    }
    if (city != null && city.trim().isNotEmpty) {
      queryParams['addressCity'] = city.trim();
    }
    // if (category != null && category.trim().isNotEmpty) {
    //   queryParams['category'] = category.trim();
    // }

    return makeRequest(
      endpoint: ApiEndpoints.events,
      method: 'GET',
      queryParameters: queryParams,
      headers: {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final contentType = response.headers['content-type'];
    dynamic decoded;

    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {};
      } else {
        print(
            'Error: Empty response body for status code ${response.statusCode}');
        throw ApiException.http(response.statusCode,
            'Server returned empty response for error status.');
      }
    }

    if (contentType != null && contentType.contains('application/json')) {
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('JSON Decode Error: $e');
        throw ApiException.invalidResponse();
      }
    } else {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print(
            'Warning: Received non-JSON error response (Content-Type: $contentType)');
        throw ApiException.http(response.statusCode, response.body);
      } else {
        print(
            'Warning: Received successful non-JSON response. Returning empty map.');
        return {};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded == null && response.body.isEmpty) {
        return {};
      } else {
        print('Error: Expected JSON Map but got ${decoded.runtimeType}');
        throw ApiException.invalidResponse();
      }
    } else {
      print('API Error: ${response.body}');

      switch (response.statusCode) {
        case 401:
          throw ApiException.unauthorized();
        case 403:
          throw ApiException.forbidden();
        case 404:
          throw ApiException.notFound();
        case 500:
          throw ApiException.unknown('Internal server error: ${response.body}');
        default:
          throw ApiException.http(response.statusCode, response.body);
      }
    }
  }

  void dispose() {
    client.close();
  }
}
