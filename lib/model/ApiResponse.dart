class ApiResponse {
  final bool data;
  final String message;
  final bool success;
  final bool error;
  final String responseCode;

  ApiResponse({
    required this.data,
    required this.message,
    required this.success,
    required this.error,
    required this.responseCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: json['data'] ?? false,
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      error: json['error'] ?? false,
      responseCode: json['responsecode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': message,
      'success': success,
      'error': error,
      'responsecode': responseCode,
    };
  }
}

