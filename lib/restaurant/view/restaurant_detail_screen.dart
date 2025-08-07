import 'package:actual/common/const/colors.dart';
import 'package:badges/badges.dart' as badges;
import 'package:actual/common/const/data.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:actual/product/model/product_model.dart';
import 'package:actual/rating/component/rating_card.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:actual/user/provider/basket_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

import '../../common/dio/dio.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../product/component/product_card.dart';
import '../../rating/model/rating_model.dart';
import '../model/restaurant_detail_model.dart';
import '../model/restaurant_model.dart';
import '../provider/restaurant_provider.dart';
import '../provider/restaurant_rating_provider.dart';
import '../repository/restaurant_repository.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => "restaurantDetail";

  final String id;

  const RestaurantDetailScreen({super.key, required this.id});

  // UI 관련해서는 UI 코드만 두개하자
  Future<RestaurantDetailModel> getRestaurantDetail(WidgetRef ref) async {
    // final dio = Dio();
    // dio.interceptors.add(
    //     CustomInterceptor(storage: storage)
    // );

    // final dio = ref.watch(dioProvider);
    // final repository = RestaurantRepository(dio, baseUrl: "http://$ip/restaurant");
    // return repository.getRestaurantDetail(id: id);

    return ref.watch(restaurantRepositoryProvider).getRestaurantDetail(id: id);
  }

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);

    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.pagination(
      controller: controller,
      provider: ref.read(
        restaurantRatingProvider(widget.id).notifier,
      ),
    );
  }

  // 누락되어서 추가함
  @override
  void dispose() {
    controller.removeListener(listener); // 1. 리스너 제거
    controller.dispose(); // 2. 컨트롤러 해제
    super.dispose(); // 3. 부모 클래스 정리
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailProvider(widget.id));
    final ratingState = ref.watch(restaurantRatingProvider(widget.id));
    final basket = ref.watch(basketProvider);

    if (state == null) {
      return DefaultLayout(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultLayout(
      title: "불타는 떡볶이",
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: PRIMARY_COLOR,
        // 'package:flutter/material.dart'; 에도 badges 가 있어서  as badges 해서 다시 불러온다.
        // badges 클릭시 장바구니 버튼 숫자 올라가는 효과
        child: badges.Badge(
          // 값이 있을때만 badge 를 보여주게끔
          showBadge: basket.isNotEmpty,
          badgeContent: Text(
            // 토탈 카운트
            basket
                .fold<int>(
                  // 시작값
                  0,
                  (previous, next) => previous + next.count,
                )
                .toString(),
            style: TextStyle(
                color: PRIMARY_COLOR,
              fontSize: 10.0
            ),
          ),
          badgeStyle: badges.BadgeStyle(badgeColor: Colors.white),
          child: Icon(
            Icons.shopping_basket_outlined,
            color: Colors.white,
          ),
        ),
      ),
      child: CustomScrollView(
        controller: controller,
        slivers: [
          renderTop(model: state),
          if (state is! RestaurantDetailModel) renderLoading(),
          if (state is RestaurantDetailModel) renderLabel(),
          if (state is RestaurantDetailModel)
            renderProducts(
              products: state.products,
              restaurant: state,
            ),
          if (ratingState is CursorPagination<RatingModel>)
            renderRatings(models: ratingState.data),
        ],
      ),
    );
  }

  SliverPadding renderRatings({
    required List<RatingModel> models,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RatingCard.fromModel(model: models[index]),
          ),
          childCount: models.length,
        ),
      ),
    );
  }

  SliverPadding renderLoading() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: SkeletonParagraph(
                style: SkeletonParagraphStyle(
                  lines: 5,
                  // SkeletonParagraph 자체에 페딩이 있어서 없애줌
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          "메뉴",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  SliverPadding renderProducts({
    required RestaurantModel restaurant,
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final model = products[index];

          // InkWell 은 화면 안에 그대로 있을때 사용한다. (화면전환 X )
          // InkWell 은 클릭시 클릭한곳에 효과가 나온다.
          return InkWell(
            onTap: () {
              ref
                  .read(basketProvider.notifier)
                  .addToBasket(
                    product: ProductModel(
                      id: model.id,
                      name: model.name,
                      detail: model.detail,
                      imgUrl: model.imgUrl,
                      price: model.price,
                      restaurant: restaurant,
                    ),
                  );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ProductCard.fromRestaurantProductModel(model: model),
            ),
          );
        }, childCount: products.length),
      ),
    );
  }

  SliverToBoxAdapter renderTop({
    required RestaurantModel model,
  }) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }
}
