import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경변수 관리
class Env {
  Env._();

  /// API URLs
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get baginDbApiUrl => dotenv.env['BAGINDB_API_URL'] ?? '';

  /// Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Cloudflare R2
  static String get r2AccountId => dotenv.env['R2_ACCOUNT_ID'] ?? '';
  static String get r2AccessKeyId => dotenv.env['R2_ACCESS_KEY_ID'] ?? '';
  static String get r2SecretAccessKey =>
      dotenv.env['R2_SECRET_ACCESS_KEY'] ?? '';
  static String get r2Endpoint => dotenv.env['R2_ENDPOINT'] ?? '';
  static String get r2BucketName => dotenv.env['R2_BUCKET_NAME'] ?? '';
  static String get r2PublicUrl => dotenv.env['R2_PUBLIC_URL'] ?? '';
}
