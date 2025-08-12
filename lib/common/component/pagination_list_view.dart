import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/model_with_id.dart';
import 'package:actual/common/provider/pagination_provider.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 속성 만들기
typedef PaginationWidgetBuilder<T extends IModelWithId> =
    Widget Function(
      BuildContext context,
      int index,
      T model,
    );

class PaginationListView<T extends IModelWithId>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationProvider, CursorPaginationBase>
  provider;
  final PaginationWidgetBuilder<T> itemBuilder;

  const PaginationListView({
    required this.provider,
    required this.itemBuilder,
    super.key,
  });

  @override
  ConsumerState<PaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends IModelWithId> extends ConsumerState<PaginationListView> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.pagination(
      controller: controller,
      provider: ref.read(widget.provider.notifier),
    );
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    // 완전 처음 로딩
    if (state is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is CursorPaginationError) {
      return Column(
        // 좌우로 최대한 넓게
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16.0,
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(widget.provider.notifier)
                  .paginate(
                    //강제로 데이터를 다시 가져오기
                    forceRefetch: true,
                  );
            },
            child: Text("다시시도"),
          ),
        ],
      );
    }

    final cp = state as CursorPagination<T>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),

      /*
      FutureBuilder 과 StreamBuilder 의 특징은
      데이터를 요청한 이력이 있다면  그 데이터가 기억이 되어 있다.

      단점은
      어디에서든 캐시를 가지고 오는건 불가능하다.
      그래서 직접 캐시를 만든다. riverpod 을써서 가능하다.

       */
      // 화면을 당겼을때 새로고침 효과를 주기위해 RefreshIndicator 사용
      child: RefreshIndicator(
        onRefresh: () async{
          ref.read(widget.provider.notifier).paginate(
            //  강제 새로고침
            forceRefetch: true,
          );
        },
        child: ListView.separated(
          // 화면이 넘어갈 경우에만 스크롤이 나오는데
          // 화면 개수가 적어도 스크롤이 나오도록 효과 , 항상 스크롤 효과
          physics: AlwaysScrollableScrollPhysics() ,
          controller: controller,
          // 스크롤을 내릴때 로딩을 보여주기 위해 +1 을한다.
          itemCount: cp.data.length + 1,
          itemBuilder: (_, index) {
            if (index == cp.data.length) {
              // 스크롤을 빠르게 내려서 맨밑으로 갈경우
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: cp is CursorPaginationFetchingMore
                      ? CircularProgressIndicator()
                      : Text("마지막 데이터 입니다."),
                ),
              );
            }

            final pItem = cp.data[index];
            // final pItem = RestaurantModel.fromJson(item);

           // 위에서 만든 itemBuilder
            return widget.itemBuilder(
              context,
              index,
              pItem,
            );
          },

          // 각각의 아이템 사이에 들어가는 것을 빌드
          separatorBuilder: (_, index) {
            return SizedBox(
              height: 16.0,
            );
          },
        ),
      ),
    );
  }
}
