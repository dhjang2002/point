
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point/common/cardDescriptionImage.dart';
import 'package:point/common/cardPhotoItem.dart';
import 'package:point/constant/constant.dart';
import 'package:point/models/kInfoGoods.dart';
import 'package:point/models/kItemStock.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/remote/remote.dart';
import 'package:point/utils/Launcher.dart';
import 'package:point/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GoodsDisplay extends StatefulWidget {
  final int lGoodsId;
  const GoodsDisplay({
    Key? key,
    required this.lGoodsId,
  }) : super(key: key);

  @override
  State<GoodsDisplay> createState() => _GoodsDisplayState();
}

class _GoodsDisplayState extends State<GoodsDisplay> {
  final GlobalKey _posKeyHome = GlobalKey();
  InfoGoods _info = InfoGoods();
  List<ItemStock> stockList = [];

  late SessionData _session;
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _requestGoodsInfo();
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

  Future <bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:ModalProgressHUD(
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
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: Container(
                        //padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        color: Colors.grey[100],
                        child: CustomScrollView(
                          slivers: [
                            _renderSliverAppbar(),
                            _renderGoodsTitle(),
                            _renderPhotoPage(),
                            _renderGoodsInfo(),
                            _renderDetailImage(),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          )
        ),
        floatingActionButton: (_info.sMallGoodsID.isNotEmpty)
            ? FloatingActionButton.extended(
            onPressed: () {
              _goLink(_info.sMallGoodsID);
            },
            label: Text("주문하기")
        ) : null,
    );
  }

  SliverAppBar _renderSliverAppbar() {
    return SliverAppBar(
        key: _posKeyHome,
        floating: true,
        centerTitle: false,
        //pinned: true,
        //title: const Text("상품정보"),
        leading: IconButton(
            icon: Image.asset(
              "assets/icon/top_back.png",
              height: 32,
              fit: BoxFit.fitHeight,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        actions: [

          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.black,
                  size: 26,
                ),
                onPressed: () {
                  _requestGoodsInfo();
                }),
          ),
        ],
        expandedHeight: 70);
  }

  SliverList _renderGoodsTitle() {
    String category = _info.sGoodsClassName1;
    if(_info.sGoodsClassName2.isNotEmpty) {
      category = "$category/${_info.sGoodsClassName2}";
    }
    if(_info.sGoodsClassName3.isNotEmpty) {
      category = "$category/${_info.sGoodsClassName3}";
    }

    return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: ItemG1N18,),
                Text(_info.sName, style: ItemBkB24,),
              ],
            ),
          ),
        ]));
  }

  SliverList _renderPhotoPage() {
    final double picHeight = MediaQuery.of(context).size.width * 1;
    return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            height: picHeight,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: CardPhotos(
              fit : BoxFit.fill,
              items: _info.photoList,
            ),
          ),
        ]));
  }

  SliverList _renderGoodsInfo() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const Text(
                  "상품정보",
                  style: ItemBkB18,
                ),
                const SizedBox(
                  height: 10,
                ),
                _itemRow(3, "상  품  명:", _info.sName, false),
                _itemRow(1, "바  코  드:", _info.sBarcode, false),
                _itemRow(1, "제  조  사:", _info.Maker, false),
                _itemRow(1, "판매상태:", _info.sState, false),
                _itemprice("판매가격:"),
                _itemRow(1, "재고상태:", _info.sShowStock, false),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ])
    );
  }

  SliverList _renderDetailImage() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Visibility(
            visible: _info.descriptionImageUrl.isNotEmpty,
            child: Container(
              height: _info.descriptionImageHeight,
              child: CardImageWebview(
                imageUrl: _info.descriptionImageUrl,
              ),
            ),
          )
        ])
    );
  }

  void _goLink(String linkId) {
    String url = "$URL_MALL/$linkId";
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    //showUrl(url);
  }

  Widget _itemRow(int maxLines, String label, String value, bool bLink) {
    return Container(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 68,
                child: Text(label,
                  style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.normal,
                    letterSpacing: -0.5,
                    height: 1.2,
                    color: Colors.grey,
                  ),
                )
            ),
            Expanded(
              child:GestureDetector(
                  onTap: () {
                    if(bLink && value.isNotEmpty) {
                      _goLink(value);
                    }
                  },
                  child: Container(
                      color: Colors.transparent,
                      child:Text(value,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                        style:TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          letterSpacing: -1.3,
                          height: 1.1,
                          color: (!bLink && value.isNotEmpty) ? Colors.black : Colors.blueAccent,
                        )
                      ))
              ),
            ),
          ],
        ));
  }
  Widget _itemprice(String label) {
    return Container(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 68,
                child: Text(label,
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.normal,
                      letterSpacing: -0.5,
                      height: 1.2,
                      color: Colors.grey,
                    ),
                )
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.0,
                            height: 1.2,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(text: "${currencyFormat(_info.mSalesPrice.toString())}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                            TextSpan(text: "원",
                                style: TextStyle(fontWeight: FontWeight.normal,
                                    color: Colors.grey)
                            ),
                          ]
                      )
                  ),
                ],
              )
            ),
          ],
        ));
  }

  Future <void> _requestGoodsInfo() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/infoGoods",
        params: {"lGoodsId": widget.lGoodsId },
        onError: (String error) {},
        onResult: (dynamic data) async {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['status'] == "success") {
            _info = InfoGoods.fromJson(data['data'][0]);
            await _info.setDescriptionImage(context);
          }
        },
    );
    _showProgress(false);
  }
}

