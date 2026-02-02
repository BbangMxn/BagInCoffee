import 'package:flutter/material.dart';

/// 원두 품종 카테고리 (상위 4개)
enum BeanCategory {
  arabica,
  robusta,
  liberica,
  excelsa;

  String get label {
    switch (this) {
      case BeanCategory.arabica:
        return '아라비카';
      case BeanCategory.robusta:
        return '로부스타';
      case BeanCategory.liberica:
        return '리베리카';
      case BeanCategory.excelsa:
        return '엑셀사';
    }
  }

  String get englishName {
    switch (this) {
      case BeanCategory.arabica:
        return 'Arabica';
      case BeanCategory.robusta:
        return 'Robusta';
      case BeanCategory.liberica:
        return 'Liberica';
      case BeanCategory.excelsa:
        return 'Excelsa';
    }
  }

  String get description {
    switch (this) {
      case BeanCategory.arabica:
        return '부드럽고 복합적인 풍미, 세계 생산량 60-70%';
      case BeanCategory.robusta:
        return '강렬하고 쓴맛, 카페인 함량 높음';
      case BeanCategory.liberica:
        return '독특한 향, 희귀 품종';
      case BeanCategory.excelsa:
        return '과일향과 신맛, 동남아 생산';
    }
  }

  Color get color {
    switch (this) {
      case BeanCategory.arabica:
        return const Color(0xFF8B4513);
      case BeanCategory.robusta:
        return const Color(0xFF654321);
      case BeanCategory.liberica:
        return const Color(0xFFA0522D);
      case BeanCategory.excelsa:
        return const Color(0xFFD2691E);
    }
  }
}

/// 원두 품종 (하위 품종 포함)
class BeanVariety {
  final String value;
  final String label;
  final String? englishName;
  final BeanCategory category;
  final String? description;

  const BeanVariety({
    required this.value,
    required this.label,
    this.englishName,
    required this.category,
    this.description,
  });

