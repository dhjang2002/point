// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, use_build_context_synchronously
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:point/auth/signing.dart';
import 'package:point/models/kItemNotify.dart';
import 'package:point/push/localNotification.dart';
import 'package:point/auth/snsLogin.dart';
import 'package:point/common/cardFace.dart';
import 'package:point/common/dialogbox.dart';
import 'package:point/constant/constant.dart';
import 'package:point/home/goodsSearchPage.dart';
import 'package:point/home/goodsViewPage.dart';
import 'package:point/home/homeViewPage.dart';
import 'package:point/home/memberViewPage.dart';
import 'package:point/models/kItemGoodsCategory.dart';
import 'package:point/models/signInfo.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/push/showNotify.dart';
import 'package:point/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  static const int tabCount = 5;
  final LocalNotification notification = LocalNotification();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();
  late final _tabController = TabController(length: 5, vsync: this);
  late SessionData _session;
  late DateTime _preBackpress;
  List<ItemGoodsCategory> _category = [];
  //List<ItemNotify> _notifyList = [];

  bool _bSigning = false;
  bool _bReady = false;

  int _tabIndex = 0;
  int _pageIndex = 0;
  int _backIndex = 0;
  bool _hideBottomBar = false;

  String _versionInfo = "";
  String _serverInfo = "";
  Future <void> setVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _versionInfo = "${packageInfo.version} (${packageInfo.buildNumber})";
    _serverInfo  = SERVER.split("//").elementAt(1);
    if (kDebugMode) {
      print("_versionInfo:$_versionInfo");
      print("_serverInfo:$_serverInfo");
    }
  }

  Future <void> procFirebaseMassing() async {
    if (kDebugMode) {
      print("procFirebaseMassing()::start.");
    }

    messaging.getToken().then((token) {
      if (kDebugMode) {
        print("procFirebaseMassing()::getToken(): ---- > $token");
      }
      _session.FirebaseToken = (token != null)  ? token : "";
    });

    // 사용자가 클릭한 메시지를 제공함.
    messaging.getInitialMessage().then((message) {
      if (kDebugMode) {
        print("getInitialMessage(user tab) -----------------> ");
      }

      if(message != null && message.notification != null) {
        String action = "";
        if(message.data["action"] != null) {
          action = message.data["action"];
        }

        if (kDebugMode) {
          print("title=${message.notification!.title.toString()},\n"
              "body=${message.notification!.body.toString()},\n"
              "action=$action");
        }
      }

      // if foreground state here.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("Foreground Status(active) -----------------> ");
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

          // _session.bNotice = true;
          // _session.notifyListeners();
          notification.show(
              message.notification!.title.toString(),
              message.notification!.body.toString()
          );
          _updateNotifyStatus();
        }
      });

      // 엡이 죽지않고 백그라운드 상태일때...
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        if (kDebugMode) {
          print("Background Status(alive) -----------------> ");
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

          notification.show(
              message.notification!.title.toString(),
              message.notification!.body.toString()
          );

          // _session.bNotice = true;
          // _session.notifyListeners();
          _updateNotifyStatus();
        }
      });
    });
  }

  Future <void> setFirebaseSubcribed() async {
    await FirebaseMessaging.instance.subscribeToTopic("ALL");
    /*
    String topic = _session.FireBaseTopic!;
    if (kDebugMode) {
      print("setFirebaseSubcribed($topic)");
    }

    if(_session.FireBaseTopic!.isNotEmpty
        && _session.FireBaseTopic != _session.FireBaseTopicSaved) {
      if (kDebugMode) {
        print("updated Topics .....");
      }

      await _session.setFirebaseTopic(_session.FireBaseTopic!);

      // 이전 구독정보 삭제
      //bool isValidTopic = RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(topic);
      // "본사(HD)", "직영점(SB)", "매출처(SS)", "매입처(RR)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("HD");    // "본사(HD)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("SB");    // "직영점(SB)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("SS");    // "매출처(SS)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("RR");    // "매입처(RR)"

      // 새 구독정보 등록
      if (_session.FireBaseTopic == "SR") {
        await FirebaseMessaging.instance.subscribeToTopic("SS");
        await FirebaseMessaging.instance.subscribeToTopic("RR");
      }
      else {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      }
    }
    */
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future <void> initDynamicLinks() async {
    print("start initDynamicLinks() ...........................................");
    dynamicLinks.onLink.listen((dynamicLinkData) {
      _showGoodsDetail(dynamicLinkData.link.path);
      //Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      //print('onLink error');
      print(error.message);
    });

    PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    Uri? deepLink = data?.link;
    if(deepLink != null) {
      _showGoodsDetail(deepLink.path);
    }
  }


  @override
  void initState() {
    _bReady = false;
    _preBackpress   = DateTime.now();
    _session = Provider.of<SessionData>(context, listen: false);
    _session.signInfo = SignInfo();

    Future.microtask(() async {
      WidgetsBinding.instance.addObserver(this);
      await notification.init();
      await notification.requestPermissions();
      await notification.cancel();
      await procFirebaseMassing();
      await setVersionInfo();
      await _session.loadData();

      //_session.Token = "574|0I75LD6wYQNGDKmc3dlFL7Kh1NXxI6xYT5EB5bW2";

      await _doLoginProc();
      await initDynamicLinks();

    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FlutterAppBadger.removeBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    _session = Provider.of<SessionData>(context, listen: true);
    if (!_bReady) {
      return Container(
          color: Colors.white,
          child: Center(
              child: ClipRect(
                child: Container(
                    //padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child:Image.asset(
                  "assets/icon/ic_launcher.png",
                  //width: 180,
                  height: 100,
                  fit: BoxFit.fitHeight,
                )),
              ))
      );
    }

    if(!_session.isSigned()) {
      Future.microtask(() async {
        await _doLoginProc();
      });
    }

    const double barItemImageHeight=20;
    return Scaffold(
      key: _scaffoldStateKey,
      endDrawer: _renderDrawer(),
      bottomNavigationBar: Visibility(
        visible: !_hideBottomBar,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          onTap: (int index) {
            if (_tabIndex == index || _tabIndex > tabCount - 1) {
              return;
            }
            _goPage(index);
          },

          currentIndex: _tabIndex,
          items: [
            BottomNavigationBarItem(
                label: "전체상품",
                icon: Container(
                  padding: const EdgeInsets.fromLTRB(5,5,5,10),
                    child:Image.asset(
                      (_tabIndex == 0)
                        ? "assets/icon/bottom_action_01_on.png"
                        : "assets/icon/bottom_action_01.png",
                  height: barItemImageHeight,
                  fit: BoxFit.fitHeight,
                ))
            ),
            BottomNavigationBarItem(
                label: "행사상품",
                icon: Container(
                    padding: const EdgeInsets.fromLTRB(5,5,5,10),
                    child:Image.asset(
                      (_tabIndex == 1)
                          ? "assets/icon/bottom_action_02_on.png"
                          : "assets/icon/bottom_action_02.png",
                      height: barItemImageHeight,
                      fit: BoxFit.fitHeight,
                    )
                )
            ),
            BottomNavigationBarItem(
                label: "홈",
                icon: Container(
                    padding: const EdgeInsets.fromLTRB(5,5,5,10),
                    child:Image.asset(
                      (_tabIndex == 2)
                          ? "assets/icon/bottom_action_03_on.png"
                          : "assets/icon/bottom_action_03.png",
                      height: barItemImageHeight,
                      fit: BoxFit.fitHeight,
                    )
                )
            ),
            BottomNavigationBarItem(
                label: "상품조회",
                icon: Container(
                    padding: const EdgeInsets.fromLTRB(5,5,5,10),
                    child:Image.asset(
                      (_tabIndex == 3)
                          ? "assets/icon/bottom_action_04_on.png"
                          : "assets/icon/bottom_action_04.png",
                      height: barItemImageHeight,
                      fit: BoxFit.fitHeight,
                    )
                )
            ),
            BottomNavigationBarItem(
                label: "마이페이지",
                icon: Container(
                    padding: const EdgeInsets.fromLTRB(5,5,5,10),
                    child:Image.asset(
                      (_tabIndex == 4)
                          ? "assets/icon/bottom_action_05_on.png"
                          : "assets/icon/bottom_action_05.png",
                      height: barItemImageHeight,
                      fit: BoxFit.fitHeight,
                    )
                )
            ),
          ],
        ),
      ),
        body: WillPopScope(
            onWillPop: onWillPop,
            child: _buildTabHome()
        ),
    );
  }

  Widget _buildTabHome() {
    if (!_bReady) {
      return Container();
    }
    return Container(
      margin: const EdgeInsets.only(bottom:0),
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          // 0 전체상품
          GoodsViewPage(
            sRange: "All",
            category:_category,
            onDrawer: () { _scaffoldStateKey.currentState!.openEndDrawer();},
            onNotice: () { _onNotice();},
          ),

          // 1: 할인상품
          GoodsViewPage(
            sRange: "Event",
            category:_category,
            onDrawer: () { _scaffoldStateKey.currentState!.openEndDrawer();},
            onNotice: () { _onNotice();},
          ),
          // 2: 홈
          HomeViewPage(
            category:_category,
            //notifyItems: _notifyList,
            onDrawer: () { _scaffoldStateKey.currentState!.openEndDrawer();},
            onNotice: () { _onNotice();},
            onPage: (int page) {
              _goPage(page);
            },
          ),

          // 3: 상품조회
          GoodsSearchPage(
            category:_category,
            onDrawer: () { _scaffoldStateKey.currentState!.openEndDrawer();},
            onNotice: () { _onNotice();},
          ),

          // 4: 마이베이지
          MemberViewPage(
            category:_category,
            onDrawer: () { _scaffoldStateKey.currentState!.openEndDrawer();},
            onNotice: () { _onNotice();},
          ),

        ],
      ),
    );
  }

  void _goPage(int index) {
    setState((){
      if (index < tabCount) {
        _hideBottomBar = false;
        _tabIndex  = index;
        _backIndex = index;
      } else {
        _hideBottomBar = true;
      }

      _pageIndex = index;
      _tabController.animateTo(index,
          duration: const Duration(milliseconds: 0), curve: Curves.ease);
    });
  }

  Widget _drowerItem({required String menuText, required String imagePath, required Function() onTap}){
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          child: Image.asset(
            imagePath,
            width: DrawerItemMenuIconSize,
            height: DrawerItemMenuIconSize,
            color: Colors.white,
          ),
        ),
        title: Text(
          menuText,
          style: ItemBkN18,
        ),
        onTap: () => onTap(),
      ),
    );
  }

  Widget _renderDrawer() {
    final String axisInfo = getMainAxisInfo(context);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            // menu
            Positioned(
              left: 0,right: 0,top: 0,bottom: 130,
                child: SingleChildScrollView(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 1. title bar
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(15, 10, 0, 20),
                            child: Row(
                              children: [
                                Image.asset("assets/intro/intro_logo.png",
                                    height: 32, fit: BoxFit.fitHeight),
                                const Spacer(),
                                IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 24,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    }),
                              ],
                            ),
                          ),

                          // 2. user info
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  offset: const Offset(0, 0.5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(_session.getMemberGrade(),
                                      style: ItemBkB14,),
                                  ],
                                ),
                                ListTile(
                                  tileColor: Colors.grey,
                                  contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width:56,
                                        height: 56,
                                        child: CardFace(photoUrl: ""),
                                      ),

                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _session.signInfo!.sName,
                                            maxLines: 2,
                                            style: ItemBkN18,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "ID:${_session.signInfo!.sKakaoID.toString()}",
                                            maxLines: 1,
                                            style: ItemBkN14,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25,),
                          _drowerItem(
                              menuText: '로그아웃',
                              imagePath: 'assets/icon/quick_icon01.png',
                              onTap: () {
                                Navigator.pop(context);
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  _doLogout();
                                });
                              }),
                          _drowerItem(
                              menuText: '공지사항',
                              imagePath: 'assets/icon/quick_icon05.png',
                              onTap: () {
                                _onNotice();
                              }),
                          _drowerItem(
                              menuText: '상품검색',
                              imagePath: 'assets/icon/quick_icon02.png',
                              onTap: () {
                                _goPage(3);
                                Future.microtask(() {
                                  Navigator.pop(context);
                                });
                              }),
                          _drowerItem(
                              menuText: '행사상품',
                              imagePath: 'assets/icon/quick_icon03.png',
                              onTap: () {
                                _goPage(1);
                                Future.microtask(() {
                                  Navigator.pop(context);
                                });
                              }),
                          _drowerItem(
                              menuText: '내정보',
                              imagePath: 'assets/icon/quick_icon04.png',
                              onTap: () {
                                _goPage(4);
                                Future.microtask(() {
                                  Navigator.pop(context);
                                });
                              }),
                        ],
                      ),
                    )
                )
            ),
            // version info
            Positioned(
              bottom:0,left: 0,right: 0,
              child: Container(
                width: double.infinity,
                height: 130,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("빌드정보", style: ItemBkB14,),
                    Text("앱버전: $_versionInfo", style: ItemBkN12,),
                    Text("서버: $_serverInfo", style: ItemBkN12),
                    Text("빌드일자: $buildDate", style: ItemBkN12),
                    Text("실행환경: $axisInfo", style: ItemBkN12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future <void> _doLoginProc() async {
    if(_bSigning) {
      return;
    }
    _bSigning = true;
    await SigningWithToken(context, _session);
    if(!_session.isSigned()) {
      await _doLogin();
    }

    // post login process....
    await setFirebaseSubcribed();
    await _reqGoodCategory();
    await _updateNotifyStatus();

    _bSigning = false;
    setState(() {
      _bReady = true;
      _goPage(2);
    });
  }

  Future <void> _doLogin() async {
    await Navigator.push(context,
      Transition(child: const SnsLogin(),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  Future <void> _doLogout() async {
    if(_session.isSigned()) {
      await Remote.apiPost(
          context: context,
          session: _session,
          method: "auth/logout",
          params: {},
          onResult: (dynamic data) {
            if (data['status'] == "success") {
              _session.setLogout();
              setState(() {});
            } else {
              showToastMessage(data['message']);
            }
          },
          onError: (String error) {}
      );
    }
  }

  // backKey event 처리
  Future <bool> onWillPop() async {
    if (_closeDrower()) {
      _closeDrower();
      return false;
    }

    if(_pageIndex != 2) {
      if (_pageIndex > _tabIndex) {
        _goPage(_backIndex);
        return false;
      }
      else {
        if (_tabIndex != 2) {
          _goPage(2);
          return false;
        }
      }
    }

    //print("check Clossing....");
    final timegap = DateTime.now().difference(_preBackpress);
    final cantExit = timegap >= const Duration(seconds: 2);
    _preBackpress = DateTime.now();

    //print("check Clossing....cantExit[$cantExit]");

    if (cantExit) {
      showToastMessage("한번 더 누르면 앱을 종료합니다.");
      return false; // false will do nothing when back press
    }

    Fluttertoast.cancel();
    return true; // true will exit the app
  }

  // 메뉴바 닫기
  bool _closeDrower() {
    if (_scaffoldStateKey.currentState!.isEndDrawerOpen) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  Future<void> _onNotice() async {
    await notification.cancel();
    await Navigator.push(
      context,
      Transition(
          child: const ShowNotify(),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    _session.bNotice = false;
    _session.notifyListeners();
    _updateNotifyStatus();
  }

  Future <void> _reqGoodCategory() async {
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/listCategory",
        params: {
          "lPageNo": "1",  "lRowNo" : "4"
        },
        onResult: (dynamic data) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

          if (data['status'] == "success") {
            _category = ItemGoodsCategory.fromSnapshot(data['data']);
            _category.insert(0, ItemGoodsCategory(sName: "전체", sCode: ""));
            setState(() {

            });
          }
        },
        onError: (String error) {}
    );
  }

  Future<void> _updateNotifyStatus() async {
    _session.bNotice = false;
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/listNotice",
        params: {"sTopic": _session.FireBaseTopic},
        onResult: (dynamic data) async {
          if (data['data'] != null) {
            var content = data['data'];
            _session.notifyItems = ItemNotify.fromSnapshot(content);
            if (_session.notifyItems.isNotEmpty) {
              String noticeId = _session.notifyItems[0].lNoticeID.toString();
              if (noticeId != _session.NoticeId) {
                _session.bNotice = true;
                _session.notifyListeners();
              }
            }
            setState(() {});
          }
        },
        onError: (String error) {});

  }

  void _showGoodsDetail(String path) {
    print(path);
    showToastMessage(path);
  }
}
