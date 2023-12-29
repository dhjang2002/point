// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point/cache/requestParam.dart';
import 'package:point/common/cardGoodsSqare.dart';
import 'package:point/common/cardPhoto.dart';
import 'package:point/constant/constant.dart';
import 'package:point/home/goodsDisplay.dart';
import 'package:point/models/kItemBanner.dart';
import 'package:point/models/kItemGoodsCategory.dart';
import 'package:point/models/kItemGoodsList.dart';
import 'package:point/models/kItemNotify.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/remote/remote.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class HomeViewPage extends StatefulWidget {
  final List<ItemGoodsCategory> category;
  //final List<ItemNotify> notifyItems;
  final Function() onDrawer;
  final Function() onNotice;
  final Function(int page) onPage;
  const HomeViewPage({Key? key,
    required this.category,
    //required this.notifyItems,
    required this.onDrawer,
    required this.onNotice,
    required this.onPage,
  }) : super(key: key);

  @override
  State<HomeViewPage> createState() => _HomeViewPageState();
}

class _HomeViewPageState extends State<HomeViewPage> {
  final GlobalKey _posKeyHome = GlobalKey();

  // 메인 광고 목록
  List<ItemBanner>    _bannerList = [];
  List<ItemGoodsList> _eventList = [];
  List<ItemGoodsList> _newList = [];

  late SessionData _session;

