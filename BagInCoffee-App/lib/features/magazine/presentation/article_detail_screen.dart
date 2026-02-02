import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// 기사 상세 화면
class ArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('매거진')),
      body: Center(
        child: Text('기사 상세: $articleId', style: AppTypography.headlineMedium),
      ),
    );
  }
}
