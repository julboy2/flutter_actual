import 'package:actual/common/component/pagination_list_view.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../component/restaurant_card.dart';
import '../provider/restaurant_provider.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationListView(
      provider: restaurantProvider,
      itemBuilder: <RestaurantModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            context.goNamed(
                RestaurantDetailScreen.routeName,
              pathParameters: {
                  "rid": model.id,
              },
              // 모바일에서는 queryParameters 안쓰는게 좋다.
              //queryParameters:
            );
            //context.go("/restaurant/${model.id}");


            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (_) => RestaurantDetailScreen(
            //       id: model.id,
            //     ),
            //   ),
            // );
          },
          child: RestaurantCard.fromModel(model: model),
        );
      },
    );
  }
}
