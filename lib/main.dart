import 'package:actual/common/view/splash_screen.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _app());
}

class _app extends StatelessWidget {
  const _app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "NotoSans",
      ),

      // 상단에 디버그 표시 제거
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
