import 'dart:convert';
import 'dart:io';
import 'dart:ui' hide Codec;
import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/component/custom_text_form_field.dart';
import '../../common/const/data.dart';
import '../../common/view/root_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = "";
  String password ="";

  @override
  Widget build(BuildContext context) {

    final dio = Dio();

    // 에뮬레이터 localhost
    final emulatorIp = "10.0.2.2:3000";
    // 시뮬레이터 localhost
    final simulatorIp = "127.0.0.1:3000";

    final ip = Platform.isIOS ? simulatorIp : emulatorIp;

    return DefaultLayout(
      // 화면을 넘어설때 스크롤이 생기도록 처리
      child: SingleChildScrollView(
        // 로그인이나 비밀번호 클릭시 키가 올라오면 onDrag : 화면 드래그시 키 없어짐 , manual : done 클릭시 키 없어짐
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Title(),
                const SizedBox(
                  height: 16.0,
                ),
                _SubTitle(),
                Image.asset(
                  "asset/img/misc/logo.png",
                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                CustomTextFormField(
                  hintText: "이메일을 넣어주세요",
                  onChanged: (String value) {
                    username = value;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CustomTextFormField(
                  hintText: "비밀번호를 넣어주세요",
                  onChanged: (String value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // ID:비밀번호
                    // test@codefactory.ai/testtest
                    final rawString = "$username:$password";

                    Codec<String , String> stringToBase64 = utf8.fuse(base64);

                    String token = stringToBase64.encode(rawString);

                    final resp = await dio.post(
                        "http://$ip/auth/login",
                      options: Options(
                        headers: {
                          "authorization" :"Basic $token",
                        }
                      )
                    );

                    final refreshToken = resp.data["refreshToken"];
                    final accessToken = resp.data["accessToken"];

                    await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
                    await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => RootTab(),
                      )
                    );

                    print(resp.data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                  ),
                  child: Text(
                    "로그인",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final refreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAY29kZWZhY3RvcnkuYWkiLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTc1MjQwODk4OCwiZXhwIjoxNzUyNDk1Mzg4fQ.cRa36AoxeZqWe5DbHNjcuxuv8gtxBmqEHi4ZUoWvGXU";

                    final resp = await dio.post(
                        "http://$ip/auth/token",
                        options: Options(
                            headers: {
                              "authorization" :"Bearer $refreshToken",
                            }
                        )
                    );

                    print(resp.data);
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.black),
                  child: Text(
                    "회원가입",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "환영합니다!",
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "이메일과 비밀번호를 로그인 해주세요!\n오늘도 성공적인 주문이 되길 :)",
      style: TextStyle(
        fontSize: 16,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
