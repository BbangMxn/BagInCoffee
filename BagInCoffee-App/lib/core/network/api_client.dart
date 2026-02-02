import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/env.dart';
import '../constants/app_constants.dart';

/// API 클라이언트 (Dio 기반)
class ApiClient {
  late final Dio _dio;
  late final Dio _baginDbDio;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = _createDio(Env.apiBaseUrl);
    _baginDbDio = _createDio(Env.baginDbApiUrl);
  }

  Dio _createDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 추가
    dio.interceptors.addAll([_AuthInterceptor(), _LoggingInterceptor()]);

    return dio;
  }

  /// Main API Dio 인스턴스
  Dio get dio => _dio;

  /// BagInDB API Dio 인스턴스
  Dio get baginDbDio => _baginDbDio;

  // ============================================
  // Main API Methods
  // ============================================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ============================================
  // BagInDB API Methods
  // ============================================

  Future<Response<T>> getBaginDb<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _baginDbDio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// 인증 인터셉터 - Supabase JWT 토큰 자동 주입
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 에러 시 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      // TODO: 토큰 갱신 로직
    }
    handler.next(err);
  }
}

/// 로깅 인터셉터
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────');
      print('│ [REQUEST] ${options.method} ${options.uri}');
      if (options.data != null) {
        print('│ Body: ${options.data}');
      }
      print('└─────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────');
      print(
        '│ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}',
      );
      print('└─────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────');
      print('│ [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}');
      print('│ Message: ${err.message}');
      print('└─────────────────────────────────────────────');
    }
    handler.next(err);
  }
}
