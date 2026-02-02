import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// 알림 화면
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림')),
      body: Center(child: Text('알림 목록', style: AppTypography.headlineMedium)),
    );
  }
}
