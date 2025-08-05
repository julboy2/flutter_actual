import 'package:actual/common/view/splash_screen.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/provider/go_router.dart';

void main() {
  runApp(
    ProviderScope(child: _app())
  );
}

class _app extends ConsumerWidget  {
  const _app({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig : router,
      theme: ThemeData(
        fontFamily: "NotoSans",
      ),

      // 상단에 디버그 표시 제거
      debugShowCheckedModeBanner: false,

    );
  }
}