  static const List<BeanVariety> all = [
    // 아라비카 품종들
    BeanVariety(
      value: 'typica',
      label: '티피카',
      englishName: 'Typica',
      category: BeanCategory.arabica,
      description: '아라비카의 원종, 깔끔하고 밸런스 좋음',
    ),
    BeanVariety(
      value: 'bourbon',
      label: '버본',
      englishName: 'Bourbon',
      category: BeanCategory.arabica,
      description: '달콤하고 복합적인 풍미',
    ),
    BeanVariety(
      value: 'geisha',
      label: '게이샤',
      englishName: 'Geisha/Gesha',
      category: BeanCategory.arabica,
      description: '플로럴, 재스민, 베르가못 향',
    ),
    BeanVariety(
      value: 'caturra',
      label: '카투라',
      englishName: 'Caturra',
      category: BeanCategory.arabica,
      description: '버본 돌연변이, 밝은 산미',
    ),
    BeanVariety(
      value: 'catuai',
      label: '카투아이',
      englishName: 'Catuai',
      category: BeanCategory.arabica,
      description: '카투라×문도노보 교배종',
    ),
    BeanVariety(
      value: 'sl28',
      label: 'SL28',
      englishName: 'SL28',
      category: BeanCategory.arabica,
      description: '케냐 대표 품종, 강한 과일 산미',
    ),
    BeanVariety(
      value: 'sl34',
      label: 'SL34',
      englishName: 'SL34',
      category: BeanCategory.arabica,
      description: '케냐 품종, SL28보다 부드러움',
    ),
    BeanVariety(
      value: 'pacamara',
      label: '파카마라',
      englishName: 'Pacamara',
      category: BeanCategory.arabica,
      description: '파카스×마라고지페 교배, 큰 원두',
    ),
    BeanVariety(
      value: 'maragogype',
      label: '마라고지페',
      englishName: 'Maragogype',
      category: BeanCategory.arabica,
      description: '티피카 돌연변이, 코끼리 원두',
    ),
    BeanVariety(
      value: 'mundo_novo',
      label: '문도노보',
      englishName: 'Mundo Novo',
      category: BeanCategory.arabica,
      description: '티피카×버본 자연 교배종',
    ),
    BeanVariety(
      value: 'yellow_bourbon',
      label: '옐로우 버본',
      englishName: 'Yellow Bourbon',
      category: BeanCategory.arabica,
      description: '노란 체리, 달콤한 풍미',
    ),
    BeanVariety(
      value: 'pink_bourbon',
      label: '핑크 버본',
      englishName: 'Pink Bourbon',
      category: BeanCategory.arabica,
      description: '분홍 체리, 플로럴하고 복합적',
    ),
    BeanVariety(
      value: 'villa_sarchi',
      label: '빌라 사르치',
      englishName: 'Villa Sarchi',
      category: BeanCategory.arabica,
      description: '버본 돌연변이, 코스타리카',
    ),
    BeanVariety(
      value: 'java',
      label: '자바',
      englishName: 'Java',
      category: BeanCategory.arabica,
      description: '에티오피아 원산, 허브향',
    ),
    BeanVariety(
      value: 'heirloom',
      label: '헤어룸',
      englishName: 'Heirloom',
      category: BeanCategory.arabica,
      description: '에티오피아 토착 품종 총칭',
    ),
    BeanVariety(
      value: 'castillo',
      label: '카스티요',
      englishName: 'Castillo',
      category: BeanCategory.arabica,
      description: '콜롬비아 개발, 녹병 저항성',
    ),
    BeanVariety(
      value: 'colombia',
      label: '콜롬비아',
      englishName: 'Colombia',
      category: BeanCategory.arabica,
      description: '카투라×티모르 교배종',
    ),
    BeanVariety(
      value: 'tabi',
      label: '타비',
      englishName: 'Tabi',
      category: BeanCategory.arabica,
      description: '티피카×버본×티모르 교배',
    ),
    BeanVariety(
      value: 'sidra',
      label: '시드라',
      englishName: 'Sidra',
      category: BeanCategory.arabica,
      description: '티피카×버본 에콰도르 품종',
    ),
    BeanVariety(
      value: 'wush_wush',
      label: '우시 우시',
      englishName: 'Wush Wush',
      category: BeanCategory.arabica,
      description: '에티오피아 토착, 플로럴',
    ),
    BeanVariety(
      value: 'arabica_other',
      label: '기타 아라비카',
      englishName: 'Other Arabica',
      category: BeanCategory.arabica,
    ),

    // 로부스타 품종들
    BeanVariety(
      value: 'robusta_standard',
      label: '로부스타 스탠다드',
      englishName: 'Robusta Standard',
      category: BeanCategory.robusta,
      description: '일반 로부스타, 강한 쓴맛',
    ),
    BeanVariety(
      value: 'fine_robusta',
      label: '파인 로부스타',
      englishName: 'Fine Robusta',
      category: BeanCategory.robusta,
      description: '고품질 로부스타, 밸런스 좋음',
    ),
    BeanVariety(
      value: 'robusta_other',
      label: '기타 로부스타',
      englishName: 'Other Robusta',
      category: BeanCategory.robusta,
    ),

    // 리베리카 품종들
    BeanVariety(
      value: 'liberica_standard',
      label: '리베리카 스탠다드',
      englishName: 'Liberica Standard',
      category: BeanCategory.liberica,
      description: '독특한 우디, 스모키 향',
    ),
    BeanVariety(
      value: 'barako',
      label: '바라코',
      englishName: 'Barako',
      category: BeanCategory.liberica,
      description: '필리핀 리베리카, 강렬한 향',
    ),
    BeanVariety(
      value: 'liberica_other',
      label: '기타 리베리카',
      englishName: 'Other Liberica',
      category: BeanCategory.liberica,
    ),

    // 엑셀사 품종들
    BeanVariety(
      value: 'excelsa_standard',
      label: '엑셀사 스탠다드',
      englishName: 'Excelsa Standard',
      category: BeanCategory.excelsa,
      description: '과일향, 타르트한 산미',
    ),
    BeanVariety(
      value: 'excelsa_other',
      label: '기타 엑셀사',
      englishName: 'Other Excelsa',
      category: BeanCategory.excelsa,
    ),
  ];

  /// value로 BeanVariety 찾기
  static BeanVariety? fromValue(String value) {
    try {
      return all.firstWhere((v) => v.value == value);
    } catch (_) {
      return null;
    }
  }

  /// 카테고리별로 그룹화
  static Map<BeanCategory, List<BeanVariety>> get grouped {
    final map = <BeanCategory, List<BeanVariety>>{};
    for (final variety in all) {
      map.putIfAbsent(variety.category, () => []).add(variety);
    }
    return map;
  }

  /// 카테고리별 품종 수
  static Map<BeanCategory, int> get countByCategory {
    final grouped = BeanVariety.grouped;
    return {
      for (final category in BeanCategory.values)
        category: grouped[category]?.length ?? 0,
    };
  }
}
