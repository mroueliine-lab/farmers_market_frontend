import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

class FakeDio extends Fake implements Dio {
  final Map<String, dynamic> _getResponses = {};
  final Map<String, dynamic> _postResponses = {};
  final Map<String, Exception> _getErrors = {};
  final Map<String, Exception> _postErrors = {};

  final _interceptors = Interceptors();

  @override
  Interceptors get interceptors => _interceptors;

  void onGet(String path, Map<String, dynamic> data) =>
      _getResponses[path] = data;

  void onPost(String path, Map<String, dynamic> data) =>
      _postResponses[path] = data;

  void onGetThrow(String path, Exception error) => _getErrors[path] = error;

  void onPostThrow(String path, Exception error) => _postErrors[path] = error;

  Response<T> _makeResponse<T>(String path, dynamic data) => Response<T>(
        data: data as T,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (_getErrors.containsKey(path)) throw _getErrors[path]!;
    if (_getResponses.containsKey(path)) {
      return _makeResponse<T>(path, _getResponses[path]);
    }
    throw UnimplementedError('No GET stub for $path');
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (_postErrors.containsKey(path)) throw _postErrors[path]!;
    if (_postResponses.containsKey(path)) {
      return _makeResponse<T>(path, _postResponses[path]);
    }
    throw UnimplementedError('No POST stub for $path');
  }
}

DioException fakeDioException(String path, int statusCode) => DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        statusCode: statusCode,
        requestOptions: RequestOptions(path: path),
      ),
      type: DioExceptionType.badResponse,
    );
