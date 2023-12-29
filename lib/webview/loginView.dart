import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:point/common/dialogbox.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String AUTH_URL = "https://wms.point-i.co.kr/auth/point/login/";

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static const platformCh = MethodChannel('fcm_default_channel');

  late WebViewController _webViewController;
  bool _bReady = false;

  @override
  void initState() {
     if(Platform.isAndroid) {
       WebView.platform = SurfaceAndroidWebView();
    //WebView.platform = AndroidWebView();
     }
    setState(() {
      _bReady = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text(""),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, "");
            }),
      ),
      body: WillPopScope(
          onWillPop: () => _onBackPressed(context),
          child: _buildWebview()
      ),
    );
  }

  Widget _buildWebview() {
    if(!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
        child: WebView(
          zoomEnabled:false,
          initialUrl: AUTH_URL,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
          },

          onProgress: (int progress) {
            if (kDebugMode) {
              print("WebView is loading (progress : $progress%)");
            }
          },

          javascriptChannels: <JavascriptChannel> {
            fromApp(context),
          },
          navigationDelegate: (request) async{
            print('navigate url : ${request.url}');

            // 2 채널이용
            if(!request.url.startsWith('http') && !request.url.startsWith('https')) {

              if(Platform.isAndroid) {
                getAppUrl(request.url.toString());
                return NavigationDecision.prevent;

              }else if(Platform.isIOS){
                if (await canLaunchUrl(Uri.parse(request.url))) {
                  print('navigate url : ${request.url}');
                  await launchUrl(Uri.parse(request.url),);
                  return NavigationDecision.prevent;
                }
              }
            }
            return NavigationDecision.navigate;
          },

          onPageStarted: (String url) {
            if (kDebugMode) {
              print('Page started loading: $url');
            }
          },

          onPageFinished: (String url) {
            if (kDebugMode) {
              print('Page finished loading: $url');
            }
          },

          gestureNavigationEnabled: true,
        )
    );
  }

  Future getAppUrl(String url) async {

    print(">>>>>> getAppUrl()=$url");

    await platformCh.invokeMethod('getAppUrl', <String, Object>{'url': url}).then((value) async{
      print('After: paring url : $value');

      if(value.toString().startsWith('ispmobile://')) {
        await platformCh.invokeMethod('startAct', <String, Object>{'url': url}).then((value) {
          print('parsing url : $value');
          return;
        });
      }

      value = "com.kakao.talk.intent.action.CAPRI_LOGGED_IN_ACTIVITY;launchFlags=0x08880000;S.com.kakao.sdk.talk.appKey=502a11e55331d01839c364d642bdb0cd;S.com.kakao.sdk.talk.redirectUri=https://wms.point-i.co.kr/auth/point/callback;S.com.kakao.sdk.talk.kaHeader=sdk/1.43.1%20os/javascript%20sdk_type/javascript%20lang/ko-KR%20device/Linux_aarch64%20origin/https%3A%2F%2Fwms.point-i.co.kr;S.com.kakao.sdk.talk.extraparams=%7B%22client_id%22%3A%22502a11e55331d01839c364d642bdb0cd%22%2C%22redirect_uri%22%3A%22https%3A%2F%2Fwms.point-i.co.kr%2Fauth%2Fpoint%2Fcallback%22%2C%22response_type%22%3A%22code%22%2C%22auth_tran_id%22%3A%22ieb7bfeoc3j502a11e55331d01839c364d642bdb0cdlbvwpo2v%22%2C%22is_popup%22%3Atrue%7D;S.browser_fallback_url=https%3A%2F%2Fkauth.kakao.com%2Foauth%2Fauthorize%3Fclient_id%3D502a11e55331d01839c364d642bdb0cd%26redirect_uri%3Dhttps%253A%252F%252Fwms.point-i.co.kr%252Fauth%252Fpoint%252Fcallback%26response_type%3Dcode%26auth_tran_id%3Dieb7bfeoc3j502a11e55331d01839c364d642bdb0cdlbvwpo2v%26ka%3Dsdk%252F1.43.1%2520os%252Fjavascript%2520sdk_type%252Fjavascript%2520lang%252Fko-KR%2520device%252FLinux_aarch64%2520origin%252Fhttps%25253A%25252F%25252Fwms.point-i.co.kr%26is_popup%3Dfalse;end;";

      if (await canLaunchUrl(Uri.parse(value))) {
        await launchUrl(Uri.parse(value),);
        return;
      } else {
        showOkDialogBox(
            context:context,
            title: '확인',
            message: '해당 앱 설치 후 이용바랍니다.');
        return;
      }
    });

    return;
  }

  // webToAppMoim.postMessage("{command:'OK'}");
  JavascriptChannel fromApp(BuildContext context) {
    return JavascriptChannel(
        name: 'webToAppMoim',
        onMessageReceived: (JavascriptMessage message) {
          if (kDebugMode) {
            print("webToAppMoim(): message = ${message.message}");
          }
          dynamic param = jsonDecode(message.message)[0];
          //print("webToAppMoim() data="+param.toString());
          var cmd = param['command'];
          var token = param['token'];
          switch(cmd) {
            case "OK":
              _authResult(token);
              break;
            case "CANCEL":
              _authResult("");
              break;
            default:
              break;
          }
        }
    );
  }

  Future<void> appToWeb(
      String postCode,
      String address,
      String bname,
      String latitude, String longitude) async {
    await _webViewController.runJavascript("window.appToSetAddr('$postCode','$address', '$bname')");
  }

  void _authResult(String token) {
    Navigator.pop(context, token);
  }

  /*
  Future<bool> _canGoBack() async {
    return await _webViewController.canGoBack();
  }

  Future<void> _goBack() async {
    var flag = await _webViewController.canGoBack();
    if (flag) {
      await _webViewController.goBack();
    }
  }
  */

  Future<bool> _onBackPressed(BuildContext context) async {
    // var flag = await _canGoBack();
    // if (flag) {
    //   _goBack();
    // }
    // else {
    //   _authResult(false);
    // }
    return Future(() => false);
  }
}
