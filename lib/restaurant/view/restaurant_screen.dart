import 'package:actual/common/const/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../component/restaurant_card.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  Future<List> paginateRestaurant() async{
    final dio = Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final resp = await dio.get(
      "http://$ip/restaurant",
      options: Options(
        headers: {
          "authorization" : "Bearer $accessToken"
        }
      )
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
          builder: (context , AsyncSnapshot<List> snapshot){
            // print(snapshot.error);
            // print(snapshot.data);
            if(!snapshot.hasData){
              return Container();
            }

            return ListView.separated(
                itemBuilder: (_, index){
                  final item = snapshot.data![index];

                  return RestaurantCard(
                    image: Image.network(
                      "http://$ip/${item["thumbUrl"]}",
                      fit: BoxFit.cover,
                    ),
                    // image: Image.asset(
                    //   "asset/img/food/ddeok_bok_gi.jpg",
                    //   // fit 으로 해야 전체로 꽉찬다.
                    //   fit: BoxFit.cover,
                    // ) ,
                    name: item["name"],
                    // List<String> 타입 변환
                    tags: List<String>.from(item["tags"]) ,
                    ratingsCount: item["ratingsCount"],
                    deliveryTime: item["deliveryTime"],
                    deliveryFee: item["deliveryFee"],
                    ratings: item["ratings"],
                  );
                },
                itemCount: snapshot.data!.length,
              // 각각의 아이템 사이에 들어가는 것을 빌드
              separatorBuilder: (_,index){
                  return SizedBox(height: 16.0,);
              }
            );


          },
        )
      ),
    );
  }
}
