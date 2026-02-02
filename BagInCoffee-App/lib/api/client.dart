import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';

/// API 예외
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  ApiException({required this.message, this.code, this.statusCode});

  @override
  String toString() =>
      'ApiException: $message (code: $code, status: $statusCode)';
}

/// API 클라이언트
class ApiClient {
  static const String _mainApiUrl =
      'https://backend-production-a376.up.railway.app';
  static const String _baginDbUrl = 'https://bagindb-production.up.railway.app';

  late final Dio _mainDio;
  late final Dio _baginDbDio;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _mainDio = _createDio(_mainApiUrl);
    _baginDbDio = _createDio(_baginDbUrl);
  }

  Dio _createDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor());

    return dio;
  }

  /// 인증 토큰 가져오기
  String? get _authToken {
    try {
      return Supabase.instance.client.auth.currentSession?.accessToken;
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // Main API (BagInCoffee_B)
  // ============================================

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    try {
      final options = Options(
        headers: requiresAuth && _authToken != null
            ? {'Authorization': 'Bearer $_authToken'}
            : null,
      );

      final response = await _mainDio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        code: e.response?.data?['code'],
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final options = Options(
        headers: requiresAuth && _authToken != null
            ? {'Authorization': 'Bearer $_authToken'}
            : null,
      );

      final response = await _mainDio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        code: e.response?.data?['code'],
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final options = Options(
        headers: requiresAuth && _authToken != null
            ? {'Authorization': 'Bearer $_authToken'}
            : null,
      );

      final response = await _mainDio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        code: e.response?.data?['code'],
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final options = Options(
        headers: requiresAuth && _authToken != null
            ? {'Authorization': 'Bearer $_authToken'}
            : null,
      );

      final response = await _mainDio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        code: e.response?.data?['code'],
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ============================================
  // BagInDB API (Products, Equipment, Brands)
  // ============================================

  Future<dynamic> getBaginDb(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 BagInDB API Request: $path');
        print('📋 Query Parameters: $queryParameters');
      }

      final response = await _baginDbDio.get(
        path,
        queryParameters: queryParameters,
      );

      if (kDebugMode) print('✅ BagInDB API Response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ BagInDB API Error: ${e.message}');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
      }

      throw ApiException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        code: e.response?.data?['code'],
        statusCode: e.response?.statusCode,
      );
    }
  }
}

/// 인증 인터셉터
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Authorization 헤더가 이미 설정되어 있지 않으면 자동 주입
    if (options.headers['Authorization'] == null) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
      } catch (_) {
        // Supabase 초기화 안됐을 때 무시
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 에러 로깅
    if (err.response?.statusCode == 401) {
      // TODO: 토큰 갱신 또는 로그아웃 처리
    }
    handler.next(err);
  }
}
