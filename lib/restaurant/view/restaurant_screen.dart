import 'package:actual/common/const/data.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../component/restaurant_card.dart';
import '../model/restaurant_model.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  Future<List> paginateRestaurant() async {
    final dio = Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final resp = await dio.get(
      "http://$ip/restaurant",
      options: Options(headers: {"authorization": "Bearer $accessToken"}),
    );

    return resp.data["data"];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List>(
          future: paginateRestaurant(),
          builder: (context, AsyncSnapshot<List> snapshot) {
            // print(snapshot.error);
            // print(snapshot.data);
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.separated(
              itemBuilder: (_, index) {
                final item = snapshot.data![index];
                final pItem = RestaurantModel.fromJson(item);

                return GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RestaurantDetailScreen(
                        id: pItem.id,
                      ))
                    );
                  },
                    child: RestaurantCard.fromModel(model: pItem)
                );
              },
              itemCount: snapshot.data!.length,
              // 각각의 아이템 사이에 들어가는 것을 빌드
              separatorBuilder: (_, index) {
                return SizedBox(
                  height: 16.0,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
