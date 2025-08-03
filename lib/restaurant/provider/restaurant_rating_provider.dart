import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/provider/pagination_provider.dart';
import 'package:actual/rating/model/rating_model.dart';
import 'package:actual/restaurant/repository/restaurant_rating_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantRatingProvider = StateNotifierProvider.family<
  RestaurantRatingStateNotifier, CursorPaginationBase ,String
>((ref , id){
  final repo = ref.watch(restaurantRatingRepositoryProvider(id));

  return RestaurantRatingStateNotifier(repository: repo);

});


class RestaurantRatingStateNotifier extends PaginationProvider<RatingModel , RestaurantRatingRepository>{

  // 이렇게 하면 외부에서 받는거기 때문에 외부에서 super 를 받진 않는다..
  // RestaurantRatingStateNotifier(super.state);

  RestaurantRatingStateNotifier({required super.repository});

}