import 'package:dio/dio.dart';
import '../config/app_config.dart';

class DioClient {
    static Dio create() {
        final dio = Dio(BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
            },
        ));

        if (AppConfig.isDebug) {
            dio.interceptors.add(LogInterceptor(
                requestBody: true,
                responseBody: true,
                requestHeader: false,
                responseHeader: false,
                error: true,
            ));
        }

        return dio;
    }
}