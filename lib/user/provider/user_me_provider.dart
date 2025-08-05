import 'package:actual/common/const/data.dart';
import 'package:actual/common/secure_storage/secure_storage.dart';
import 'package:actual/user/model/user_model.dart';
import 'package:actual/user/provider/auth_provider.dart';
import 'package:actual/user/repository/auth_repository.dart';
import 'package:actual/user/repository/user_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final userMeProvider = StateNotifierProvider<UserMeStateNotifier , UserModelBase?>(
    (ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      final userMeRepository = ref.watch(userMeRepositoryProvider);
      final storage = ref.watch(secureStorageProvider);

      return UserMeStateNotifier(
        authRepository: authRepository,
        repository: userMeRepository,
        storage: storage,
      );
    }
);

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserMeRepository repository;
  final FlutterSecureStorage storage;

  UserMeStateNotifier({
    required this.authRepository,
    required this.repository,
    required this.storage,
  }) : super(UserModelLoading()) {
    getMe();
  }

  Future<void> getMe() async {

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    print("Access Token: $accessToken"); // 디버깅용
    print("Refresh Token: $refreshToken"); // 디버깅용

    if (refreshToken == null || accessToken == null) {
      state = null;
      return;
    }

    final resp = await repository.getMe();
    state = resp;
  }

  // UserModelBase 를 받는 이유는 어떤값을 받을지몰라서
  Future<UserModelBase> login({
    required String username,
    required String password,
  }) async {
    try {
      state = UserModelLoading();

      final resp = await authRepository.login(
        username: username,
        password: password,
      );

      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);

      final userResp = await repository.getMe();

      state = userResp;

      return userResp;
    } catch (e) {
      state = UserModelError(message: "로그인에 실패했습니다.");

      //Future<UserModelBase> 리턴형식으로 반환하기위해 Future.value 로반환
      return Future.value(state);
    }
  }

  Future<void> logout() async {
    state = null;

    // 동시에 delete 해주기
    await Future.wait([
      storage.delete(key: REFRESH_TOKEN_KEY),
      storage.delete(key: ACCESS_TOKEN_KEY),
    ]);

    // await storage.delete(key: REFRESH_TOKEN_KEY);
    // await storage.delete(key: ACCESS_TOKEN_KEY);
  }
}
