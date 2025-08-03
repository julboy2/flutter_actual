import 'package:actual/common/dio/dio.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../common/const/data.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/model/pagination_params.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../rating/model/rating_model.dart';

part 'restaurant_rating_repository.g.dart';

// uri 에서 :rid 값을 받기위해 family 로 받는다.
final restaurantRatingRepositoryProvider =
    Provider.family<RestaurantRatingRepository, String>((ref, id) {
      final dio = ref.watch(dioProvider);

      return RestaurantRatingRepository(
        dio,
        baseUrl: "http://$ip/restaurant/$id/rating",
      );
    });

// repository class 는 무조건 abstract 로 선언을 해줘야된다고 한다. 인스턴스화가 안되도록
// http://ip/restaurant/:rid/rating
@RestApi()
abstract class RestaurantRatingRepository implements IBasePaginationRepository<RatingModel> {
  factory RestaurantRatingRepository(Dio dio, {String baseUrl}) =
      _RestaurantRatingRepository;

  // abstract 로 선언했기때문에 body {} 부분은 적지 않는다.
  @GET("/")
  @Headers({
    "accessToken": "true",
  })
  Future<CursorPagination<RatingModel>> paginate({
    // @Queries() 가 파라미터를 쿼리값으로 변경
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });
}
