import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:point/cache/cacheGoodsList.dart';
import 'package:point/constant/constant.dart';
import 'package:point/firebase_options.dart';
import 'package:point/home/mainHome.dart';
import 'package:point/provider/sessionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';

Future <void> _onBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("_onBackgroundHandler() -----------------> ");
  }
  if(message.notification != null) {
    String action = "";
    if(message.data["action"] != null) {
      action = message.data["action"];
    }

    if (kDebugMode) {
      print("title=${message.notification!.title.toString()},\n"
          "body=${message.notification!.body.toString()},\n"
          "action=$action");
    }

    // push notification = push();
    // notification.initializeNotification();
    // notification.show(
    //     "B>"+message.notification!.title.toString(),
    //     message.notification!.body.toString());
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HttpOverrides.global = MyHttpOverrides();

  KakaoSdk.init(
    nativeAppKey: 'df7b8153a69473035d96730dee60e023',
    javaScriptAppKey: '502a11e55331d01839c364d642bdb0cd',
    loggingEnabled: true,
  );

  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionData()),
        ChangeNotifierProvider(create: (_) => CacheGoodList()),
      ],
      child: const AppHome(),
    ),
  );
}

class AppHome extends StatelessWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.1,
            ),
            child: child!,
          ),
          title: appName,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                actionsIconTheme: const IconThemeData(color: Colors.black),
                centerTitle: true,
                elevation: 0.0,
                titleTextStyle: TextStyle(fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.normal)
            ),
            // background Color
            backgroundColor: Colors.white,
            scaffoldBackgroundColor:Colors.white,
            primarySwatch:  Colors.indigo,
            primaryColor: Colors.red,
          ),

          initialRoute: '/',
          routes: {
            "/"  : (_) => const MainHome(),
            //"/home"  : (_) => const MainHome(),
          },
        );
      },
    );
  }
}

