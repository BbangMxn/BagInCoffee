import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';

/// 추출 방식 카테고리
enum BrewCategory {
  espresso,
  pourOver,
  immersion,
  coldBrew,
  machine,
  traditional,
  other;

  String get label {
    switch (this) {
      case BrewCategory.espresso:
        return '에스프레소';
      case BrewCategory.pourOver:
        return '푸어오버/드립';
      case BrewCategory.immersion:
        return '침출식';
      case BrewCategory.coldBrew:
        return '콜드브루';
      case BrewCategory.machine:
        return '머신';
      case BrewCategory.traditional:
        return '전통 방식';
      case BrewCategory.other:
        return '기타';
    }
  }

  IconData get icon {
    switch (this) {
      case BrewCategory.espresso:
        return LucideIcons.coffee;
      case BrewCategory.pourOver:
        return LucideIcons.droplets;
      case BrewCategory.immersion:
        return LucideIcons.clock;
      case BrewCategory.coldBrew:
        return LucideIcons.snowflake;
      case BrewCategory.machine:
        return LucideIcons.settings;
      case BrewCategory.traditional:
        return LucideIcons.flame;
      case BrewCategory.other:
        return LucideIcons.moreHorizontal;
    }
  }
}

/// 추출 방식
class BrewMethod {
  final String value;
  final String label;
  final String? subLabel;
  final BrewCategory category;
  final IconData? icon;

  const BrewMethod({
    required this.value,
    required this.label,
    this.subLabel,
    required this.category,
    this.icon,
  });

