class ApiException implements Exception {
  const ApiException(this.message);

  factory ApiException.failedToConnect() {
    return const ApiException('Failed to connect to the server');
  }

  factory ApiException.http(int statusCode, String message) {
    return ApiException('[$statusCode] $message');
  }

  factory ApiException.timeout() {
    return const ApiException('Connection timed out');
  }

  factory ApiException.invalidResponse() {
    return const ApiException('Invalid response from the server');
  }

  factory ApiException.networkError() {
    return const ApiException('Network error');
  }

  factory ApiException.unauthorized() {
    return const ApiException('Unauthorized');
  }

  factory ApiException.forbidden() {
    return const ApiException('Forbidden');
  }

  factory ApiException.notFound() {
    return const ApiException('Resource not found');
  }

  factory ApiException.unknown(String message) {
    return ApiException('An unexpected error occurred: $message');
  }

  final String message;

  @override
  String toString() {
    return 'ApiException: $message';
  }
}
