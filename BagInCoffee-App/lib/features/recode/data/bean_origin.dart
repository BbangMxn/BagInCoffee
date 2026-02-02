import 'package:flutter/material.dart';

/// 커피 재배 지역 (대륙별)
enum CoffeeRegion {
  africa,
  centralAmerica,
  southAmerica,
  asia,
  oceania;

  String get label {
    switch (this) {
      case CoffeeRegion.africa:
        return '아프리카';
      case CoffeeRegion.centralAmerica:
        return '중미';
      case CoffeeRegion.southAmerica:
        return '남미';
      case CoffeeRegion.asia:
        return '아시아';
      case CoffeeRegion.oceania:
        return '오세아니아';
    }
  }

  IconData get icon {
    switch (this) {
      case CoffeeRegion.africa:
        return Icons.public;
      case CoffeeRegion.centralAmerica:
        return Icons.terrain;
      case CoffeeRegion.southAmerica:
        return Icons.landscape;
      case CoffeeRegion.asia:
        return Icons.temple_buddhist;
      case CoffeeRegion.oceania:
        return Icons.beach_access;
    }
  }
}

/// 커피 원산지 (나라)
class BeanOrigin {
  final String code; // ISO 3166-1 alpha-2
  final String nameKo;
  final String nameEn;
  final CoffeeRegion region;
  final String? description;
  final bool popular; // 인기 있는 원산지

  const BeanOrigin({
    required this.code,
    required this.nameKo,
    required this.nameEn,
    required this.region,
    this.description,
    this.popular = false,
  });

