/// BagInCoffee API Layer
///
/// 모든 API를 한 곳에서 import할 수 있습니다.
///
/// ```dart
/// import 'package:bagin_coffee/api/api.dart';
///
/// // 사용 예시
/// final posts = await postsApi.list();
/// final guides = await guidesApi.list();
/// ```

// API Client
export 'client.dart';

// Content APIs
export 'posts.dart';
export 'guides.dart';
export 'recodes.dart';
export 'news.dart';

// Social APIs
export 'comments.dart';
export 'users.dart';
export 'notifications.dart';
export 'reviews.dart';

// BagInDB APIs (Products, Brands, Categories)
export 'products.dart';
export 'brands.dart';
export 'categories.dart';
