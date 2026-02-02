import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 사이드바 열림 상태
final sidebarOpenProvider = StateProvider<bool>((ref) => false);

/// 사이드바 토글
void toggleSidebar(WidgetRef ref) {
  ref.read(sidebarOpenProvider.notifier).update((state) => !state);
}

/// 사이드바 열기
void openSidebar(WidgetRef ref) {
  ref.read(sidebarOpenProvider.notifier).state = true;
}

/// 사이드바 닫기
void closeSidebar(WidgetRef ref) {
  ref.read(sidebarOpenProvider.notifier).state = false;
}
