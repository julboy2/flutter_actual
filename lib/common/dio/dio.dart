import 'package:actual/common/const/data.dart';
import 'package:actual/common/secure_storage/secure_storage.dart';
import 'package:actual/user/provider/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(CustomInterceptor(storage: storage ,ref:  ref));

  return dio;
});

class CustomInterceptor extends Interceptor {
  // 스토리지에서 토큰을 가져오기위해 호출
  final FlutterSecureStorage storage;
  final Ref ref;

  const CustomInterceptor({
    required this.storage,
    required this.ref,
  });

  // 1) 요청을 보낼때 : dio 호출시 자동으로 호출된다.
  // 요청이 보내질때마다
  // 만약에 요청 헤더에 accessToken : ture 라면
  // 실제 토큰을 가져와서 헤더를 변경한다.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print("[REQ] [${options.method}] ${options.uri}");

    // repository 파일에서
    // @Headers({"accessToken" : "true",}) 선언했다.
    if (options.headers["accessToken"] == "true") {
      options.headers.remove("accessToken");

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({
        "authorization": "Bearer $token",
      });
    }

    if (options.headers["refreshToken"] == "true") {
      options.headers.remove("refreshToken");

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({
        "authorization": "Bearer $token",
      });
    }

    //return 을 해야 실제 요청이 된다.
    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      "[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}",
    );
    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러가 났을때 토큰 재발급
    // 401 에러가 났으면 서버에서 리프레시 토큰으로 액세스 토큰을 새로 발급하도록 짜놨다.
    print("[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}");

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    if (refreshToken == null) {
      // 에러를 던짐
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == "/auth/token";

    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        final resp = await dio.post(
          "http://$ip/auth/token",
          options: Options(headers: {"authorization": "Bearer $refreshToken"}),
        );

        final accessToken = resp.data["accessToken"];

        // err.requestOptions 는 위에 선언한
        // void onRequest(RequestOptions options,
        // 이다
        final options = err.requestOptions;

        options.headers.addAll({
          "authorization": "Bearer $accessToken",
        });

        // 스토리지에 새롭게 발급받은 액세스 토큰을 넣어준다.
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        final response = await dio.fetch(options);

        return handler.resolve(response);
      } on DioException catch (e) {
        ref.read(authProvider.notifier).logout();

        // on DioException 이렇게 하면 dio 에러만 잡는다.
        // 에러를 던짐
        return handler.reject(e);
      }


    }

    // return handler.reject(err);
    super.onError(err, handler);
  }
}
