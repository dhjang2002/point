// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, file_names
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point/cache/cacheGoodsList.dart';
import 'package:point/cache/requestParam.dart';
import 'package:point/common/cardGoodsSqare.dart';
import 'package:point/common/cardTabbar.dart';
import 'package:point/constant/constant.dart';
import 'package:point/home/goodsDisplay.dart';
import 'package:point/models/kItemGoodsCategory.dart';
import 'package:point/models/kItemGoodsList.dart';
import 'package:point/provider/sessionData.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class GoodsViewPage extends StatefulWidget {
  final String sRange;
  final List<ItemGoodsCategory> category;
  final Function() onDrawer;
  final Function() onNotice;
  const GoodsViewPage({Key? key,
    required this.sRange,
    required this.category,
    required this.onDrawer,
    required this.onNotice,
  }) : super(key: key);

  @override
  State<GoodsViewPage> createState() => _GoodsViewPageState();
}

class _GoodsViewPageState extends State<GoodsViewPage> {
  final GlobalKey _posKeyHome = GlobalKey();
  final ScrollController _listScrollController = ScrollController();

  late RequestParam _reqParam;
  late CacheGoodList _cacheData;

  late SessionData _session;
  bool isDisposed = false;
  @override
  void initState() {
    _session   = Provider.of<SessionData>(context, listen: false);
    print("_session.bNotice=${_session.bNotice}");

    _cacheData = Provider.of<CacheGoodList>(context, listen: false);
    _cacheData.clear();
    _reqParam = RequestParam();
    _reqParam.setSession(_session);
    if(widget.sRange=="Event") {
      _reqParam.setPromotion();
    }

    Future.microtask(() async {
      await requestData();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
    _listScrollController.dispose();
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
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height-60,
                    width: double.infinity,
                    child: Container(
                      //padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: CustomScrollView(
                        slivers: [
                          _renderSliverAppbar(),
                          _renderCategory(),
                          _renderOrderInfo(),
                          _todaysPopular(),
                        ],
                      ),
                    ),
                  )),
              Align(
                  alignment: (_cacheData.isFirst)
                      ? Alignment.center
                      : Alignment.bottomCenter,
                  //left: 0,right: 0, bottom: 0,
                  child: Visibility(
                    visible: _cacheData.loading,
                    child: Container(
                      width: double.infinity,
                      height: 25,
                      color: Colors.transparent,
                      margin: const EdgeInsets.only(bottom: 5),
                      child: (_cacheData.hasMore)
                          ? const Center(
                          child: const SizedBox(
                              width: 25,
                              child: const CircularProgressIndicator()))
                          : const Center(child: Icon(Icons.arrow_drop_up)),
                    ),
                  )),
              Positioned(
                bottom: 50, right: 5,
                  child: FloatingActionButton.small(
                    child: const Icon(Icons.arrow_upward,
                        color: Colors.black),
                      backgroundColor: Colors.white,
                      onPressed: (){
                        Scrollable.ensureVisible(
                            _posKeyHome.currentContext!,
                            duration: const Duration(
                                milliseconds: moveMilisceond)
                        );
                      }
                  )
              ),
            ],
          ),
      );
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

  SliverList _renderCategory() {
    return SliverList(
        delegate: SliverChildListDelegate([
          CardTabbar(
            items: widget.category,
            onChange: (item) {
            print("${item.sCode}-${item.sName}");
            if(_reqParam.category != item.sCode) {
              _reqParam.setCategory(item.sCode);
              _requestFirst();
            }
          },)
        ]));
  }

  SliverList _renderOrderInfo() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Visibility(
              visible: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(_reqParam.orderValue, style: ItemBkB20),
                        const SizedBox(width: 10),
                        Text(_reqParam.orderDesc, style: ItemG1N16),
                        const Spacer(),
                        PopupMenuButton<String>(
                          // icon: Container(
                          //     color: Colors.black,
                          //     child: const Icon(Icons.add, color: Colors.white,)),
                          onSelected: (String value) {
                            FocusScope.of(context).unfocus();
                            if(value != _reqParam.orderValue) {
                              _reqParam.setOrder(value);
                              _requestFirst();
                            }
                          },
                          itemBuilder: (BuildContext context) => _reqParam.orderList.map((value) => PopupMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                              .toList(),
                        )
                      ],
                    ),
                    //const Divider(height: 1,),
                  ],
                    ),
              )
          ),
        ]));
  }

  SliverGrid _todaysPopular() {
    _cacheData = Provider.of<CacheGoodList>(context, listen: true);
    final double mainAxisExtent = getMainAxisExtent(context);
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: mainAxisExtent,
        //childAspectRatio: 0.48,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (_cacheData.cache.length > 3 && index+1 == _cacheData.cache.length) {
            if (!_cacheData.loading && _cacheData.hasMore) {
              Future.microtask(() async {
                await _requestMore();
              });
            }
          }

          return CardGoodSqare(
            item: _cacheData.cache[index],
            onFavorites: (ItemGoodsList item) {},
            onTab: (ItemGoodsList item) async {
              _showGoods(item.lGoodsId);
            },
          );
        },
        childCount: _cacheData.cache.length,
      ),
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
    _requestFirst();
  }

  // 서버에서 데이터를 가져온다.
  Future <void> _requestFirst() async {
    await _cacheData.requestFrom(context: context, param: _reqParam, first: true);
    //listScrollController.jumpTo(0);
  }

  Future <void> _requestMore() async {
    if(isDisposed) {
      return;
    }
    await _cacheData.requestFrom(context: context, param: _reqParam, first: false);
  }
}
