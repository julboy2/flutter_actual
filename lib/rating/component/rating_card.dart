import 'package:actual/common/const/colors.dart';
import 'package:actual/rating/model/rating_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class RatingCard extends StatelessWidget {
  final ImageProvider avatarImage;
  final List<Image> images;
  final int rating;
  final String email;
  final String content;

  const RatingCard({
    super.key,
    required this.avatarImage,
    required this.images,
    required this.rating,
    required this.email,
    required this.content,
  });

  factory RatingCard.fromModel({
    required RatingModel model,
  }){
    return RatingCard(
        avatarImage: NetworkImage(
          model.user.imageUrl,
        ),
        images: model.imgUrls.map((e) => Image.network(e)).toList(),
        rating: model.rating,
        email: model.user.username,
        content: model.content
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          avatarImage: avatarImage,
          email: email,
          rating: rating,
        ),
        const SizedBox(
          height: 8.0,
        ),
        _Body(content: content),
        // 위아래로 스크롤 을 하면 크기를 지정안해줘도되지만 좌우 스크롤시 height 크기를 지정해줘야된다.
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(height: 100, child: _Images(images: images)),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final ImageProvider avatarImage;
  final String email;
  final int rating;

  const _Header({
    super.key,
    required this.avatarImage,
    required this.email,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12.0,
          backgroundImage: avatarImage,
        ),
        const SizedBox(
          width: 8.0,
        ),
        // 꽉 차게 하는 효과 Expanded
        Expanded(
          child: Text(
            email,
            // 초과되는 부분은 ... 으로 나오도록
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...List.generate(
          5,
              (index) =>
              Icon(
                index < rating ? Icons.star : Icons.star_border_outlined,
                color: PRIMARY_COLOR,
              ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final String content;

  const _Body({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 글자를 좌측정렬로 오게하고
        // 한줄을 넘어가면 엔터효과로 글이 밑으로 내려간다.
        Flexible(
          child: Text(
            content,
            style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14.0),
          ),
        ),
      ],
    );
  }
}

class _Images extends StatelessWidget {
  final List<Image> images;

  const _Images({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    // ListView 는 오른쪽으로 리스트
    // 해당 프로젝트는 오른쪽으로 최대 5개까지만 이미지가 나오게 api 에서 호출한다.
    return ListView(
      // 위아래로 스크롤 을 하면 크기를 지정안해줘도되지만 좌우 스크롤시 크기를 지정해줘야된다.
      // 좌우 스크롤 추가
      scrollDirection: Axis.horizontal,
      // import 'package:collection/collection.dart'; 를 호출하면
      // .map 이 아니라 mapIndexed 를 사용할수 있다. ( map 는 index 가 없다. )
      children: images
          .mapIndexed(
            (index, e) =>
            Padding(
              padding: EdgeInsets.only(
                right: index == images.length - 1 ? 0 : 16.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: e,
              ),
            ),
      )
          .toList(),
    );
  }
}
