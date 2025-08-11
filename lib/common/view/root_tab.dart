import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/order/view/order_screen.dart';
import 'package:actual/user/view/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../product/view/product_screen.dart';
import '../../restaurant/view/restaurant_screen.dart';

class RootTab extends StatefulWidget {
  static String get routeName => "home";

  const RootTab({super.key});

  @override
  State<RootTab> createState() => _RootTabState();
}

// 1. 애니메이션 제어를 위한 Ticker 제공
// TabController는 탭 전환 시 슬라이드 애니메이션을 처리하기 위해 Ticker가 필요합니다
// SingleTickerProviderStateMixin은 하나의 Ticker를 관리하는 mixin입니다

// 2. 메모리 효율성
// 이 화면에서는 TabController 하나만 사용하므로 SingleTickerProviderStateMixin이 적절합니다
// 여러 개의 애니메이션 컨트롤러가 필요하다면 TickerProviderStateMixin을 사용해야 합니다
class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // vsync 사용하려면 꼭 SingleTickerProviderStateMixin 넣어줘야함
    // vsync 사용 목적
// 1. 성능 최적화
// vsync는 "vertical sync"의 줄임말로, 화면의 수직 동기화와 애니메이션을 맞춥니다
// 위젯이 화면에 보이지 않을 때 애니메이션을 자동으로 일시정지시켜 CPU/GPU 리소스를 절약합니다

// 2. 부드러운 애니메이션
// 화면의 주사율(보통 60fps)과 동기화하여 끊김 없는 애니메이션을 제공합니다
// 탭 전환 시 부드러운 슬라이드 효과를 만들어냅니다

// 3. 배터리 절약
// 불필요한 애니메이션 연산을 방지하여 배터리 수명을 연장합니다
// 앱이 백그라운드에 있을 때 애니메이션이 정지됩니다

// SingleTickerProviderStateMixin 사용목적 요약 :  SingleTickerProviderStateMixin은 TabController의 애니메이션을 위해 필요하고, vsync는 성능 최적화와 부드러운 애니메이션을 위해 반드시 설정해야 하는 매개변수입니다.
    controller = TabController(length: 4, vsync: this);

    controller.addListener(tabListener);
  }


  @override
  void dispose() {
    controller.removeListener(tabListener);
    // TabController는 내부적으로 AnimationController를 사용합니다
    // dispose()를 호출하지 않으면 애니메이션 리소스가 해제되지 않아 메모리 누수가 발생할 수 있습니다
    // TabController가 사용하는 Ticker를 적절히 정리하지 않으면 백그라운드에서도 계속 실행될 수 있습니다
    controller.dispose(); // ← 이 부분이 빠져있음!
    super.dispose();

  // 먼저 listener 제거: controller.removeListener(tabListener)
  // 그다음 controller 해제: controller.dispose()
  // 마지막에 부모 클래스 정리: super.dispose()
  // 이 순서를 지켜야 controller가 완전히 정리되기 전에 listener를 안전하게 제거할 수 있습니다.
  }

  void tabListener(){
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: "코팩 딜리버리",
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        // shifting 선택된 아이콘을 조금크게 그리고 이름까지나옴
        // fixed 선택되거나 선택안된 아이콘 크기를 같게
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          // setState(() {
          //   this.index = index;
          // });

          controller.animateTo(index);

        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "홈"),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            label: "음식",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: "주문",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "프로필",
          ),
        ],
      ),
      child: TabBarView(
        // 드래그로 탭 이동 막기
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          RestaurantScreen(),
          ProductScreen(),
          OrderScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }
}
