import 'package:dio/dio.dart';

/// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(message: '연결 시간이 초과되었습니다.', statusCode: null);
      case DioExceptionType.sendTimeout:
        return ApiException(message: '요청 전송 시간이 초과되었습니다.', statusCode: null);
      case DioExceptionType.receiveTimeout:
        return ApiException(message: '응답 대기 시간이 초과되었습니다.', statusCode: null);
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
        return ApiException(message: '요청이 취소되었습니다.', statusCode: null);
      case DioExceptionType.connectionError:
        return ApiException(message: '네트워크 연결을 확인해주세요.', statusCode: null);
      default:
        return ApiException(message: '알 수 없는 오류가 발생했습니다.', statusCode: null);
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message;
    switch (statusCode) {
      case 400:
        message = data?['message'] ?? '잘못된 요청입니다.';
        break;
      case 401:
        message = '인증이 필요합니다. 다시 로그인해주세요.';
        break;
      case 403:
        message = '접근 권한이 없습니다.';
        break;
      case 404:
        message = '요청한 정보를 찾을 수 없습니다.';
        break;
      case 409:
        message = data?['message'] ?? '중복된 데이터입니다.';
        break;
      case 422:
        message = data?['message'] ?? '입력 데이터를 확인해주세요.';
        break;
      case 500:
        message = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        break;
      case 502:
      case 503:
      case 504:
        message = '서버가 일시적으로 응답하지 않습니다.';
        break;
      default:
        message = data?['message'] ?? '오류가 발생했습니다.';
    }

    return ApiException(message: message, statusCode: statusCode, data: data);
  }

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
