import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

abstract class CursorPaginationBase {}
// 아무것도 없지만 CursorPaginationError ,CursorPaginationLoading 와 CursorPagination 의 타입이 CursorPaginationBase 인것이 중요하다.
// <T> 제네릭 타입으로 불러올때 CursorPaginationBase 인 타입은 모두 불러올수 있다.

class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({
    required this.message,
  });
}

class CursorPaginationLoading extends CursorPaginationBase {}

@JsonSerializable(
  // 제네릭을 선언할때 써준다.
  genericArgumentFactories: true,
)
class CursorPagination<T> extends CursorPaginationBase {
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  CursorPagination copyWith({
    CursorPaginationMeta? meta,
    List<T>? data,
  }) {
    return CursorPagination<T>(meta: meta ?? this.meta, data: data ?? this.data);
  }

  factory CursorPagination.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  const CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  CursorPaginationMeta copyWith({
    int? count,
    bool? hasMore,
  }) {
    return CursorPaginationMeta(
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

// 다시 처음부터 불러오기 : 새로고침
class CursorPaginationRefetching<T> extends CursorPagination<T> {
  CursorPaginationRefetching({required super.meta, required super.data});
}

// 리스트 맨 아래로 내려서  추가 데이터 요청
class CursorPaginationFetchingMore<T> extends CursorPagination<T> {
  CursorPaginationFetchingMore({required super.meta, required super.data});
}
