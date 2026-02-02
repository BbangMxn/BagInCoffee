// Re-export from API layer
export '../../../api/news.dart' show NewsArticle, CreateNewsDto, UpdateNewsDto;

import '../../../api/news.dart';

// Type alias for backward compatibility
typedef Article = NewsArticle;