  /// 전체 원산지 목록
  static const List<BeanOrigin> all = [
    // 아프리카
    BeanOrigin(
      code: 'ET',
      nameKo: '에티오피아',
      nameEn: 'Ethiopia',
      region: CoffeeRegion.africa,
      description: '커피의 발상지, 과일향과 플로럴',
      popular: true,
    ),
    BeanOrigin(
      code: 'KE',
      nameKo: '케냐',
      nameEn: 'Kenya',
      region: CoffeeRegion.africa,
      description: '강한 산미, 블랙커런트, SL28/SL34',
      popular: true,
    ),
    BeanOrigin(
      code: 'RW',
      nameKo: '르완다',
      nameEn: 'Rwanda',
      region: CoffeeRegion.africa,
      description: '밝은 산미, 과일향',
      popular: false,
    ),
    BeanOrigin(
      code: 'BI',
      nameKo: '부룬디',
      nameEn: 'Burundi',
      region: CoffeeRegion.africa,
      description: '복합적인 과일향',
      popular: false,
    ),
    BeanOrigin(
      code: 'TZ',
      nameKo: '탄자니아',
      nameEn: 'Tanzania',
      region: CoffeeRegion.africa,
      description: '케냐와 유사, 부드러운 산미',
      popular: false,
    ),
    BeanOrigin(
      code: 'UG',
      nameKo: '우간다',
      nameEn: 'Uganda',
      region: CoffeeRegion.africa,
      description: '로부스타 주산지, 아라비카도 생산',
      popular: false,
    ),

    // 중미
    BeanOrigin(
      code: 'GT',
      nameKo: '과테말라',
      nameEn: 'Guatemala',
      region: CoffeeRegion.centralAmerica,
      description: '초콜릿, 견과류, 밸런스',
      popular: true,
    ),
    BeanOrigin(
      code: 'CR',
      nameKo: '코스타리카',
      nameEn: 'Costa Rica',
      region: CoffeeRegion.centralAmerica,
      description: '깔끔한 산미, 허니 프로세스',
      popular: true,
    ),
    BeanOrigin(
      code: 'PA',
      nameKo: '파나마',
      nameEn: 'Panama',
      region: CoffeeRegion.centralAmerica,
      description: '게이샤 원산지, 플로럴',
      popular: true,
    ),
    BeanOrigin(
      code: 'HN',
      nameKo: '온두라스',
      nameEn: 'Honduras',
      region: CoffeeRegion.centralAmerica,
      description: '밸런스 좋은 중미 커피',
      popular: false,
    ),
    BeanOrigin(
      code: 'NI',
      nameKo: '니카라과',
      nameEn: 'Nicaragua',
      region: CoffeeRegion.centralAmerica,
      description: '초콜릿, 캐러멜',
      popular: false,
    ),
    BeanOrigin(
      code: 'SV',
      nameKo: '엘살바도르',
      nameEn: 'El Salvador',
      region: CoffeeRegion.centralAmerica,
      description: '부드러운 산미, 단맛',
      popular: false,
    ),
    BeanOrigin(
      code: 'MX',
      nameKo: '멕시코',
      nameEn: 'Mexico',
      region: CoffeeRegion.centralAmerica,
      description: '가벼운 바디, 견과류',
      popular: false,
    ),
    BeanOrigin(
      code: 'JM',
      nameKo: '자메이카',
      nameEn: 'Jamaica',
      region: CoffeeRegion.centralAmerica,
      description: '블루마운틴, 부드럽고 밸런스',
      popular: false,
    ),

    // 남미
    BeanOrigin(
      code: 'CO',
      nameKo: '콜롬비아',
      nameEn: 'Colombia',
      region: CoffeeRegion.southAmerica,
      description: '밸런스, 캐러멜, 견과류',
      popular: true,
    ),
    BeanOrigin(
      code: 'BR',
      nameKo: '브라질',
      nameEn: 'Brazil',
      region: CoffeeRegion.southAmerica,
      description: '세계 최대 생산국, 초콜릿, 견과류',
      popular: true,
    ),
    BeanOrigin(
      code: 'PE',
      nameKo: '페루',
      nameEn: 'Peru',
      region: CoffeeRegion.southAmerica,
      description: '유기농 커피, 밝은 산미',
      popular: false,
    ),
    BeanOrigin(
      code: 'EC',
      nameKo: '에콰도르',
      nameEn: 'Ecuador',
      region: CoffeeRegion.southAmerica,
      description: '시드라 품종, 복합적',
      popular: false,
    ),
    BeanOrigin(
      code: 'BO',
      nameKo: '볼리비아',
      nameEn: 'Bolivia',
      region: CoffeeRegion.southAmerica,
      description: '고지대 재배, 깔끔한 산미',
      popular: false,
    ),

    // 아시아
    BeanOrigin(
      code: 'ID',
      nameKo: '인도네시아',
      nameEn: 'Indonesia',
      region: CoffeeRegion.asia,
      description: '만델링, 어시, 풀바디',
      popular: true,
    ),
    BeanOrigin(
      code: 'VN',
      nameKo: '베트남',
      nameEn: 'Vietnam',
      region: CoffeeRegion.asia,
      description: '로부스타 주산지, 2위 생산국',
      popular: false,
    ),
    BeanOrigin(
      code: 'TH',
      nameKo: '태국',
      nameEn: 'Thailand',
      region: CoffeeRegion.asia,
      description: '북부 고산지 아라비카',
      popular: false,
    ),
    BeanOrigin(
      code: 'LA',
      nameKo: '라오스',
      nameEn: 'Laos',
      region: CoffeeRegion.asia,
      description: '로부스타, 아라비카',
      popular: false,
    ),
    BeanOrigin(
      code: 'MM',
      nameKo: '미얀마',
      nameEn: 'Myanmar',
      region: CoffeeRegion.asia,
      description: '신흥 커피 산지',
      popular: false,
    ),
    BeanOrigin(
      code: 'IN',
      nameKo: '인도',
      nameEn: 'India',
      region: CoffeeRegion.asia,
      description: '몬순 프로세스, 스파이시',
      popular: false,
    ),
    BeanOrigin(
      code: 'YE',
      nameKo: '예멘',
      nameEn: 'Yemen',
      region: CoffeeRegion.asia,
      description: '모카 항, 와인같은 풍미',
      popular: true,
    ),

    // 오세아니아
    BeanOrigin(
      code: 'PG',
      nameKo: '파푸아뉴기니',
      nameEn: 'Papua New Guinea',
      region: CoffeeRegion.oceania,
      description: '과일향, 복합적',
      popular: false,
    ),
    BeanOrigin(
      code: 'AU',
      nameKo: '호주',
      nameEn: 'Australia',
      region: CoffeeRegion.oceania,
      description: '소량 생산, 특별한 품종',
      popular: false,
    ),
    BeanOrigin(
      code: 'HI',
      nameKo: '하와이',
      nameEn: 'Hawaii (USA)',
      region: CoffeeRegion.oceania,
      description: '코나 커피, 부드럽고 밸런스',
      popular: true,
    ),
  ];

  /// 인기 원산지만
  static List<BeanOrigin> get popularOrigins {
    return all.where((origin) => origin.popular).toList();
  }

  /// 지역별로 그룹화
  static Map<CoffeeRegion, List<BeanOrigin>> get grouped {
    final map = <CoffeeRegion, List<BeanOrigin>>{};
    for (final origin in all) {
      map.putIfAbsent(origin.region, () => []).add(origin);
    }
    return map;
  }

  /// code로 찾기
  static BeanOrigin? fromCode(String code) {
    try {
      return all.firstWhere((o) => o.code == code);
    } catch (_) {
      return null;
    }
  }

  /// 검색
  static List<BeanOrigin> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((origin) {
      return origin.nameKo.toLowerCase().contains(lowerQuery) ||
          origin.nameEn.toLowerCase().contains(lowerQuery) ||
          origin.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
