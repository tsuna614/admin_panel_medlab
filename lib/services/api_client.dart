import 'package:admin_panel_medlab/data/global_data.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<ApiResponse<T>> get<T>({
    // this is the url for the http method call
    required String endpoint,
    // this is to convert the response, if we want it to convert to the type we desire
    // we pass the convert function to wherever we need to make the call
    // for example, for Map<String, dynamic> -> Book, we use:
    // "fromJson: (data) => Book.fromJson(data)" to fetch a single book
    // "fromJson: (data) => data.map<Book>((book) => Book.fromJson(book)).toList()" to fetch a list of book
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
    Options? options,
  }) async {
    try {
      final url = "${GlobalData.baseUrl}$endpoint";

      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
      // print(response);
      return ApiResponse(
        data: fromJson != null ? fromJson(response.data) : response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        errorMessage: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    // this is the body that you put into the http method call. GET method don't have the body so this field is not needed
    required dynamic data,
    T Function(dynamic data)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await dio.post(endpoint, data: data, options: options);
      return ApiResponse(
        data: fromJson != null ? fromJson(response.data) : response.data,
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      return ApiResponse(
        errorMessage: errorMessage,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    required dynamic data,
    T Function(dynamic data)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await dio.put(endpoint, data: data, options: options);
      return ApiResponse(
        data: fromJson != null ? fromJson(response.data) : response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        errorMessage: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    T Function(dynamic data)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(endpoint, options: options);
      return ApiResponse(
        data: fromJson != null ? fromJson(response.data) : response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        errorMessage: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse({this.data, this.errorMessage, this.statusCode});
}
