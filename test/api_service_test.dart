import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/data/api_exceptions.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late ApiService apiService;
  const baseUrl = ApiEndpoints.baseUrl;
  const successResponse = {'token': 'jwt-token'};

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiService = ApiService(baseUrl: baseUrl, client: mockHttpClient);
    registerFallbackValue(Uri());
  });

  tearDown(() {
    apiService.dispose();
  });

  group('googleLogin', () {
    const accessToken = 'test-access-token';

    test('successful google login returns decoded response', () async {
      when(
        () => mockHttpClient.post(
          Uri.parse('$baseUrl/${ApiEndpoints.customerGoogleLogin}'),
          headers: ApiService.defaultHeaders,
          body: jsonEncode({'accessToken': accessToken}),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode(successResponse), 200),
      );

      final result = await apiService.googleLogin(
        accessToken: accessToken,
        endpoint: ApiEndpoints.customerGoogleLogin,
      );

      expect(result, successResponse);
    });

    test('401 response throws unauthorized exception', () async {
      when(
        () => mockHttpClient.post(
          Uri.parse('$baseUrl/${ApiEndpoints.customerGoogleLogin}'),
          headers: ApiService.defaultHeaders,
          body: jsonEncode({'accessToken': accessToken}),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => apiService.googleLogin(
          accessToken: accessToken,
          endpoint: ApiEndpoints.customerGoogleLogin,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Unauthorized'),
        ),
      );
    });

    test('handles invalid response format', () async {
      when(
        () => mockHttpClient.post(
          Uri.parse('$baseUrl/${ApiEndpoints.customerGoogleLogin}'),
          headers: ApiService.defaultHeaders,
          body: jsonEncode({'accessToken': accessToken}),
        ),
      ).thenAnswer((_) async => http.Response('Not a JSON', 200));

      expect(
        () => apiService.googleLogin(
          accessToken: accessToken,
          endpoint: ApiEndpoints.customerGoogleLogin,
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('handles 403 forbidden response', () async {
      when(
        () => mockHttpClient.post(
          Uri.parse('$baseUrl/${ApiEndpoints.customerGoogleLogin}'),
          headers: ApiService.defaultHeaders,
          body: jsonEncode({'accessToken': accessToken}),
        ),
      ).thenAnswer((_) async => http.Response('Forbidden', 403));

      expect(
        () => apiService.googleLogin(
          accessToken: accessToken,
          endpoint: ApiEndpoints.customerGoogleLogin,
        ),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'Forbidden'),
        ),
      );
    });
  });

  group('createOrganizer', () {
    const token = 'test-token';
    const firstName = 'John';
    const lastName = 'Doe';
    const displayName = 'JohnDoe';

    test('successful organizer creation returns decoded response', () async {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      when(
        () => mockHttpClient.post(
          Uri.parse('$baseUrl/${ApiEndpoints.organizers}'),
          headers: headers,
          body: jsonEncode({
            'firstName': firstName,
            'lastName': lastName,
            'displayName': displayName,
          }),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode(successResponse), 200),
      );

      final result = await apiService.createOrganizer(
        token: token,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
      );

      expect(result, successResponse);
    });

    test('handles network errors during organizer creation', () async {
      when(
        () => mockHttpClient.post(
          Uri.parse('$baseUrl/${ApiEndpoints.organizers}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'firstName': firstName,
            'lastName': lastName,
            'displayName': displayName,
          }),
        ),
      ).thenThrow(const SocketException('Network error'));

      expect(
        () => apiService.createOrganizer(
          token: token,
          firstName: firstName,
          lastName: lastName,
          displayName: displayName,
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Failed to connect to the server',
          ),
        ),
      );
    });

    test('handles unauthorized token during organizer creation', () async {
      when(
        () => mockHttpClient.post(
          Uri.parse('$baseUrl/${ApiEndpoints.organizers}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'firstName': firstName,
            'lastName': lastName,
            'displayName': displayName,
          }),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => apiService.createOrganizer(
          token: token,
          firstName: firstName,
          lastName: lastName,
          displayName: displayName,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Unauthorized'),
        ),
      );
    });
  });

  group('makeRequest', () {
    test('handles timeout exception', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: ApiService.defaultHeaders,
        ),
      ).thenThrow(TimeoutException('Request timed out'));

      expect(
        () => apiService.makeRequest(endpoint: 'test', method: 'GET'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Connection timed out'),
        ),
      );
    });

    test('handles socket exception', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: ApiService.defaultHeaders,
        ),
      ).thenThrow(const SocketException('Failed to connect'));

      expect(
        () => apiService.makeRequest(endpoint: 'test', method: 'GET'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Failed to connect to the server',
          ),
        ),
      );
    });

    test('handles unknown HTTP method', () async {
      expect(
        () => apiService.makeRequest(endpoint: 'test', method: 'PATCH'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'An unexpected error occurred: Unsupported method: PATCH',
          ),
        ),
      );
    });

    test('handles HTTP error responses', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: ApiService.defaultHeaders,
        ),
      ).thenAnswer((_) async => http.Response('Server Error', 500));

      expect(
        () => apiService.makeRequest(endpoint: 'test', method: 'GET'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'An unexpected error occurred: Internal server error',
          ),
        ),
      );
    });

    test('handles generic unexpected errors', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: ApiService.defaultHeaders,
        ),
      ).thenThrow(Exception('Unexpected error'));

      expect(
        () => apiService.makeRequest(endpoint: 'test', method: 'GET'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'An unexpected error occurred: Exception: Unexpected error',
          ),
        ),
      );
    });

    test('throws timeout exception after 10 seconds', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: ApiService.defaultHeaders,
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 11),
          () => http.Response('{}', 200),
        ),
      );

      expect(
        () => apiService.makeRequest(endpoint: 'test', method: 'GET'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Connection timed out'),
        ),
      );
    });

    test('custom headers are sent with request', () async {
      final customHeaders = {'X-Custom-Header': 'test-value'};
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: customHeaders,
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode({'key': 'value'}), 200),
      );

      final result = await apiService.makeRequest(
        endpoint: 'test',
        method: 'GET',
        headers: customHeaders,
      );

      expect(result, {'key': 'value'});
      verify(() => mockHttpClient.get(any(), headers: customHeaders)).called(1);
    });

    test('handles 404 not found response', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: ApiService.defaultHeaders,
        ),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => apiService.makeRequest(endpoint: 'test', method: 'GET'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Resource not found',
          ),
        ),
      );
    });

    test('handles concurrent requests', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/test'),
          headers: ApiService.defaultHeaders,
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode({'id': 1}), 200));

      final results = await Future.wait([
        apiService.makeRequest(endpoint: 'test', method: 'GET'),
        apiService.makeRequest(endpoint: 'test', method: 'GET'),
      ]);

      expect(results.length, 2);
      expect(results[0], {'id': 1});
      expect(results[1], {'id': 1});
    });
  });

  group('dispose', () {
    test('closes the http client', () {
      apiService.dispose();

      verify(() => mockHttpClient.close()).called(1);
    });
  });
}
