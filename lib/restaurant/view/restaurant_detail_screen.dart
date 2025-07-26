import 'package:actual/common/const/data.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/dio/dio.dart';
import '../../product/component/product_card.dart';
import '../model/restaurant_detail_model.dart';
import '../repository/restaurant_repository.dart';

class RestaurantDetailScreen extends ConsumerWidget {
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

  /*
  Future<Map<String, dynamic>> getRestaurantDetail() async {
    final dio = Dio();

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    final resp = await dio.get(
      "http://$ip/restaurant/$id",
      options: Options(
        headers: {
          "authorization": "Bearer $accessToken",
        },
      ),
    );

    return resp.data;
  }

   */

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    return DefaultLayout(
      title: "불타는 떡볶이",
      child: FutureBuilder<RestaurantDetailModel>(
        future: ref.watch(restaurantRepositoryProvider).getRestaurantDetail(id: id),
        builder: (_, AsyncSnapshot<RestaurantDetailModel> snapshot) {
          if(snapshot.hasError){
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              // 데이터가 뜨기전 로딩바
              child: CircularProgressIndicator(),
            );
          }

          // final item = RestaurantDetailModel.fromJson(
          //   snapshot.data!,
          // );

          return CustomScrollView(
            slivers: [
              renderTop(model: snapshot.data!),
              renderLabel(),
              renderProducts(
                products: snapshot.data!.products,
              ),
            ],
          );
        },
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
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final model = products[index];
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ProductCard.fromModel(model: model),
          );
        }, childCount: products.length),
      ),
    );
  }

  SliverToBoxAdapter renderTop({
    required RestaurantDetailModel model,
  }) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }
}
