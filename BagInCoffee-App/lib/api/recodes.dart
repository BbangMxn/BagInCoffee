import 'client.dart';

/// 추출 단계
class ExtractionStep {
  final int step;
  final double? water; // 백엔드: Option<f64>
  final int? time; // 백엔드: Option<i32>
  final String? note;

  ExtractionStep({required this.step, this.water, this.time, this.note});

  factory ExtractionStep.fromJson(Map<String, dynamic> json) {
    return ExtractionStep(
      step: _parseInt(json['step']) ?? 0,
      water: _parseDouble(json['water']),
      time: _parseInt(json['time']),
      note: json['note'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'step': step,
    if (water != null) 'water': water,
    if (time != null) 'time': time,
    if (note != null) 'note': note,
  };
}

/// 추출 기록 모델
class Recode {
  final String id;
  final String userId;
  final String brewMethod;
  final String? beanName;
  final String? roaster;
  final String? origin;
  final String? grindSize;
  final String? grinder;
  final double? dose;
  final List<ExtractionStep> extractionSteps;
  final double? totalWater;
  final int? totalTime;
  final double? yield_;
  final int? waterTemp;
  final String? memo;
  final double? rating;
  final double? acidity;
  final double? sweetness;
  final double? bitterness;
  final double? body;
  final double? aroma;
  final List<String> images;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recode({
    required this.id,
    required this.userId,
    required this.brewMethod,
    this.beanName,
    this.roaster,
    this.origin,
    this.grindSize,
    this.grinder,
    this.dose,
    required this.extractionSteps,
    this.totalWater,
    this.totalTime,
    this.yield_,
    this.waterTemp,
    this.memo,
    this.rating,
    this.acidity,
    this.sweetness,
    this.bitterness,
    this.body,
    this.aroma,
    required this.images,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recode.fromJson(Map<String, dynamic> json) {
    return Recode(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brewMethod: json['brew_method'] as String,
      beanName: json['bean_name'] as String?,
      roaster: json['roaster'] as String?,
      origin: json['origin'] as String?,
      grindSize: json['grind_size'] as String?,
      grinder: json['grinder'] as String?,
      dose: _parseDouble(json['dose']),
      extractionSteps: _parseExtractionSteps(json['extraction_steps']),
      totalWater: _parseDouble(json['total_water']),
      totalTime: _parseInt(json['total_time']),
      yield_: _parseDouble(json['yield']),
      waterTemp: _parseInt(json['water_temp']),
      memo: json['memo'] as String?,
      rating: _parseDouble(json['rating']),
      acidity: _parseDouble(json['acidity']),
      sweetness: _parseDouble(json['sweetness']),
      bitterness: _parseDouble(json['bitterness']),
      body: _parseDouble(json['body']),
      aroma: _parseDouble(json['aroma']),
      images: _parseStringList(json['images']),
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static List<ExtractionStep> _parseExtractionSteps(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .map((e) => ExtractionStep.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get brewMethodLabel {
    switch (brewMethod) {
      case 'espresso':
        return '에스프레소';
      case 'hario_v60':
        return '하리오 V60';
      case 'kalita_wave':
        return '칼리타 웨이브';
      case 'chemex':
        return '케멕스';
      case 'aeropress':
        return '에어로프레스';
      case 'french_press':
        return '프렌치프레스';
      case 'moka_pot':
        return '모카포트';
      case 'cold_brew':
        return '콜드브루';
      case 'siphon':
        return '사이펀';
      case 'pour_over':
        return '핸드드립';
      default:
        return brewMethod;
    }
  }
}

/// 추출 기록 생성 DTO
class CreateRecodeDto {
  final String brewMethod;
  final String? beanName;
  final String? roaster;
  final String? origin;
  final String? grindSize;
  final String? grinder;
  final double? dose;
  final List<ExtractionStep>? extractionSteps;
  final double? totalWater;
  final int? totalTime;
  final double? yield_;
  final int? waterTemp;
  final String? memo;
  final double? rating;
  final double? acidity;
  final double? sweetness;
  final double? bitterness;
  final double? body;
  final double? aroma;
  final List<String>? images;

  CreateRecodeDto({
    required this.brewMethod,
    this.beanName,
    this.roaster,
    this.origin,
    this.grindSize,
    this.grinder,
    this.dose,
    this.extractionSteps,
    this.totalWater,
    this.totalTime,
    this.yield_,
    this.waterTemp,
    this.memo,
    this.rating,
    this.acidity,
    this.sweetness,
    this.bitterness,
    this.body,
    this.aroma,
    this.images,
  });

  Map<String, dynamic> toJson() => {
    'brew_method': brewMethod,
    if (beanName != null) 'bean_name': beanName,
    if (roaster != null) 'roaster': roaster,
    if (origin != null) 'origin': origin,
    if (grindSize != null) 'grind_size': grindSize,
    if (grinder != null) 'grinder': grinder,
    if (dose != null) 'dose': dose,
    if (extractionSteps != null)
      'extraction_steps': extractionSteps!.map((e) => e.toJson()).toList(),
    if (totalWater != null) 'total_water': totalWater,
    if (totalTime != null) 'total_time': totalTime,
    if (yield_ != null) 'yield': yield_,
    if (waterTemp != null) 'water_temp': waterTemp,
    if (memo != null) 'memo': memo,
    if (rating != null) 'rating': rating,
    if (acidity != null) 'acidity': acidity,
    if (sweetness != null) 'sweetness': sweetness,
    if (bitterness != null) 'bitterness': bitterness,
    if (body != null) 'body': body,
    if (aroma != null) 'aroma': aroma,
    if (images != null) 'images': images,
  };
}

/// 추출 기록 수정 DTO
class UpdateRecodeDto {
  final String? brewMethod;
  final String? beanName;
  final String? roaster;
  final String? origin;
  final String? grindSize;
  final String? grinder;
  final double? dose;
  final List<ExtractionStep>? extractionSteps;
  final double? totalWater;
  final int? totalTime;
  final double? yield_;
  final int? waterTemp;
  final String? memo;
  final double? rating;
  final double? acidity;
  final double? sweetness;
  final double? bitterness;
  final double? body;
  final double? aroma;
  final List<String>? images;

  UpdateRecodeDto({
    this.brewMethod,
    this.beanName,
    this.roaster,
    this.origin,
    this.grindSize,
    this.grinder,
    this.dose,
    this.extractionSteps,
    this.totalWater,
    this.totalTime,
    this.yield_,
    this.waterTemp,
    this.memo,
    this.rating,
    this.acidity,
    this.sweetness,
    this.bitterness,
    this.body,
    this.aroma,
    this.images,
  });

  Map<String, dynamic> toJson() => {
    if (brewMethod != null) 'brew_method': brewMethod,
    if (beanName != null) 'bean_name': beanName,
    if (roaster != null) 'roaster': roaster,
    if (origin != null) 'origin': origin,
    if (grindSize != null) 'grind_size': grindSize,
    if (grinder != null) 'grinder': grinder,
    if (dose != null) 'dose': dose,
    if (extractionSteps != null)
      'extraction_steps': extractionSteps!.map((e) => e.toJson()).toList(),
    if (totalWater != null) 'total_water': totalWater,
    if (totalTime != null) 'total_time': totalTime,
    if (yield_ != null) 'yield': yield_,
    if (waterTemp != null) 'water_temp': waterTemp,
    if (memo != null) 'memo': memo,
    if (rating != null) 'rating': rating,
    if (acidity != null) 'acidity': acidity,
    if (sweetness != null) 'sweetness': sweetness,
    if (bitterness != null) 'bitterness': bitterness,
    if (body != null) 'body': body,
    if (aroma != null) 'aroma': aroma,
    if (images != null) 'images': images,
  };
}

/// Recodes API (추출 기록)
class RecodesApi {
  final ApiClient _client = ApiClient();

  /// 내 추출 기록 목록 조회
  Future<List<Recode>> list({int? page, int? limit}) async {
    final response = await _client.get(
      '/api/recodes',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      requiresAuth: true,
    );
    return (response as List).map((e) => Recode.fromJson(e)).toList();
  }

  /// 추출 기록 상세 조회
  Future<Recode> getById(String id) async {
    final response = await _client.get('/api/recodes/$id', requiresAuth: true);
    return Recode.fromJson(response);
  }

  /// 추출 기록 생성
  Future<Recode> create(CreateRecodeDto dto) async {
    final jsonData = dto.toJson();
    print('📤 [Recode Create] Request: $jsonData');
    try {
      final response = await _client.post('/api/recodes', data: jsonData);
      print('✅ [Recode Create] Success');
      return Recode.fromJson(response);
    } catch (e) {
      print('❌ [Recode Create] Error: $e');
      rethrow;
    }
  }

  /// 추출 기록 수정
  Future<Recode> update(String id, UpdateRecodeDto dto) async {
    final jsonData = dto.toJson();
    print('📤 [Recode Update] Request: $jsonData');
    try {
      final response = await _client.put('/api/recodes/$id', data: jsonData);
      print('✅ [Recode Update] Success');
      return Recode.fromJson(response);
    } catch (e) {
      print('❌ [Recode Update] Error: $e');
      rethrow;
    }
  }

  /// 추출 기록 삭제
  Future<void> delete(String id) async {
    await _client.delete('/api/recodes/$id');
  }

  /// 즐겨찾기 토글
  Future<Recode> toggleFavorite(String id) async {
    final response = await _client.put('/api/recodes/$id/favorite');
    return Recode.fromJson(response);
  }

  /// 즐겨찾기 목록 조회
  Future<List<Recode>> getFavorites({int? page, int? limit}) async {
    final response = await _client.get(
      '/api/recodes/favorites',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      requiresAuth: true,
    );
    return (response as List).map((e) => Recode.fromJson(e)).toList();
  }

  /// 추출 방법별 기록 조회
  Future<List<Recode>> getByBrewMethod(
    String method, {
    int? page,
    int? limit,
  }) async {
    final response = await _client.get(
      '/api/recodes/by-method',
      queryParameters: {
        'method': method,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      requiresAuth: true,
    );
    return (response as List).map((e) => Recode.fromJson(e)).toList();
  }

  /// 원두별 기록 조회
  Future<List<Recode>> getByBean(String bean, {int? page, int? limit}) async {
    final response = await _client.get(
      '/api/recodes/by-bean',
      queryParameters: {
        'bean': bean,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      requiresAuth: true,
    );
    return (response as List).map((e) => Recode.fromJson(e)).toList();
  }

  /// 추출 기록 검색
  Future<List<Recode>> search(String query, {int? page, int? limit}) async {
    final response = await _client.get(
      '/api/recodes/search',
      queryParameters: {
        'q': query,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      requiresAuth: true,
    );
    return (response as List).map((e) => Recode.fromJson(e)).toList();
  }
}

/// Recodes API 싱글톤 인스턴스
final recodesApi = RecodesApi();
