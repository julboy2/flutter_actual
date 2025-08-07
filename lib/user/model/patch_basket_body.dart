import 'package:json_annotation/json_annotation.dart';

part 'patch_basket_body.g.dart';

@JsonSerializable()
class PatchBasketBody {
  final List<PatchBasketBodyBasket> basket;

  PatchBasketBody({
    required this.basket,
  });

  Map<String, dynamic> toJson() => _$PatchBasketBodyToJson(this);
}

@JsonSerializable()
class PatchBasketBodyBasket {
  final String productId;
  final int count;

  PatchBasketBodyBasket({
    required this.productId,
    required this.count,
  });

  // fromJson 이 없으면 g 파일에서 에러가 난다.
  factory PatchBasketBodyBasket.fromJson(Map<String, dynamic> json)
  => _$PatchBasketBodyBasketFromJson(json);

  Map<String, dynamic> toJson() => _$PatchBasketBodyBasketToJson(this);
}
