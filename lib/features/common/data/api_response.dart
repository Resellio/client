class ApiResponse<T> {
  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.message(String message, int statusCode) {
    return ApiResponse(
      success: true,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.success(T data, int statusCode, [String? message]) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  final bool success;
  final T? data;
  final String? message;
  final int statusCode;
}