  static const List<BrewMethod> all = [
    // 에스프레소 계열
    BrewMethod(
      value: 'espresso',
      label: '에스프레소',
      subLabel: 'Espresso',
      category: BrewCategory.espresso,
    ),
    BrewMethod(
      value: 'espresso_lungo',
      label: '룽고',
      subLabel: 'Lungo',
      category: BrewCategory.espresso,
    ),
    BrewMethod(
      value: 'espresso_ristretto',
      label: '리스트레토',
      subLabel: 'Ristretto',
      category: BrewCategory.espresso,
    ),

    // 푸어오버/드립 계열
    BrewMethod(
      value: 'hario_v60',
      label: '하리오 V60',
      subLabel: 'Hario V60',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'hario_switch',
      label: '하리오 스위치',
      subLabel: 'Hario Switch',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'mugen_switch',
      label: '무겐 스위치',
      subLabel: 'Mugen Switch',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'kalita_wave',
      label: '칼리타 웨이브',
      subLabel: 'Kalita Wave',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'chemex',
      label: '케멕스',
      subLabel: 'Chemex',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'origami',
      label: '오리가미',
      subLabel: 'Origami',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'flower_dripper',
      label: '플라워 드리퍼',
      subLabel: 'Flower Dripper',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'melitta',
      label: '멜리타',
      subLabel: 'Melitta',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'kono',
      label: '코노',
      subLabel: 'Kono',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'december_dripper',
      label: '디셈버 드리퍼',
      subLabel: 'December Dripper',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'clever_dripper',
      label: '클레버 드리퍼',
      subLabel: 'Clever Dripper',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'tricolate',
      label: '트리콜레이트',
      subLabel: 'Tricolate',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'orea',
      label: '오레아',
      subLabel: 'Orea',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'april_brewer',
      label: '에이프릴 브루어',
      subLabel: 'April Brewer',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'fellow_stagg',
      label: '펠로우 스태그',
      subLabel: 'Fellow Stagg',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'timemore_crystal',
      label: '타임모어 크리스탈',
      subLabel: 'Timemore Crystal Eye',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'nel_drip',
      label: '넬 드립',
      subLabel: 'Nel Drip',
      category: BrewCategory.pourOver,
    ),
    BrewMethod(
      value: 'pour_over',
      label: '기타 드리퍼',
      subLabel: 'Other Pour Over',
      category: BrewCategory.pourOver,
    ),

    // 침출식
    BrewMethod(
      value: 'french_press',
      label: '프렌치프레스',
      subLabel: 'French Press',
      category: BrewCategory.immersion,
    ),
    BrewMethod(
      value: 'aeropress',
      label: '에어로프레스',
      subLabel: 'AeroPress',
      category: BrewCategory.immersion,
    ),
    BrewMethod(
      value: 'delter_press',
      label: '델터 프레스',
      subLabel: 'Delter Press',
      category: BrewCategory.immersion,
    ),
    BrewMethod(
      value: 'siphon',
      label: '사이펀',
      subLabel: 'Siphon / Vacuum',
      category: BrewCategory.immersion,
    ),
    BrewMethod(
      value: 'cupping',
      label: '커핑',
      subLabel: 'Cupping',
      category: BrewCategory.immersion,
    ),
    BrewMethod(
      value: 'steep_release',
      label: '스팁 앤 릴리즈',
      subLabel: 'Steep & Release',
      category: BrewCategory.immersion,
    ),

    // 콜드브루
    BrewMethod(
      value: 'cold_brew',
      label: '콜드브루',
      subLabel: 'Cold Brew',
      category: BrewCategory.coldBrew,
    ),
    BrewMethod(
      value: 'cold_drip',
      label: '더치커피',
      subLabel: 'Cold Drip / Dutch',
      category: BrewCategory.coldBrew,
    ),
    BrewMethod(
      value: 'japanese_iced',
      label: '재패니즈 아이스',
      subLabel: 'Japanese Iced Coffee',
      category: BrewCategory.coldBrew,
    ),
    BrewMethod(
      value: 'flash_brew',
      label: '플래시 브루',
      subLabel: 'Flash Brew',
      category: BrewCategory.coldBrew,
    ),

    // 머신
    BrewMethod(
      value: 'drip_machine',
      label: '드립 머신',
      subLabel: 'Drip Machine',
      category: BrewCategory.machine,
    ),
    BrewMethod(
      value: 'automatic_espresso',
      label: '전자동 에스프레소',
      subLabel: 'Automatic Espresso',
      category: BrewCategory.machine,
    ),

    // 전통 방식
    BrewMethod(
      value: 'moka_pot',
      label: '모카포트',
      subLabel: 'Moka Pot',
      category: BrewCategory.traditional,
    ),
    BrewMethod(
      value: 'bialetti',
      label: '비알레티',
      subLabel: 'Bialetti',
      category: BrewCategory.traditional,
    ),
    BrewMethod(
      value: 'turkish',
      label: '터키쉬 커피',
      subLabel: 'Turkish Coffee',
      category: BrewCategory.traditional,
    ),
    BrewMethod(
      value: 'ibrik',
      label: '이브릭',
      subLabel: 'Ibrik',
      category: BrewCategory.traditional,
    ),
    BrewMethod(
      value: 'cezve',
      label: '체즈베',
      subLabel: 'Cezve',
      category: BrewCategory.traditional,
    ),
    BrewMethod(
      value: 'vietnamese_phin',
      label: '베트남 핀',
      subLabel: 'Vietnamese Phin',
      category: BrewCategory.traditional,
    ),
    BrewMethod(
      value: 'percolator',
      label: '퍼콜레이터',
      subLabel: 'Percolator',
      category: BrewCategory.traditional,
    ),

    // 기타
    BrewMethod(
      value: 'other',
      label: '기타',
      subLabel: 'Other',
      category: BrewCategory.other,
    ),
  ];

  /// value로 BrewMethod 찾기
  static BrewMethod? fromValue(String value) {
    try {
      return all.firstWhere((m) => m.value == value);
    } catch (_) {
      return null;
    }
  }

  /// 카테고리별로 그룹화
  static Map<BrewCategory, List<BrewMethod>> get grouped {
    final map = <BrewCategory, List<BrewMethod>>{};
    for (final method in all) {
      map.putIfAbsent(method.category, () => []).add(method);
    }
    return map;
  }
}
