import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'restaurant_repository.g.dart';

// repository class 는 무조건 abstract 로 선언을 해줘야된다고 한다. 인스턴스화가 안되도록
@RestApi()
abstract class RestaurantRepository {
  // http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  // abstract 로 선언했기때문에 body {} 부분은 적지 않는다.
  // @GET("/")
  // paginate();

  @GET("/{id}")
  @Headers({
    "accessToken" : "true",
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}
