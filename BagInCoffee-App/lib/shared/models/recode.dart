/// 추출 방법
enum BrewMethod {
  espresso,
  pourOver,
  aeropress,
  frenchPress,
  mokaPot,
  coldBrew,
  siphon,
  dripMachine,
  other;

  factory BrewMethod.fromString(String value) {
    switch (value) {
      case 'espresso':
        return BrewMethod.espresso;
      case 'pour_over':
        return BrewMethod.pourOver;
      case 'aeropress':
        return BrewMethod.aeropress;
      case 'french_press':
        return BrewMethod.frenchPress;
      case 'moka_pot':
        return BrewMethod.mokaPot;
      case 'cold_brew':
        return BrewMethod.coldBrew;
      case 'siphon':
        return BrewMethod.siphon;
      case 'drip_machine':
        return BrewMethod.dripMachine;
      default:
        return BrewMethod.other;
    }
  }

  String toJson() {
    switch (this) {
      case BrewMethod.espresso:
        return 'espresso';
      case BrewMethod.pourOver:
        return 'pour_over';
      case BrewMethod.aeropress:
        return 'aeropress';
      case BrewMethod.frenchPress:
        return 'french_press';
      case BrewMethod.mokaPot:
        return 'moka_pot';
      case BrewMethod.coldBrew:
        return 'cold_brew';
      case BrewMethod.siphon:
        return 'siphon';
      case BrewMethod.dripMachine:
        return 'drip_machine';
      case BrewMethod.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case BrewMethod.espresso:
        return '에스프레소';
      case BrewMethod.pourOver:
        return '핸드드립';
      case BrewMethod.aeropress:
        return '에어로프레스';
      case BrewMethod.frenchPress:
        return '프렌치프레스';
      case BrewMethod.mokaPot:
        return '모카포트';
      case BrewMethod.coldBrew:
        return '콜드브루';
      case BrewMethod.siphon:
        return '사이폰';
      case BrewMethod.dripMachine:
        return '드립머신';
      case BrewMethod.other:
        return '기타';
    }
  }
}

/// 추출 단계
class ExtractionStep {
  final int step;
  final double? water;
  final int? time;
  final String? note;

  const ExtractionStep({required this.step, this.water, this.time, this.note});

  factory ExtractionStep.fromJson(Map<String, dynamic> json) {
    return ExtractionStep(
      step: json['step'] as int,
      water: (json['water'] as num?)?.toDouble(),
      time: json['time'] as int?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      if (water != null) 'water': water,
      if (time != null) 'time': time,
      if (note != null) 'note': note,
    };
  }
}

/// 추출 기록 (Recode)
class Recode {
  final String id;
  final String userId;
  final String brewMethod;
  final String? beanName;
  final String? roaster;
  final String? origin;
  final String? grinder;
  final String? grindSize;
  final double? dose;
  final List<ExtractionStep>? extractionSteps;
  final double? totalWater;
  final int? totalTime;
  final double? yieldAmount;
  final int? waterTemp;
  final String? memo;
  final double? rating;
  final double? acidity;
  final double? sweetness;
  final double? bitterness;
  final double? body;
  final List<String> images;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recode({
    required this.id,
    required this.userId,
    required this.brewMethod,
    this.beanName,
    this.roaster,
    this.origin,
    this.grinder,
    this.grindSize,
    this.dose,
    this.extractionSteps,
    this.totalWater,
    this.totalTime,
    this.yieldAmount,
    this.waterTemp,
    this.memo,
    this.rating,
    this.acidity,
    this.sweetness,
    this.bitterness,
    this.body,
    required this.images,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  BrewMethod get brewMethodEnum => BrewMethod.fromString(brewMethod);

  factory Recode.fromJson(Map<String, dynamic> json) {
    return Recode(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brewMethod: json['brew_method'] as String,
      beanName: json['bean_name'] as String?,
      roaster: json['roaster'] as String?,
      origin: json['origin'] as String?,
      grinder: json['grinder'] as String?,
      grindSize: json['grind_size'] as String?,
      dose: (json['dose'] as num?)?.toDouble(),
      extractionSteps: json['extraction_steps'] != null
          ? (json['extraction_steps'] as List<dynamic>)
                .map((e) => ExtractionStep.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      totalWater: (json['total_water'] as num?)?.toDouble(),
      totalTime: json['total_time'] as int?,
      yieldAmount:
          (json['yield'] as num?)?.toDouble() ??
          (json['yield_amount'] as num?)?.toDouble(),
      waterTemp: json['water_temp'] as int?,
      memo: json['memo'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      acidity: (json['acidity'] as num?)?.toDouble(),
      sweetness: (json['sweetness'] as num?)?.toDouble(),
      bitterness: (json['bitterness'] as num?)?.toDouble(),
      body: (json['body'] as num?)?.toDouble(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brew_method': brewMethod,
      'bean_name': beanName,
      'roaster': roaster,
      'origin': origin,
      'grinder': grinder,
      'grind_size': grindSize,
      'dose': dose,
      'extraction_steps': extractionSteps?.map((e) => e.toJson()).toList(),
      'total_water': totalWater,
      'total_time': totalTime,
      'yield': yieldAmount,
      'water_temp': waterTemp,
      'memo': memo,
      'rating': rating,
      'acidity': acidity,
      'sweetness': sweetness,
      'bitterness': bitterness,
      'body': body,
      'images': images,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 추출 기록 작성 DTO
class CreateRecodeDto {
  final String brewMethod;
  final String? beanName;
  final String? roaster;
  final String? origin;
  final String? grinder;
  final String? grindSize;
  final double? dose;
  final List<ExtractionStep>? extractionSteps;
  final double? totalWater;
  final int? totalTime;
  final double? yieldAmount;
  final int? waterTemp;
  final String? memo;
  final double? rating;
  final double? acidity;
  final double? sweetness;
  final double? bitterness;
  final double? body;
  final List<String>? images;

  const CreateRecodeDto({
    required this.brewMethod,
    this.beanName,
    this.roaster,
    this.origin,
    this.grinder,
    this.grindSize,
    this.dose,
    this.extractionSteps,
    this.totalWater,
    this.totalTime,
    this.yieldAmount,
    this.waterTemp,
    this.memo,
    this.rating,
    this.acidity,
    this.sweetness,
    this.bitterness,
    this.body,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'brew_method': brewMethod,
      if (beanName != null) 'bean_name': beanName,
      if (roaster != null) 'roaster': roaster,
      if (origin != null) 'origin': origin,
      if (grinder != null) 'grinder': grinder,
      if (grindSize != null) 'grind_size': grindSize,
      if (dose != null) 'dose': dose,
      if (extractionSteps != null)
        'extraction_steps': extractionSteps!.map((e) => e.toJson()).toList(),
      if (totalWater != null) 'total_water': totalWater,
      if (totalTime != null) 'total_time': totalTime,
      if (yieldAmount != null) 'yield_amount': yieldAmount,
      if (waterTemp != null) 'water_temp': waterTemp,
      if (memo != null) 'memo': memo,
      if (rating != null) 'rating': rating,
      if (acidity != null) 'acidity': acidity,
      if (sweetness != null) 'sweetness': sweetness,
      if (bitterness != null) 'bitterness': bitterness,
      if (body != null) 'body': body,
      if (images != null) 'images': images,
    };
  }
}