  @override
  void initState() {
    _session   = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() async {
      await requestData();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isInAsyncCall = false;
  void _showProgress(bool bShow) {
    setState(() {
      _isInAsyncCall = bShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      opacity: 0.0,
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height-60,
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  color: Colors.grey[100],
                  child: CustomScrollView(
                    slivers: [
                      _renderSliverAppbar(),
                      _renderWellcome(),
                      _todaysBanner(),
                      _renderTitle(_newList.isNotEmpty, 50,
                          "${_session.signInfo!.sName}님을 위한 신상품 소식",
                          "다까미아에서 적극 추천하는 상품", -1),
                      _renderGoodsItems(_newList),

                      _renderTitle(_eventList.isNotEmpty, 50,
                          "할인상품",
                          "행사기간동안만 진행하는 특사상품", 1),
                      _renderGoodsItems(_eventList),

                      _renderNotice(4),
                    ],
                  ),
                ),
              )
          ),
          Positioned(
              bottom: 50, right: 5,
              child: FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  onPressed: (){
                    Scrollable.ensureVisible(
                        _posKeyHome.currentContext!,
                        duration: const Duration(
                            milliseconds: moveMilisceond)
                    );
                  },
                  child: const Icon(Icons.arrow_upward,
                      color: Colors.black)
              )
          ),
        ],
      ),
    );
  }

  SliverList _renderNotice(int count) {
    int itemCount = _session.notifyItems.length;
    if(itemCount>3) {
      itemCount = 3;
    }
    return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 30),
            padding: const EdgeInsets.fromLTRB(10,10,10,20),
            width: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset((!_session.bNotice)
                          ? "assets/icon/icon_notice_off.png"
                          : "assets/icon/icon_notice_on.png",
                        height: 20, fit: BoxFit.fitHeight,
                      ),

                      const Text(" 공지사항", style: ItemBkB20,),
                      const Spacer(),
                      TextButton(
                          onPressed: (){
                            if(_session.notifyItems.length>itemCount) {
                              widget.onNotice();
                            }
                          },
                          child: (_session.notifyItems.length>itemCount)
                              ? const Text("공지 더보기", style: ItemB1N16)
                              : const Text("", style: ItemB1N16)
                      )
                    ],
                  ),
                ),
                const Divider(height: 1,),
                const SizedBox(height: 10,),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemCount,
                  itemBuilder: (BuildContext context, int index) {
                    ItemNotify item = _session.notifyItems[index];
                    return _ItemNotice(item);
                  },
                )
              ],
            ),
          )
        ]));
  }

  Widget _ItemNotice(ItemNotify item) {
    final span=TextSpan(text:item.tContent);
    final tp =TextPainter(text:span,maxLines: 3,textDirection: TextDirection.ltr);
    tp.layout(maxWidth: MediaQuery.of(context).size.width); // equals the parent screen width
    //print("tp.didExceedMaxLines=${tp.didExceedMaxLines}");

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Visibility(
                  visible: tp.didExceedMaxLines,//!item.showMore,
                  child: TextButton(
                      onPressed: (){
                        setState(() {
                          item.showMore = !item.showMore;
                        });
                      },
                      child: (item.showMore)
                          ? const Text("간략히")//Icons.keyboard_arrow_up_rounded
                          : const Text("펼치기"),//Icons.keyboard_arrow_down_outlined)
                  )
              ),
              const Spacer(),
              Text(item.dtRegDate, style: ItemBkN12,),
            ],
          ),
          const SizedBox(height: 5,),
          Text(item.sTitle, style: ItemBkB18, maxLines: 3,
            textAlign:TextAlign.justify,
            overflow: TextOverflow.ellipsis,),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,5,0,0),
            child: Text(item.tContent,
                style: ItemBkN14, maxLines: (item.showMore) ? 44 : 3,
                textAlign:TextAlign.justify,
                overflow: TextOverflow.ellipsis),
          ),
          const Divider(),
        ],
      ),
    );
  }

  SliverList _renderWellcome() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(_session.signInfo!.sName, style: ItemBkB20,),
                    const Text("님, 환영합니다.", style: ItemBkN20,),
                  ],
                ),
                const SizedBox(height: 5,),
                Row(
                  children: const [
                    Text("어떤 상품을 찾고 계신가요?", style: ItemBkN20,),
                  ],
                ),
              ],
            ),
          )
        ]));
  }

  SliverList _renderTitle(bool bShow, double topMargin, String title, String message, int page) {
    return SliverList(
        delegate: SliverChildListDelegate([
          Visibility(
              visible: bShow,
              child: Container(
                margin: EdgeInsets.only(top:topMargin),
                padding: const EdgeInsets.fromLTRB(15, 10, 5, 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: ItemBkB20),
                        SizedBox(height: 5,),
                        Text(message, style: ItemG1N14),
                      ],
                    ),
                    const Spacer(),
                    Visibility(
                      visible: page>=0,
                        child: TextButton(
                        onPressed: () {
                          widget.onPage(page);
                        },
                        child: const Text("상품 더보기", style: ItemB1N16))
                    )
                  ],
                )
              )
          ),
        ]));
  }

  SliverAppBar _renderSliverAppbar() {
    return SliverAppBar(
        key: _posKeyHome,
        floating: true,
        centerTitle: false,
        //pinned: true,
        title: Image.asset("assets/intro/intro_logo.png",
            height: 32, fit: BoxFit.fitHeight),
        actions: [
          // 검색
          Visibility(
            visible: true, //(_bSearch && _tabIndex != 0),
            child: IconButton(
                icon: Image.asset((!_session.bNotice)
                    ? "assets/icon/icon_notice_off.png"
                    : "assets/icon/icon_notice_on.png",
                  height: 24, fit: BoxFit.fitHeight,
                ),
                onPressed: () {
                  setState(() {
                    widget.onNotice();
                  });
                }),
          ),
          // 알림
          Visibility(
            visible: true, //(_tabIndex == 0), //(_m_isSigned && _bSearch),
            child: IconButton(
                icon: Image.asset(
                  "assets/icon/top_menu.png",
                  height: 32, fit: BoxFit.fitHeight,
                  color: Colors
                      .black, //(_tabIndex == 4) ? Colors.black : Colors.white,
                ),
                onPressed: () {
                  widget.onDrawer();
                }),
          ),
        ],
        expandedHeight: 70);
  }

  SliverToBoxAdapter _todaysBanner() {
    final szHeight = MediaQuery.of(context).size.width * .8;
    return SliverToBoxAdapter(
      child: Visibility(
        visible: _bannerList.isNotEmpty,
      child:SizedBox(
        height: szHeight,
        child: Scrollbar(
          //controller: _scrollControllerBannerList, //ScrollBar에 컨트롤러를 알려준다
          //thumbVisibility: false,
          //thickness: 5,   // 스크롤바의 두께를 지정한다
          child: ListView.builder(
              //controller: _scrollControllerBannerList,
              scrollDirection: Axis.horizontal,
              itemCount: _bannerList.length,
              itemBuilder: (context, index) {
                return _itemCardBanner(_bannerList[index]);
              }),
        ),
      ),
    ));
  }

  Widget _itemCardBanner(ItemBanner item) {
    final double imageWidth = MediaQuery.of(context).size.width;
    String url = "";
    if(item.sBannerFile.isNotEmpty) {
      url = "$SERVER/${item.sBannerFile}";
    }
    return SizedBox(
        width: imageWidth,
        child:CardPhoto(
          photoUrl: url,
          fit: BoxFit.fitHeight,
          radious: 0,
        )
    );
  }

  SliverToBoxAdapter _renderGoodsItems(final List<ItemGoodsList> items) {
    final double listHeight = getMainAxisExtent(context);
    //final imageHeight = MediaQuery.of(context).size.width * 0.6;
    final listWidth   = MediaQuery.of(context).size.width * 0.49;
    // final listHeight =
    //     MediaQuery.of(context).size.width * 0.6 + imageHeight * 0.6;
    return SliverToBoxAdapter(
      child: Visibility(
        visible: items.isNotEmpty,
          child:Container(
            padding: const EdgeInsets.only(bottom: 0, top: 0),
            margin: const EdgeInsets.only(bottom: 20),
            height: listHeight,
            color: Colors.white,
            child: Scrollbar(
              thickness: 3, // 스크롤바의 두께를 지정한다
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      //padding: const EdgeInsets.only(bottom: 10),
                      width: listWidth,
                      color: Colors.white,
                      child: CardGoodSqare(
                        margin:const EdgeInsets.only(bottom:0),
                        //padding:const EdgeInsets.fromLTRB(1, 0, 1, 10),
                        item: items[index],
                        onTab: (ItemGoodsList item) async {
                          _showGoods(item.lGoodsId);
                        },
                      )
                    );
                  }
              ),
            ),
          ),
      )
    );
  }

  void _showGoods(int lGoodsId) {
    Navigator.push(context,
      Transition(child: GoodsDisplay(lGoodsId: lGoodsId),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  // 서버에서 데이터를 가져온다.
  Future <void> requestData() async {
    _showProgress(true);

    await _reqBanner();

    _eventList = await getGoodsItems(RequestParam(isPromotion: "Y"));
    RequestParam newParam = RequestParam();
    newParam.setOrder("최신 상품순");
    _newList = await getGoodsItems(newParam);
    _showProgress(false);
  }

  Future<List<ItemGoodsList>> getGoodsItems(RequestParam param) async {
    List<ItemGoodsList> items = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/listGoods",
        params: param.toMap(),
        onResult: (dynamic data) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['status'] == "success") {
            var content = data['data'];
            if(content==null) {
              return items;
            }

            if(content is List) {
              items = ItemGoodsList.fromSnapshot(content);
            }
            else {
              items = ItemGoodsList.fromSnapshot([content]);
            }
          }
        },
        onError: (String error) {
        }
    );
    return items;
  }

  Future<void> _reqBanner() async {
    _bannerList = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/infoPointMain",
        params: {},
        onResult: (dynamic data) {

          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['status'] == "success") {
            var content = data['data'];
            if(content!=null) {
              if (content is List) {
                _bannerList = ItemBanner.fromSnapshot(content);
              }
              else {
                _bannerList = ItemBanner.fromSnapshot([content]);
              }
            }
          }
        },
        onError: (String error) {
          //showSnackbar(context, error);
        }
    );
  }
}
