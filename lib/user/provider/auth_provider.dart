import 'dart:async';

import 'package:actual/common/view/root_tab.dart';
import 'package:actual/common/view/splash_screen.dart';
import 'package:actual/order/view/order_done_screen.dart';
import 'package:actual/restaurant/view/basket_screen.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:actual/user/model/user_model.dart';
import 'package:actual/user/provider/user_me_provider.dart';
import 'package:actual/user/view/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider with ChangeNotifier {
  final Ref ref;

  AuthProvider({
    required this.ref,
  }) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      // userMeProvider 에서 변경사항이 생겼을때만 알려주기
      if (previous != next) {
        // ChangeNotifierProvider  사용시에는 수동으로 상태값을 변경해줘야함
        // 오준석님강의에도 있었던 상태값 변경
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
    GoRoute(
      path: "/",
      name: RootTab.routeName,
      builder: (_, __) => RootTab(),
      routes: [
        GoRoute(
          path: "restaurant/:rid",
          name: RestaurantDetailScreen.routeName,
          builder: (_, state) =>
              RestaurantDetailScreen(id: state.pathParameters["rid"]!),
        ),
      ],
    ),
    GoRoute(
      path: "/basket",
      name: BasketScreen.routeName,
      builder: (_, __) => BasketScreen(),
    ),
    GoRoute(
      path: "/order_done",
      name: OrderDoneScreen.routeName,
      builder: (_, __) => OrderDoneScreen(),
    ),
    GoRoute(
      path: "/splash",
      name: SplashScreen.routeName,
      builder: (_, __) => SplashScreen(),
    ),
    GoRoute(
      path: "/login",
      name: LoginScreen.routeName,
      builder: (_, __) => LoginScreen(),
    ),
  ];

  void logout(){
    ref.read(userMeProvider.notifier).logout();
  }

  /// SplashScreen
  /// 앱을 처음 시작했을때
  /// 토큰이 존재하는지 확인하고
  /// 로그인 스크린으로 보내줄지
  /// 홈 스크린으로 보내줄지 확인하는 과정이 필요하다.
  Future<String?> redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final UserModelBase? user = ref.read(userMeProvider);

    final loggIn = state.uri.path == "/login";

    // 유저 정보가 없는데
    // 로그인중이면 그대로 로그인 페이지에 두고
    // 만약 로그인중이 아니라면 로그인 페이지로 이동
    if (user == null) {
      return loggIn ? null : "/login";
    }

    // user 가 null 이 아님

    // UserModel
    // 사용자 정보가 있는 상태면
    // 로그인 중이거나 현재 위치가 SplashScreen 이면 (이미 로그인 상태이기때문에)
    // 홈으로 이동
    // null 로 하면 원래 가던곳으로 간다고한다.
    if (user is UserModel) {
      return loggIn || state.uri.path == "/splash" ? "/" : null;
    }

    // UseModelError
    if (user is UserModelError) {
      return !loggIn ? "/login" : null;
    }

    return null;
  }
}
