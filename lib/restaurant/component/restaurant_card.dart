import 'package:actual/common/const/colors.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter/material.dart';

import '../model/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final Widget image;
  final String name;
  final List<String> tags;
  final int ratingsCount;
  final int deliveryTime;
  final int deliveryFee;
  final double ratings;
  final bool isDetail;
  final String? herokey;
  final String? detail;

  const RestaurantCard({
    super.key,
    required this.image,
    required this.name,
    required this.tags,
    required this.ratingsCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.ratings,
    this.isDetail = false,
    this.herokey,
    this.detail,
  });

  factory RestaurantCard.fromModel({
    required RestaurantModel model,
    bool isDetail = false,
  }) {
    return RestaurantCard(
      image: Image.network(
        model.thumbUrl,
        fit: BoxFit.cover,
      ),
      // image: Image.asset(
      //   "asset/img/food/ddeok_bok_gi.jpg",
      //   // fit 으로 해야 전체로 꽉찬다.
      //   fit: BoxFit.cover,
      // ) ,
      name: model.name,
      // List<String> 타입 변환
      tags: model.tags,
      ratingsCount: model.ratingsCount,
      deliveryTime: model.deliveryTime,
      deliveryFee: model.deliveryFee,
      ratings: model.ratings,
      isDetail: isDetail,
      herokey: model.id,
      detail: model is RestaurantDetailModel ? model.detail : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(herokey != null)
          // Hero 위젯은 이미지가 다음페이에 자연스럽게 이동되는효과
          Hero(
            tag: ObjectKey(herokey),
            // 이미지를 사각을 깍을때 사용
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDetail ? 0 : 12.0),
              child: image,
            ),
          ),
        if(herokey == null)
          ClipRRect(
            borderRadius: BorderRadius.circular(isDetail ? 0 : 12.0),
            child: image,
          ),
        const SizedBox(height: 16.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDetail ? 16.0 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                tags.join("·"),
                style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  _IconText(
                    icon: Icons.star,
                    label: ratings.toString(),
                  ),
                  renderDot(),
                  _IconText(
                    icon: Icons.receipt,
                    label: ratingsCount.toString(),
                  ),
                  renderDot(),
                  _IconText(
                    icon: Icons.timelapse_outlined,
                    label: "$deliveryTime 분",
                  ),
                  renderDot(),
                  _IconText(
                    icon: Icons.monetization_on,
                    label: deliveryFee == 0 ? "무료" : deliveryFee.toString(),
                  ),
                ],
              ),
              if (detail != null && isDetail)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(detail!),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget renderDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        "·",
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconText({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: PRIMARY_COLOR,
          size: 14.0,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
