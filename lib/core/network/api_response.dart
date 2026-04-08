import 'package:dio/dio.dart';

class ApiResponse {
  static Map<String, dynamic> object(Response response) =>
      response.data['data'] as Map<String, dynamic>;

  static List<dynamic> list(Response response) =>
      response.data['data'] as List;

  static Map<String, dynamic> raw(Response response) =>
      response.data as Map<String, dynamic>;
}
