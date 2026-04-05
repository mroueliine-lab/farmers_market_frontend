import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'network/dio_client.dart';
import 'network/auth_interceptor.dart';
import 'storage/secure_storage_service.dart';

final storageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.create();
  final storage = ref.read(storageProvider);
  dio.interceptors.add(AuthInterceptor(storage));
  return dio;
});
