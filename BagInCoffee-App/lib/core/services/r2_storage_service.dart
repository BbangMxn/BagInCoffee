import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constants/env.dart';

/// Cloudflare R2 Storage 서비스
class R2StorageService {
  static final R2StorageService _instance = R2StorageService._internal();
  factory R2StorageService() => _instance;
  R2StorageService._internal();

  /// 파일 업로드
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    String folder = 'posts',
  }) async {
    final key = '$folder/$fileName';

    final now = DateTime.now().toUtc();
    final dateStamp = DateFormat('yyyyMMdd').format(now);
    final amzDate = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(now);

    // AWS Signature Version 4
    final hashedPayload = sha256.convert(bytes).toString();

    // Cloudflare R2는 region을 'auto'로 사용
    final host = Uri.parse(Env.r2Endpoint).host;
    final canonicalUri = '/${Env.r2BucketName}/$key';

    final canonicalHeaders = <String, String>{
      'content-type': contentType,
      'host': host,
      'x-amz-content-sha256': hashedPayload,
      'x-amz-date': amzDate,
    };

    final signedHeaders = canonicalHeaders.keys.toList()..sort();
    final signedHeadersStr = signedHeaders.join(';');

    final canonicalHeadersStr = signedHeaders
        .map((key) => '$key:${canonicalHeaders[key]}')
        .join('\n');

    final canonicalRequest =
        'PUT\n'
        '$canonicalUri\n'
        '\n' // query string
        '$canonicalHeadersStr\n'
        '\n'
        '$signedHeadersStr\n'
        '$hashedPayload';

    final credentialScope = '$dateStamp/auto/s3/aws4_request';
    final hashedCanonicalRequest = sha256
        .convert(utf8.encode(canonicalRequest))
        .toString();

    final stringToSign =
        'AWS4-HMAC-SHA256\n'
        '$amzDate\n'
        '$credentialScope\n'
        '$hashedCanonicalRequest';

    final signature = _calculateSignature(
      secretKey: Env.r2SecretAccessKey,
      dateStamp: dateStamp,
      stringToSign: stringToSign,
    );

    final authorization =
        'AWS4-HMAC-SHA256 '
        'Credential=${Env.r2AccessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeadersStr, '
        'Signature=$signature';

    final url = '${Env.r2Endpoint}$canonicalUri';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': authorization,
        'Content-Type': contentType,
        'Host': host,
        'x-amz-content-sha256': hashedPayload,
        'x-amz-date': amzDate,
      },
      body: bytes,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('R2 업로드 실패: ${response.statusCode} - ${response.body}');
    }

    // Public URL 반환
    return '${Env.r2PublicUrl}/$key';
  }

  String _calculateSignature({
    required String secretKey,
    required String dateStamp,
    required String stringToSign,
  }) {
    final kDate = _hmacSha256('AWS4$secretKey', dateStamp);
    final kRegion = _hmacSha256String(kDate, 'auto');
    final kService = _hmacSha256String(kRegion, 's3');
    final kSigning = _hmacSha256String(kService, 'aws4_request');
    final signature = _hmacSha256String(kSigning, stringToSign);

    return signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  List<int> _hmacSha256(String key, String data) {
    final hmac = Hmac(sha256, utf8.encode(key));
    return hmac.convert(utf8.encode(data)).bytes;
  }

  List<int> _hmacSha256String(List<int> key, String data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(data)).bytes;
  }

  /// 파일 삭제
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Public URL에서 key 추출
      final uri = Uri.parse(fileUrl);
      final key = uri.path.substring(1); // 앞의 / 제거

      final now = DateTime.now().toUtc();
      final dateStamp = DateFormat('yyyyMMdd').format(now);
      final amzDate = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(now);

      final host = Uri.parse(Env.r2Endpoint).host;
      final canonicalUri = '/${Env.r2BucketName}/$key';

      final canonicalHeaders = <String, String>{
        'host': host,
        'x-amz-date': amzDate,
      };

      final signedHeaders = canonicalHeaders.keys.toList()..sort();
      final signedHeadersStr = signedHeaders.join(';');

      final canonicalHeadersStr = signedHeaders
          .map((key) => '$key:${canonicalHeaders[key]}')
          .join('\n');

      final canonicalRequest =
          'DELETE\n'
          '$canonicalUri\n'
          '\n'
          '$canonicalHeadersStr\n'
          '\n'
          '$signedHeadersStr\n'
          'UNSIGNED-PAYLOAD';

      final credentialScope = '$dateStamp/auto/s3/aws4_request';
      final hashedCanonicalRequest = sha256
          .convert(utf8.encode(canonicalRequest))
          .toString();

      final stringToSign =
          'AWS4-HMAC-SHA256\n'
          '$amzDate\n'
          '$credentialScope\n'
          '$hashedCanonicalRequest';

      final signature = _calculateSignature(
        secretKey: Env.r2SecretAccessKey,
        dateStamp: dateStamp,
        stringToSign: stringToSign,
      );

      final authorization =
          'AWS4-HMAC-SHA256 '
          'Credential=${Env.r2AccessKeyId}/$credentialScope, '
          'SignedHeaders=$signedHeadersStr, '
          'Signature=$signature';

      final url = '${Env.r2Endpoint}$canonicalUri';

      await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': authorization,
          'Host': host,
          'x-amz-date': amzDate,
        },
      );
    } catch (e) {
      // 삭제 실패는 조용히 무시 (이미 삭제되었거나 존재하지 않을 수 있음)
    }
  }
}

/// Global instance
final r2Storage = R2StorageService();
