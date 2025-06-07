import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/common/data/api_response.dart';

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

  Future<ApiResponse<Map<String, dynamic>>> makeRequest({
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

  Future<ApiResponse<Map<String, dynamic>>> googleLogin({
    required String accessToken,
    required String endpoint,
  }) async {
    return makeRequest(
      endpoint: endpoint,
      method: 'POST',
      body: jsonEncode({'accessToken': accessToken}),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCategories(
    String token,
  ) async {
    return makeRequest(
      endpoint: ApiEndpoints.categories,
      headers: {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      },
      method: 'GET',
      queryParameters: {
        'page': '0',
        'pageSize': '100',
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createOrganizer({
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

  Future<ApiResponse<Map<String, dynamic>>> organizerAboutMe({
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

  Future<ApiResponse<Map<String, dynamic>>> getEvents({
    required String token,
    required int page,
    required int pageSize,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? city,
    List<String>? categories,
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
    // TODO:
    // if (categories != null && categories.isNotEmpty) {
    //   queryParams['categories'] =
    //       categories.map((e) => {name: e.trim()}).toList();
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

  Future<ApiResponse<Map<String, dynamic>>> getOrganizerEvents({
    required String token,
    required int page,
    required int pageSize,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    return makeRequest(
      endpoint: ApiEndpoints.organizerGetEvents,
      method: 'GET',
      queryParameters: queryParams,
      headers: {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createEvent({
    required String token,
    required Map<String, dynamic> eventData,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.events,
      method: 'POST',
      headers: {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrganizerEventDetails({
    required String token,
    required String id,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.organizerGetEventDetails(id),
      method: 'GET',
      headers: {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final contentType = response.headers['content-type'];

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.message('Success', response.statusCode);
      }

      if (contentType != null && contentType.contains('application/json')) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return ApiResponse.success(decoded, response.statusCode);
          } else {
            return ApiResponse.success({'data': decoded}, response.statusCode);
          }
        } catch (err) {
          throw ApiException.invalidResponse();
        }
      } else {
        return ApiResponse.message(response.body.trim(), response.statusCode);
      }
    }

    throw ApiException.http(response.statusCode, response.body);
  }

  void dispose() {
    client.close();
  }
}
