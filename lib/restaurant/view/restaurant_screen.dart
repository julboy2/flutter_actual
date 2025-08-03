import 'package:actual/common/const/data.dart';
import 'package:actual/common/dio/dio.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:actual/restaurant/repository/restaurant_repository.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../component/restaurant_card.dart';
import '../model/restaurant_model.dart';
import '../provider/restaurant_provider.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({super.key});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  // Future<List<RestaurantModel>> paginateRestaurant(WidgetRef ref) async {
  //   final dio = ref.watch(dioProvider);
  //
  //   final resp = await RestaurantRepository(
  //     dio,
  //     baseUrl: "http://$ip/restaurant",
  //   ).paginate();
  //   return resp.data;
  // }

  // 스크롤을 다내리기전에 추가 20개를 가져오기위해서는 ScrollController 을 써야됨
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // controller 의 값이 바뀔때마다 실행된다.
    controller.addListener(scrollListener);
  }

  void scrollListener(){
    PaginationUtils.pagination(
        controller: controller,
        provider: ref.read(
          restaurantProvider.notifier,
        )
    );

    // 현재 위치가
    // 최대 길이보다 조금 덜되는 위치까지 왔다면
    // 새로운 데이터를 추가요청

    // 현재위치를 가져오려면 offset
    // if(controller.offset > controller.position.maxScrollExtent - 300){
    //   ref.read(restaurantProvider.notifier).paginate(
    //     fetchMore: true,
    //   );
    // }
  }


  @override
  Widget build(BuildContext context) {
    final data = ref.watch(restaurantProvider);

    // 완전 처음 로딩
    if (data is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (data is CursorPaginationError) {
      return Center(
        child: Text(data.message),
      );
    }

    final cp = data as CursorPagination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),

      /*
      FutureBuilder 과 StreamBuilder 의 특징은
      데이터를 요청한 이력이 있다면  그 데이터가 기억이 되어 있다.

      단점은
      어디에서든 캐시를 가지고 오는건 불가능하다.
      그래서 직접 캐시를 만든다. riverpod 을써서 가능하다.

       */
      child: ListView.separated(
        controller: controller,
        // 스크롤을 내릴때 로딩을 보여주기 위해 +1 을한다.
        itemCount: cp.data.length + 1,
        itemBuilder: (_, index) {
          if(index == cp.data.length){
            // 스크롤을 빠르게 내려서 맨밑으로 갈경우
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0 ,
                vertical: 8.0
              ),
              child: Center(
                child: data is CursorPaginationFetchingMore
                ? CircularProgressIndicator() : Text("마지막 데이터 입니다."),
              ),
            );
          }

          final pItem = cp.data[index];
          // final pItem = RestaurantModel.fromJson(item);

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailScreen(
                    id: pItem.id,
                  ),
                ),
              );
            },
            child: RestaurantCard.fromModel(model: pItem),
          );
        },

        // 각각의 아이템 사이에 들어가는 것을 빌드
        separatorBuilder: (_, index) {
          return SizedBox(
            height: 16.0,
          );
        },
      ),
    );
  }
}
