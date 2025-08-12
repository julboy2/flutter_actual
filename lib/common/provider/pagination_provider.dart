import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/repository/base_pagination_repository.dart';
import 'package:actual/restaurant/repository/restaurant_rating_repository.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/model_with_id.dart';
import '../model/pagination_params.dart';

class _PaginationInfo{
  final int fetchCount;
  // true - 추가로 데이터 더 가져옴
  // false - 새로고침 (현재 상태를 덮어씌움)
  final bool fetchMore;
  // 강제로 다시 로딩
  // true - CursorPaginationLoading()
  // fetchMore 와 다른점은 fetchMore 는 그대로 보이고 새로고침을 진행하고
  // forceRefetch 는 화면에 있는데이터를 지우고 완전히 새로 가져온다.
  final bool forceRefetch;

  _PaginationInfo({
    this.fetchCount = 20,
    this.fetchMore = false,
    this.forceRefetch = false,
  });

}

// dart 언에어서는 해당 경우에 implements 가 아니라 extends 를 사용한다.
class PaginationProvider<
  T extends IModelWithId,
  U extends IBasePaginationRepository<T>
> extends StateNotifier<CursorPaginationBase>{
  final U repository;
  // 스크롤을 내리면 연속적으로 몇번씩 호출이 되기때문에 처음 1번만 호출되고 나머지는 막는다
  final paginationThrottle = Throttle(
    // 1 초중에 새로운 요청이 들어오면 막는다. (중복요청 막음)
      Duration(seconds: 5),
      // 최초실행
      initialValue: _PaginationInfo(),
  //     checkEquality는 입력값의 동일성 검사를 제어하는 옵션입니다:
  //     checkEquality: true (기본값): 이전 입력과 현재 입력이 같으면 throttle을 적용하지 않고 즉시 실행
  // checkEquality: false: 입력값이 같든 다르든 상관없이 항상 throttle 규칙을 적용

  // 즉, checkEquality: false로 설정하면:
  //
  // 같은 요청이 와도 throttle 기간(1초) 동안은 무조건 대기
  // 중복 요청을 허용하는 게 아니라, 오히려 더 엄격하게 제한
    checkEquality: false,
  );

  // 이렇게 하면 외부에서 받는거기 때문에 외부에서 super 를 받진 않는다..
  // RestaurantRatingStateNotifier(super.state);
  PaginationProvider({required this.repository}): super(CursorPaginationLoading()){
    paginate();

    paginationThrottle.values.listen(
      // state 처음값은 initialValue 가 들어간다.
      // 그다음부터는 아래선언한 paginationThrottle.setValue(여기) 값이 들어간다.
        (state){
          _throttledPagination(state);
        },
    );
  }

  Future<void> paginate({
    int fetchCount = 20,
    // true - 추가로 데이터 더 가져옴
    // false - 새로고침 (현재 상태를 덮어씌움)
    bool fetchMore = false,
    // 강제로 다시 로딩
    // true - CursorPaginationLoading()
    // fetchMore 와 다른점은 fetchMore 는 그대로 보이고 새로고침을 진행하고
    // forceRefetch 는 화면에 있는데이터를 지우고 완전히 새로 가져온다.
    bool forceRefetch = false,
  }) async {
    paginationThrottle.setValue(
        _PaginationInfo(
          fetchMore: fetchMore,
          fetchCount: fetchCount,
          forceRefetch: forceRefetch,
        )
    );

  }

  _throttledPagination(_PaginationInfo info) async{
    final fetchMore= info.fetchMore;
    final fetchCount= info.fetchCount;
    final forceRefetch= info.forceRefetch;

    try {
      // 5가지 가능성
      // State 의 상태
      // 상태가
      // 1) CursorPagination - 정상적으로 데이터가 있는 상태
      // 2) CursorPaginationLoading - 데이터가 로딩중인 생태 (현재 캐시 없음)
      // 3) CursorPaginationError - 에러가 있는 상태
      // 4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때
      // 5) CursorPaginationFetchMore - 추가 데이터를 paginate  요청을 받았을때

      // 바로 반환하는 상황
      // 1) hasMore = false ( 기존 상태에서 이미 다음 데이터가 없다는 값을 들고 있다면)
      // 2) 로딩중 - fetchMore: true
      //  fetchMore 가 아닐때 - 새로고침의 의도가 있을 수 있다.
      // 이미 데이터를 1번 이상요청 했을때
      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;

        // 더 데이터가 없을때
        if (!pState.meta.hasMore) {
          return;
        }
      }

      //  처음로딩
      final isLoading = state is CursorPaginationLoading;

      // 로딩을 한상태에서 추가적으로 데이터를 가져올때
      final isRefetching = state is CursorPaginationRefetching;

      final isFetchingMore = state is CursorPaginationFetchingMore;

      // 2번 반환 상황
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      // fetchMore
      // 데이터를 추가로 더 가져오는 상황
      if (fetchMore) {
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      }
      // 데이터를 처음부터 가져오는 상황
      else {
        // 만약 데이터가 있는 상황이라면
        // 기존 데이터를 보존한채로 fetch 를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching<T>(
            meta: pState.meta,
            data: pState.data,
          );
        } else {
          state = CursorPaginationLoading();
        }
      }

      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore<T>;

        // 기존 데이터에 새로운 데이터 추가
        state = resp.copyWith(
          data: [
            ...pState.data,
            ...resp.data,
          ],
        );
      } else {
        state = resp;
      }
    } catch (e, stack) {
      state = CursorPaginationError(message: "데이터를 가져오지 못 했습니다.");
    }
  }

}