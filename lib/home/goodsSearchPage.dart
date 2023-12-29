// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point/cache/cacheGoodsList.dart';
import 'package:point/cache/requestParam.dart';
import 'package:point/common/cardGoodsTile.dart';
import 'package:point/common/cardTabbar.dart';
import 'package:point/common/dialogbox.dart';
import 'package:point/common/scanBarcode.dart';
import 'package:point/common/searchForm.dart';
import 'package:point/constant/constant.dart';
import 'package:point/home/goodsDisplay.dart';
import 'package:point/home/popGoodsSelect.dart';
import 'package:point/models/kItemGoodsCategory.dart';
import 'package:point/models/kItemGoodsList.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/remote/remote.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class GoodsSearchPage extends StatefulWidget {
  final List<ItemGoodsCategory> category;
  final Function() onDrawer;
  final Function() onNotice;
  const GoodsSearchPage({Key? key,
    required this.category,
    required this.onDrawer,
    required this.onNotice,
  }) : super(key: key);

  @override
  State<GoodsSearchPage> createState() => _GoodsSearchPageState();
}

class _GoodsSearchPageState extends State<GoodsSearchPage> {
  final GlobalKey _posKeyHome = GlobalKey();
  late RequestParam _reqParam;
  late CacheGoodList _cacheData;
  String _findValue = "";
  bool isDisposed = false;
  late SessionData _session;

  @override
  void initState() {
    _session   = Provider.of<SessionData>(context, listen: false);
    _cacheData = Provider.of<CacheGoodList>(context, listen: false);
    _cacheData.clear();
    _reqParam = RequestParam();
    _reqParam.setSession(_session);

    Future.microtask(() async {
      await requestData();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  final bool _isInAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    _cacheData = Provider.of<CacheGoodList>(context, listen: true);
    return ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      opacity: 0.0,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height-52,
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: CustomScrollView(
                      slivers: [
                        _renderSliverAppbar(),
                        _renderSearchBar(),
                        _renderOrderInfo(),
                        _renderGoodsItems(),
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
      )
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
                  FocusScope.of(context).unfocus();
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
                  FocusScope.of(context).unfocus();
                  widget.onDrawer();
                }),
          ),
        ],
        expandedHeight: 70);
  }

  SliverList _renderSearchBar() {
    return SliverList(
        delegate: SliverChildListDelegate([
        Container(
          margin: const EdgeInsets.all(10),
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
              const SizedBox(height: 25,),
              Row(
                children: [
                  const Text("상품검색", style: ItemBkN16,),
                  const Text("   | ", style: ItemBkN16,),
                  TextButton(onPressed: () {
                      _showBarcodeScan();
                    },
                    child: Row(
                      children: [
                        Image.asset("assets/icon/icon_barcode.png",
                          height: 14, fit: BoxFit.fitHeight, color: Colors.blue,),
                        const Text(" 바코드검색", style: ItemB1N16),
                      ],
                    )
                  ),
                ],
              ),

              Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child:CardTabbar(
                    items: widget.category,
                    onChange: (item) {
                      print("${item.sCode}-${item.sName}");
                      if(_reqParam.category != item.sCode) {
                        _reqParam.setCategory(item.sCode);
                        _requestFirst();
                      }
                    },)
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SearchForm(
                        readOnly: false,
                        valueText: "",
                        suffixIcon: const Icon(
                          Icons.search_outlined,
                          color: Colors.black,
                          size: 28,
                        ),
                        hintText: '상품명',
                        onCreated: (TextEditingController controller) {
                          //_findValue_controller = controller;
                        },
                        onChange: (String value) {
                          _findValue = value.trim();
                        },
                        onSummit: (String value) {
                          _findValue = value.trim();
                          if(_findValue.length>1 && _findValue != _reqParam.keyword) {
                            _reqParam.setKeyword(_findValue);
                            _requestFirst();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        ]));
  }
  SliverList _renderOrderInfo() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Visibility(
              visible: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 35, 5, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_reqParam.orderValue, style: ItemBkB20),
                            Text(_reqParam.orderDesc, style: ItemG1N16),
                          ],
                        ),

                        const Spacer(),
                        PopupMenuButton<String>(
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
                    const Divider(height: 1,),
                  ],
                ),
              )
          ),
        ]));
  }

  /*
  SliverList _renderTitle(bool visiable, String title, String message) {
    return SliverList(
        delegate: SliverChildListDelegate([
          Visibility(
              visible: visiable,
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 35, 5, 10),
                child: Row(
                  children: [
                    Text(title, style: ItemBkB20),
                    const SizedBox(width: 10),
                    Text(message, style: ItemG1N16)
                  ],
                ),
              )
          ),
        ]));
  }
  */

  SliverGrid _renderGoodsItems() {
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      mainAxisExtent = 110;
    } else if(rt<1.55) {
      mainAxisExtent = 110;
    } else if(rt<2.20) {
      mainAxisExtent = 124;
    } else if(rt<2.70) {
      mainAxisExtent = 124;
    }

    //final double mainAxisExtent = 124;//getMainAxisExtent(context);
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: mainAxisExtent,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (_cacheData.cache.length > 3 &&
              index+1 == _cacheData.cache.length) {
            if (!_cacheData.loading && _cacheData.hasMore) {
              Future.microtask(() {
                _requestMore();
              });
            }
          }
          // return Container(
          //   margin: EdgeInsets.all(1),
          //   color: Colors.amber,
          // );
          return Column(
            children: [
              CardGoodTile(
                item: _cacheData.cache[index],
                tileHeight: mainAxisExtent,
                onTab: (ItemGoodsList item) async {
                  FocusScope.of(context).unfocus();
                  _showGoods(item.lGoodsId);
                },
              ),
            ],
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
  }

  Future <void> _requestMore() async {
    if(isDisposed) {
      return;
    }
    await _cacheData.requestFrom(context: context, param: _reqParam, first: false);
  }

  Future<void> _showBarcodeScan() async {
    showBottomScaned(context: context,
        onResult: (String barcode) async {
      if(barcode.isNotEmpty) {
        if(barcode.length>10) {
          var items = await geItems(barcode);
          if(items.isNotEmpty) {
            if (items.length == 1) {
              _showGoods(items[0].lGoodsId);
            }
            else {
              showGoodsSelect(context: context,
                  title: '상품선택',
                  items: items,
                  onResult: (bool bDirty, ItemGoodsList item) {
                    _showGoods(item.lGoodsId);
                  }
              );
            }
          }
          else {
            showToastMessage("상품 바코드를 스캔하세요.");
          }
        }
        else {
          showToastMessage("상품 바코드를 스캔하세요.");
        }
      }
    });
  }

  Future<List<ItemGoodsList>> geItems(String barcode) async {
    List<ItemGoodsList> items = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/listGoods",
        params: {"sBarcode":barcode},
        onResult: (dynamic data) {

          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

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
        onError: (String error) {}
    );
    return items;
  }
}
