/// 장비 상태
enum EquipmentCondition {
  new_,
  likeNew,
  good,
  fair,
  poor;

  factory EquipmentCondition.fromString(String value) {
    switch (value) {
      case 'new':
        return EquipmentCondition.new_;
      case 'like_new':
        return EquipmentCondition.likeNew;
      case 'good':
        return EquipmentCondition.good;
      case 'fair':
        return EquipmentCondition.fair;
      case 'poor':
        return EquipmentCondition.poor;
      default:
        return EquipmentCondition.good;
    }
  }

  String get label {
    switch (this) {
      case EquipmentCondition.new_:
        return '새 상품';
      case EquipmentCondition.likeNew:
        return '거의 새것';
      case EquipmentCondition.good:
        return '상태 좋음';
      case EquipmentCondition.fair:
        return '보통';
      case EquipmentCondition.poor:
        return '사용감 있음';
    }
  }

  String get value {
    switch (this) {
      case EquipmentCondition.new_:
        return 'new';
      case EquipmentCondition.likeNew:
        return 'like_new';
      case EquipmentCondition.good:
        return 'good';
      case EquipmentCondition.fair:
        return 'fair';
      case EquipmentCondition.poor:
        return 'poor';
    }
  }
}

/// 장비 판매 상태
enum EquipmentStatus {
  active,
  sold,
  reserved;

  factory EquipmentStatus.fromString(String value) {
    switch (value) {
      case 'active':
        return EquipmentStatus.active;
      case 'sold':
        return EquipmentStatus.sold;
      case 'reserved':
        return EquipmentStatus.reserved;
      default:
        return EquipmentStatus.active;
    }
  }

  String get label {
    switch (this) {
      case EquipmentStatus.active:
        return '판매중';
      case EquipmentStatus.sold:
        return '판매완료';
      case EquipmentStatus.reserved:
        return '예약중';
    }
  }
}

/// 장비 판매자 정보
class EquipmentSeller {
  final String id;
  final String? username;
  final String? avatarUrl;

  const EquipmentSeller({required this.id, this.username, this.avatarUrl});

  factory EquipmentSeller.fromJson(Map<String, dynamic> json) {
    return EquipmentSeller(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

/// 마켓플레이스 장비 아이템 모델
class EquipmentItem {
  final String id;
  final String sellerId;
  final EquipmentSeller? seller;
  final String? equipmentId;
  final String title;
  final String? description;
  final double price;
  final EquipmentCondition? condition;
  final String? location;
  final List<String> images;
  final EquipmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EquipmentItem({
    required this.id,
    required this.sellerId,
    this.seller,
    this.equipmentId,
    required this.title,
    this.description,
    required this.price,
    this.condition,
    this.location,
    required this.images,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      seller: json['seller'] != null
          ? EquipmentSeller.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      equipmentId: json['equipment_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      condition: json['condition'] != null
          ? EquipmentCondition.fromString(json['condition'] as String)
          : null,
      location: json['location'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      status: EquipmentStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get formattedPrice {
    if (price >= 10000) {
      final man = (price / 10000).floor();
      final remainder = (price % 10000).toInt();
      if (remainder == 0) {
        return '$man만원';
      }
      return '$man만 ${_formatNumber(remainder)}원';
    }
    return '${_formatNumber(price.toInt())}원';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
