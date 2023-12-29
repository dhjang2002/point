// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, library_private_types_in_public_api, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, duplicate_ignore

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:point/auth/joinUser.dart';
import 'package:point/auth/signing.dart';
import 'package:point/common/dialogbox.dart';
import 'package:point/constant/constant.dart';
import 'package:point/models/newPerson.dart';
import 'package:point/provider/sessionData.dart';
import 'package:flutter/material.dart';
import 'package:point/remote/remote.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:transition/transition.dart';
import 'package:http/http.dart' as http;
//import 'html_shim.dart' if (dart.library.html) 'dart:html' show window;

class SnsLogin extends StatefulWidget {
  const SnsLogin({Key? key}) : super(key: key);

  @override
  _SnsLoginState createState() => _SnsLoginState();
}

class _SnsLoginState extends State<SnsLogin> {
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    print(_session.toString());

    Future.microtask(() async {});
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    const double radious = 50.0;
    final double size = MediaQuery.of(context).size.width/3*5;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: WillPopScope(
          onWillPop: () => _onBackPressed(context),
          child: GestureDetector(
              onTap: () { FocusScope.of(context).unfocus(); },
              child: SafeArea(
                child:SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                            child: Container(
                              height: double.infinity,
                              alignment: Alignment.center, // This is needed
                              child: Image.asset(
                                "assets/icon/icon_sign_back.png",
                                fit: BoxFit.contain,
                                width: 150,
                              ),
                            )
                        ),

                        Positioned(
                          bottom: 50,
                          child: Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width - 20,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                //const Spacer(),
                                // 로그인 버튼
                                const SizedBox(height: 20.0),
                                // kakao
                                GestureDetector(
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius:
                                            BorderRadius.circular(radious)),
                                    child: const Center(
                                        child: Text('Kakao 인증',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold)
                                        )
                                    ),
                                  ),
                                  onTap: () {
                                    _kakaoLogin();
                                  },
                                ),
                                const SizedBox(height: 20.0),
                                // apple
                                Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      child: Container(
                                        width: double.infinity,
                                        margin:
                                            const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                        padding:
                                            const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(radious)),
                                        child: const Center(
                                            child: Text('apple 로그인',
                                                style: const TextStyle(
                                                    color: ColorB3,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      onTap: () {
                                        _appleLogin();
                                      },
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              )
          )
      ),
    );
  }

  Future<void> _appleLogin() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'de.lunaone.flutter.signinwithappleexample.service',
        redirectUri: kIsWeb
            ? Uri.parse(
                "https://") //Uri.parse('https://${window.location.host}/')
            : Uri.parse(
                'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
              ),
      ),
      nonce: 'example-nonce',
      state: 'example-state',
    );

    // ignore: avoid_print
    print(credential);

    // This is the endpoint that will convert an authorization code obtained
    // via Sign in with Apple into a session in your system
    final signInWithAppleEndpoint = Uri(
      scheme: 'https',
      host: 'flutter-sign-in-with-apple-example.glitch.me',
      path: '/sign_in_with_apple',
      queryParameters: <String, String>{
        'code': credential.authorizationCode,
        if (credential.givenName != null) 'firstName': credential.givenName!,
        if (credential.familyName != null) 'lastName': credential.familyName!,
        'useBundleId':
            !kIsWeb && (Platform.isIOS || Platform.isMacOS) ? 'true' : 'false',
        if (credential.state != null) 'state': credential.state!,
      },
    );

    final session = await http.Client().post(
      signInWithAppleEndpoint,
    );

    // If we got this far, a session based on the Apple ID credential has been created in your system,
    // and you can now set this as the app's session
    // ignore: avoid_print
    //print(session);
  }

  Future <void> _kakaoLogin() async {
    String access_token = "";
    bool talkInstalled = await isKakaoTalkInstalled();

    // 카카오톡이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (talkInstalled) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        access_token = token.accessToken;
        print('카카오톡으로 로그인 성공 $access_token');
      } catch (e) {
        print('카카오계정으로 로그인 실패');

        // 유저에 의해서 카카오톡으로 로그인이 취소된 경우 카카오계정으로 로그인 생략 (ex 뒤로가기)
        if (e is PlatformException && e.code == 'CANCELED') {
          return;
        }

        // 카카오톡에 로그인이 안되어있는 경우 카카오계정으로 로그인
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          access_token = token.accessToken;
          print('카카오톡으로 로그인 성공 $access_token');
        } catch (e) {
          print('카카오계정으로 로그인 실패');
        }
      }
    } else {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        access_token = token.accessToken;
        print('카카오톡으로 로그인 성공 $access_token');
      } catch (e) {
        print('카카오계정으로 로그인 실패');
      }
    }

    _reqKakaoSigning(access_token);
  }

  Future<void> _reqKakaoSigning(String token) async {
    //print("_reqKakaoSigning()->token: $token");
    _session.Token = "";
    if (token.isNotEmpty) {
      await Remote.apiPost(
          context: context,
          session: _session,
          method: "point/kakaoLogin",
          params: {"token": token},
          onResult: (dynamic data) async {

            if (kDebugMode) {
              var logger = Logger();
              logger.d(data);
            }

            String access_token;
            if (data['status'] == "success") {
              if (data['isMember'].toString().trim() == "0") {
                NewPerson person = NewPerson.fromJson(data['data']);
                //print(person.toString());
                access_token = await _doJoinUser(person);
              } else {
                access_token = data['token'].toString().trim();
              }
              _session.Token = access_token;
              if(_session.Token.isNotEmpty) {
                await SigningWithToken(context, _session);
                _session.notifyListeners();
                if(_session.isSigned()) {
                  Navigator.pop(context);
                }
              }
            } else {
              showOkDialogBox(
                  context: context, title: "오류", message: data['message']);
            }
          },
          onError: (String error) {});
    }
  }

  Future<String> _doJoinUser(NewPerson person) async {
    var token = await Navigator.push(
      context,
      Transition(
          child: JoinUser(
            person: person,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (token != null) {
      return token.toString();
    }
    return "";
  }

  _onBackPressed(BuildContext context) {
    return Future(() => false);
  }
}
