import 'package:actual/common/dio/dio.dart';
import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/pagination_params.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../common/const/data.dart';
import '../../common/repository/base_pagination_repository.dart';

part 'restaurant_repository.g.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final repository = RestaurantRepository(
    dio,
    baseUrl: "http://$ip/restaurant",
  );
  return repository;
});

// repository class 는 무조건 abstract 로 선언을 해줘야된다고 한다. 인스턴스화가 안되도록
@RestApi()
abstract class RestaurantRepository implements IBasePaginationRepository<RestaurantModel> {
  // http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  // abstract 로 선언했기때문에 body {} 부분은 적지 않는다.
  @GET("/")
  @Headers({
    "accessToken": "true",
  })
  Future<CursorPagination<RestaurantModel>> paginate({
    // @Queries() 가 파라미터를 쿼리값으로 변경
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });

  @GET("/{id}")
  @Headers({
    "accessToken": "true",
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}
