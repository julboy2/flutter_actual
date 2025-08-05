/*
* 캐시를 관리하는 모든 프로바이더들은 다
* StateNotifierProvider 로 만든다.
* */

import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:actual/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../common/provider/pagination_provider.dart';

final restaurantDetailProvider = Provider.family<RestaurantModel?, String>((
  ref,id,
) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhereOrNull((ele) => ele.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
      final repository = ref.watch(restaurantRepositoryProvider);

      final notifier = RestaurantStateNotifier(repository: repository);

      return notifier;
    });

class RestaurantStateNotifier extends PaginationProvider<RestaurantModel , RestaurantRepository> {
  RestaurantStateNotifier({
    required super.repository,
  });

  void getDetail({
    required String id,
  }) async {
    // 만약 아직 데이터가 하나도 없는 상태라면( CursorPagination 이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if (state is! CursorPagination) {
      await paginate();
    }

    // state 가 CursorPagination 이 아닐때 그냥 리턴
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;
    final resp = await repository.getRestaurantDetail(id: id);


    /***중요한 사항***/
    // 두번째 탭에서 스크롤을 많이 내려서 캐시에 없는 레스토랑 id 값을 클릭할경우대비
    if(pState.data.where((e) => e.id == id).isEmpty){
      state = pState.copyWith(
        data: <RestaurantModel>[
          ...pState.data,
          /***중요한 사항***/
          // 두번재 탭에서 스크롤을 내려서 캐시에 넣으면 첫번째 홈탭에서도 끝에 추가가된다.
          resp
        ]
      );
    }else {
      state = pState.copyWith(
        data: pState.data
            .map<RestaurantModel>(
              (e) => e.id == id ? resp : e,
        )
            .toList(),
      );
    }
  }
}
