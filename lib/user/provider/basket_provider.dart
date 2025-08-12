import 'dart:math';

import 'package:actual/user/model/basket_item_model.dart';
import 'package:actual/user/model/patch_basket_body.dart';
import 'package:actual/user/repository/user_me_repository.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../product/model/product_model.dart'; // firstWhereOrNull 사용위해 호출

final basketProvider =
    StateNotifierProvider<BasketProvider, List<BasketItemModel>>((ref) {
      final repository = ref.watch(userMeRepositoryProvider);

      return BasketProvider(
        repository: repository,
      );
    });

class BasketProvider extends StateNotifier<List<BasketItemModel>> {
  final UserMeRepository repository;
  final updateBasketDebounce = Debouncer(
      Duration(seconds: 1),
      initialValue: null,
    checkEquality: false,
  );

  BasketProvider({
    required this.repository,
  }) : super([]){
    updateBasketDebounce.values.listen(
        (event){
          patchBasket();
        }
    );
  }


  Future<void> patchBasket() async{
    await repository.patchBasket(
        body: PatchBasketBody(
            basket: state.map(
                (e) => PatchBasketBodyBasket(
                    productId: e.product.id,
                    count: e.count
                )
            ).toList(),
        )
    );
  }

  Future<void> addToBasket({
    required ProductModel product,
  }) async {
    // 요청을 먼저 보내고
    // 응답이 오면
    // 캐시를 업데이트 했다.

    // 여기서는 캐시를 먼저 업데이트하고 요청을 보낸다.
    // 밑에서 api 요청을 한다. (캐시 업데이트 후)
    // 만약 여기서 에러가 나도 큰문제는 아니라서 (장바구니에서 확인가능 하기때문에)
    // 에러는 무시하고 캐시를 먼저 업데이트 한다고 한다.

    /// 1) 아직 장바구니에 해당되는 상품이 없다면
    ///    장바구니에 상품을 추가한다.
    /// 2) 만약에 이미 들어있다면
    ///   장바구니에 있는 값에 +1 을 한다.

    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    if (exists) {
      // 존재하는 상품이면 카운트만 + 1
      state = state
          .map(
            (e) =>
                e.product.id == product.id ? e.copyWith(count: e.count + 1) : e,
          )
          .toList();
    } else {
      state = [...state, BasketItemModel(product: product, count: 1)];
    }

    // Optimistic Response (긍정적 응답)
    // 응답이 성공할거라고 가정하고 상태를 먼저 업데이트함
    // 앱이 빨라보이는 착시효과
    // await Future.delayed(Duration(milliseconds: 500));
    // await patchBasket();
    updateBasketDebounce.setValue(null);
  }

  Future<void> removeFromBasket({
    required ProductModel product,
    // true 면 count 와 관계없이 모두 삭제한다.
    bool isDelete = false,
  }) async {
    /// 1) 장바구니에 상품이 존재할때
    ///   1.1 상품의 카운트가 1보다 크면 -1 한다.
    ///   1.2 상품의 카운트가 1이면 삭제한다.
    /// 2) 상품이 존재하지 않을때
    ///   2.1 즉시 함수를 반환하고 아무것도 하지 않는다.

    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    if (!exists) {
      return;
    }

    final existingProduct = state.firstWhere((e) => e.product.id == product.id);

    if (existingProduct.count == 1 || isDelete) {
      // 존재하는게 1건이면 존재 제외 하고 다른상품만 담는다
      state = state.where((e) => e.product.id != product.id).toList();
    } else {
      // 장바구니에 2건이상이면 카운트만 -1
      state = state
          .map(
            (e) => e.product.id == product.id
                ? e.copyWith(
                    count: e.count - 1,
                  )
                : e,
          )
          .toList();
    }

    // await patchBasket();
    updateBasketDebounce.setValue(null);
  }
}
