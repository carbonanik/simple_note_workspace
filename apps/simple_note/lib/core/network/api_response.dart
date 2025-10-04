class ApiResponse<T> {
  final T data;
  final String? message;

  ApiResponse({required this.data, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(data: fromJsonT(json['data']), message: json['message']);
  }
}
