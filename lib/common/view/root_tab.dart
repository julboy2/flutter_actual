import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:flutter/material.dart';

import '../../restaurant/view/restaurant_screen.dart';

class RootTab extends StatefulWidget {
  const RootTab({super.key});

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // vsync 사용하려면 꼭 SingleTickerProviderStateMixin 넣어줘야함
    controller = TabController(length: 4, vsync: this);

    controller.addListener(tabListener);
  }


  @override
  void dispose() {
    controller.removeListener(tabListener);

    super.dispose();
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
          Center(child: Text("음식")),
          Center(child: Text("주문")),
          Center(child: Text("프로필")),
        ],
      ),
    );
  }
}
