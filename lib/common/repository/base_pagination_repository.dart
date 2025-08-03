import 'package:actual/common/model/pagination_params.dart';

import '../model/cursor_pagination_model.dart';
import '../model/model_with_id.dart';

// T 타입에 있는 id 가 무조건 들어와야해서  IModelWithId 를 선언해주었다. 즉 id 가 있는 모델인것이다
abstract class IBasePaginationRepository<T extends IModelWithId> {
  Future<CursorPagination<T>> paginate({
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
