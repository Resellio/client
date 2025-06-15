import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';
import 'package:resellio/features/common/data/api_response.dart';

class ApiService {
  ApiService({
    required String baseUrl,
    required this.client,
    String? Function()? tokenProvider,
  })  : _baseUrl = baseUrl,
        _tokenProvider = tokenProvider;

  final String _baseUrl;
  final http.Client client;
  final String? Function()? _tokenProvider;

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _headersWithAuth {
    final token = _tokenProvider?.call();
    return {
      ...defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse<Map<String, dynamic>>> makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? body,
    bool requiresAuth = true,
  }) async {
    try {
      final Map<String, String>? stringQueryParameters =
          queryParameters?.map((key, value) => MapEntry(key, value.toString()));

      final uri = Uri.parse('$_baseUrl/$endpoint')
          .replace(queryParameters: stringQueryParameters);

      final requestHeaders =
          headers ?? (requiresAuth ? _headersWithAuth : defaultHeaders);
      debugPrint('Making request to: $uri');
      debugPrint('Method: $method');
      debugPrint('Headers: $requestHeaders');
      if (body != null) {
        debugPrint('Body: $body');
      }

      switch (method.toUpperCase()) {
        case 'GET':
          final response = await client
              .get(uri, headers: requestHeaders)
              .timeout(const Duration(seconds: 10));
          return _handleResponse(response);
        case 'POST':
          final response = await client
              .post(uri, headers: requestHeaders, body: body)
              .timeout(const Duration(seconds: 10));
          return _handleResponse(response);
        case 'DELETE':
          final response = await client
              .delete(uri, headers: requestHeaders, body: body)
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

  Future<ApiResponse<Map<String, dynamic>>> makeMultipartRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
    bool requiresAuth = true,
  }) async {
    try {
      final Map<String, String>? stringQueryParameters =
          queryParameters?.map((key, value) => MapEntry(key, value.toString()));

      final uri = Uri.parse('$_baseUrl/$endpoint')
          .replace(queryParameters: stringQueryParameters);

      print('Making multipart request to: $uri');
      print('Method: $method');
      print('Fields: $fields');
      if (files != null) print('Files count: ${files.length}');

      final request = http.MultipartRequest(method.toUpperCase(), uri);

      if (requiresAuth) {
        final token = _tokenProvider?.call();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      if (headers != null) {
        final filteredHeaders = Map<String, String>.from(headers)
          ..remove('Content-Type');
        request.headers.addAll(filteredHeaders);
      }

      print('Multipart Headers: ${request.headers}');

      request.fields.addAll(fields);

      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
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
      print('Unknown Error in makeMultipartRequest: $err');
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
      requiresAuth: false,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCategories() async {
    return makeRequest(
      endpoint: ApiEndpoints.categories,
      method: 'GET',
      queryParameters: {
        'page': '0',
        'pageSize': '100',
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createOrganizer({
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.organizers,
      method: 'POST',
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
      }),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> organizerAboutMe(
    String token,
  ) async {
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
    required int page,
    required int pageSize,
    String? query,
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

    if (query != null && query.trim().isNotEmpty) {
      queryParams['SearchQuery'] = query.trim();
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
    if (categories != null && categories.isNotEmpty) {
      for (var i = 0; i < categories.length; i++) {
        queryParams['CategoriesNames[$i]'] = categories[i];
      }
    }

    return makeRequest(
      endpoint: ApiEndpoints.events,
      method: 'GET',
      queryParameters: queryParams,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrganizerEvents({
    required int page,
    required int pageSize,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? minStartDate,
    DateTime? maxStartDate,
    DateTime? minEndDate,
    DateTime? maxEndDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (query != null && query.trim().isNotEmpty) {
      queryParams['SearchQuery'] = query.trim();
    }
    if (startDate != null) {
      queryParams['minEndDate'] = startDate.toString();
    }
    if (endDate != null) {
      queryParams['maxStartDate'] = endDate.toString();
    }
    if (minStartDate != null) {
      queryParams['minStartDate'] = minStartDate.toString();
    }
    if (maxStartDate != null) {
      queryParams['maxStartDate'] = maxStartDate.toString();
    }
    if (minEndDate != null) {
      queryParams['minEndDate'] = minEndDate.toString();
    }
    if (maxEndDate != null) {
      queryParams['maxEndDate'] = maxEndDate.toString();
    }

    return makeRequest(
      endpoint: ApiEndpoints.organizerEvents,
      method: 'GET',
      queryParameters: queryParams,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getEventDetails({
    required String eventId,
  }) async {
    return makeRequest(
      endpoint: '${ApiEndpoints.events}/$eventId',
      method: 'GET',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrganizerEventDetails({
    required String token,
    required String eventId,
  }) async {
    return makeRequest(
      endpoint: '${ApiEndpoints.organizerEvents}/$eventId',
      method: 'GET',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createEvent({
    required Map<String, dynamic> eventData,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final fields = <String, String>{};

    void addFieldsRecursively(Map<String, dynamic> data, String prefix) {
      data.forEach((key, value) {
        final fieldKey = prefix.isEmpty ? key : '$prefix.$key';

        if (value is Map<String, dynamic>) {
          addFieldsRecursively(value, fieldKey);
        } else if (value is List) {
          for (int i = 0; i < value.length; i++) {
            if (value[i] is Map<String, dynamic>) {
              addFieldsRecursively(
                  value[i] as Map<String, dynamic>, '$fieldKey[$i]');
            } else {
              fields['$fieldKey[$i]'] = value[i].toString();
            }
          }
          if (value.isEmpty) {
            fields[fieldKey] = '';
          }
        } else {
          fields[fieldKey] = value?.toString() ?? '';
        }
      });
    }

    addFieldsRecursively(eventData, '');

    final files = <http.MultipartFile>[];

    if (imageBytes != null) {
      final imageFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName ?? 'event_image.jpg',
      );
      files.add(imageFile);
    }

    return makeMultipartRequest(
      endpoint: ApiEndpoints.events,
      method: 'POST',
      fields: fields,
      files: files.isNotEmpty ? files : null,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCart() async {
    return makeRequest(
      endpoint: ApiEndpoints.shoppingCarts,
      method: 'GET',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addTicket({
    required String ticketTypeId,
    required int quantity,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.shoppingCarts,
      method: 'POST',
      body: jsonEncode({
        'ticketTypeId': ticketTypeId,
        'amount': quantity,
      }),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addResellTicketToCart({
    required String ticketId,
  }) async {
    return makeRequest(
      endpoint: '${ApiEndpoints.shoppingCarts}/$ticketId',
      method: 'POST',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> removeTicket({
    required String ticketTypeId,
    required int quantity,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.shoppingCarts,
      method: 'DELETE',
      body: jsonEncode({
        'ticketTypeId': ticketTypeId,
        'amount': quantity,
      }),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> removeResellTicketFromCart({
    required String ticketId,
  }) async {
    return makeRequest(
      endpoint: '${ApiEndpoints.shoppingCarts}/$ticketId',
      method: 'DELETE',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getDueAmount() async {
    return makeRequest(
      endpoint: ApiEndpoints.checkoutDue,
      method: 'GET',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> checkout({
    required double amount,
    required String currency,
    required String cardNumber,
    required String cardExpiry,
    required String cvv,
  }) async {
    return makeRequest(
      endpoint: ApiEndpoints.checkout,
      method: 'POST',
      body: jsonEncode({
        'amount': double.parse(amount.toStringAsFixed(2)),
        'currency': currency,
        'cardNumber': cardNumber,
        'cardExpiry': cardExpiry,
        'cvv': cvv,
      }),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTickets({
    required int page,
    required int pageSize,
    int? usage,
    int? resell,
    String? eventName,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (usage != null) {
      queryParams['Usage'] = usage.toString();
    }
    if (resell != null) {
      queryParams['Resell'] = resell.toString();
    }
    if (eventName != null && eventName.trim().isNotEmpty) {
      queryParams['EventName'] = eventName.trim();
    }

    return makeRequest(
      endpoint: ApiEndpoints.tickets,
      method: 'GET',
      queryParameters: queryParams,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTicketDetails({
    required String ticketId,
  }) async {
    return makeRequest(
      endpoint: '${ApiEndpoints.tickets}/$ticketId',
      method: 'GET',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resellTicket({
    required String ticketId,
    required double resellPrice,
    required String resellCurrency,
  }) async {
    return makeRequest(
      endpoint: '${ApiEndpoints.tickets}/resell/$ticketId',
      method: 'POST',
      body: jsonEncode({
        'resellPrice': resellPrice,
        'resellCurrency': resellCurrency,
      }),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTicketsForResell({
    required String eventId,
    required int page,
    required int pageSize,
  }) async {
    final queryParams = <String, dynamic>{
      'eventId': eventId,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    return makeRequest(
      endpoint: '${ApiEndpoints.tickets}/for-resell',
      method: 'GET',
      queryParameters: queryParams,
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
