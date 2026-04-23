class ApiResponse<T> {
  final bool    success;
  final int     statusCode;
  final String? message;
  final T?      data;
  final String  timestamp;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.message,
    this.data,
    this.timestamp = '',
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success:    json['success']     ?? false,
      statusCode: json['status_code'] ?? 0,
      message:    json['message'],
      data:       json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'],
      timestamp:  json['timestamp'] ?? '',
    );
  }

  bool get isSuccess  => success && statusCode >= 200 && statusCode < 300;
  bool get isError    => !success;
  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden   => statusCode == 403;
}