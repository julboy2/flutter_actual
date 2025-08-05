// Retrofit 을 쓰지 않고 작업해보자
// header 에 작업할게 많기때문에 (그렇다고 한다.) , Retrofit 을 써도된다.

import 'package:actual/common/const/data.dart';
import 'package:actual/common/dio/dio.dart';
import 'package:actual/common/model/login_response.dart';
import 'package:actual/common/model/token_response.dart';
import 'package:actual/common/utils/data_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref){
  final dio = ref.watch(dioProvider);

  return AuthRepository(baseUrl: "http://$ip/auth", dio: dio);
});

class AuthRepository {
  final String baseUrl;
  final Dio dio;

  AuthRepository({
    required this.baseUrl,
    required this.dio,
  });

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final serialized = DataUtils.plainToBase64("$username:$password");

    final resp = await dio.post(
      "$baseUrl/login",
      options: Options(
        headers: {
          "authorization": "Basic $serialized",
        },
      ),
    );

    return LoginResponse.fromJson(resp.data);
  }

  Future<TokenResponse> token() async {
    final resp = await dio.post(
      "$baseUrl/token",
      options: Options(
        headers: {
          "refreshToken": "true",
        },
      ),
    );

    return TokenResponse.fromJson(resp.data);
  }
}
