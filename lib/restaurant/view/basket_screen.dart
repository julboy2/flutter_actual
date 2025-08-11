import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/order/provider/order_provider.dart';
import 'package:actual/order/view/order_done_screen.dart';
import 'package:actual/user/provider/basket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../product/component/product_card.dart';

class BasketScreen extends ConsumerWidget {
  static String get routeName => "basket";

  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(basketProvider);

    if(basket.isEmpty){
      return DefaultLayout(
        title: "장바구니",
          child: Center(
            child: Text(
                "장바구니가 비어 있습니다.",
            ),
          )

      );
    }

    final productsTotal = basket.fold<int>(
      0,
          (p, n) => p + (n.product.price * n.count),
    );

    final deliveryFee =basket.first.product.restaurant.deliveryFee;

    return DefaultLayout(
      title: "장바구니",
      // 맨 아래부분이 기기의 버튼 부분에 중복이되어서
      // SafeArea 사용 여기서는 bottom 해주면 기기의 아래버튼보다 좀 올라온다.
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  // row 글과 글사이에 넣기
                  separatorBuilder: (_, index) {
                    return Divider(
                      height: 32.0,
                    );
                  },
                  itemBuilder: (_, index) {
                    final model = basket[index];

                    return ProductCard.fromProductModel(
                      model: model.product,
                      onAdd: () {
                        ref
                            .read(basketProvider.notifier)
                            .addToBasket(product: model.product);
                      },
                      onSubtract: () {
                        ref
                            .read(basketProvider.notifier)
                            .removeFromBasket(product: model.product);
                      },
                    );
                  },
                  itemCount: basket.length,
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "장바구니 금액",
                        style: TextStyle(
                          color: BODY_TEXT_COLOR,
                        ),
                      ),
                      Text(
                          "₩" +productsTotal.toString(),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "배달비",
                        style: TextStyle(
                          color: BODY_TEXT_COLOR,
                        ),
                      ),
                      if(basket.isNotEmpty)
                      Text(
                          "₩" + deliveryFee.toString(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "총액",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "₩" + (deliveryFee + productsTotal).toString(),
                      )
                    ],
                  ),
                  SizedBox(
                    // double.infinity 해주면 좌우 끝까지 버튼이 나온다.
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async{
                         final resp = await  ref.read(orderProvider.notifier).postOrder();
                         if(resp){
                           context.goNamed(OrderDoneScreen.routeName);
                         }else{
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text("결제 실패")),
                           );
                         }
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                        child: Text(
                            "결제하기",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
