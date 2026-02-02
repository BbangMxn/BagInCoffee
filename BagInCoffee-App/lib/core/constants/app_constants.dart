/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  // 앱 정보
  static const String appName = 'BagIn Coffee';
  static const String appVersion = '1.0.0';

  // Supabase Storage Buckets
  static const String profileImagesBucket = 'profile-images';
  static const String coverImagesBucket = 'cover-images';

  // 페이지네이션
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 이미지
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 85;
  static const int thumbnailSize = 200;

  // 타임아웃
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
