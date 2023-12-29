// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, file_names
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point/common/cardBarcode.dart';
import 'package:point/common/cardFace.dart';
import 'package:point/common/dialogbox.dart';
import 'package:point/common/inputForm.dart';
import 'package:point/constant/constant.dart';
import 'package:point/home/popEditView.dart';
import 'package:point/models/kItemGoodsCategory.dart';
import 'package:point/models/memberInfo.dart';
import 'package:point/models/signInfo.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/remote/remote.dart';
import 'package:provider/provider.dart';

class MemberViewPage extends StatefulWidget {
  final List<ItemGoodsCategory> category;
  final Function() onDrawer;
  final Function() onNotice;
  const MemberViewPage({Key? key,
    required this.category,
    required this.onDrawer,
    required this.onNotice,
  }) : super(key: key);

  @override
  State<MemberViewPage> createState() => _MemberViewPageState();
}

class _MemberViewPageState extends State<MemberViewPage> {
  final GlobalKey _posKeyHome = GlobalKey();

  final List<EditViewItem> _sexItems = [
    EditViewItem(value: "남자", tag:"00"),
    EditViewItem(value: "여자", tag:"01"),
  ];

  List<EditViewItem> _storeItems = [];

  Uint8List? _barcodeData = null;

  String _joinCode = "";
  late SessionData _session;

  @override
  void initState() {
    _session   = Provider.of<SessionData>(context, listen: false);

    Future.microtask(() async {
      await _reqData();
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        opacity: 0.0,
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
                    //padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    color: Colors.grey[50],
                    child: CustomScrollView(
                      slivers: [
                        _renderSliverAppbar(),
                        _renderSign(),
                        _renderMember(),
                        _renderPoint(),
                        _renderNotMember(),
                      ],
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  SliverList _renderNotMember() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Visibility(
              visible: _session.signInfo!.lMemberID == 0,
              child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                const Text("회원가입 안내",
                  style: ItemBkB16,
                  textAlign: TextAlign.left,),
                Container(
                    padding:const EdgeInsets.fromLTRB(0,5,0,0),
                    child: const Text("기존 포인트낚시 매장회원 정보의 연동을 원하시는 분은 "
                        "대표번호: 051-326-8893 로 연락주시거나 "
                        "가입 매장에 문의 바랍니다.",
                      style: ItemBkN14,
                      textAlign: TextAlign.justify,
                    )
                ),

                const SizedBox(height: 20,),
                const Text("기존회원",
                  style: ItemBkB16,
                  textAlign: TextAlign.left,),
                Container(
                  margin: EdgeInsets.only(top:10),
                  padding: EdgeInsets.all(10),
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
                      const Text("회원코드",
                        style: ItemBkN14,
                        textAlign: TextAlign.left,),
                      Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: InputForm(
                            readOnly: false,
                            disable: false,
                            onlyDigit: true,
                            keyboardType: TextInputType.number,
                            valueText: _joinCode,
                            textStyle: ItemBkB24,
                            hintStyle: ItemG1N24,
                            hintText: '000000',
                            onChange: (String value) {
                              setState(() {
                                _joinCode = value;
                              });
                            },
                          )
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          SizedBox(
                              width: 160,
                              height: 44,
                              //padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                              child: OutlinedButton(
                                onPressed: () async {
                                  _reqJoin();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  side: const BorderSide(
                                      width: 1.0, color: ColorG4),
                                ),
                                child: const Text(
                                  "기존회원 연결",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          )
        ])
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
          // 알림
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

          Visibility(
            visible: true,
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

  SliverList _renderSign() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                    Text(_session.getMemberGrade(), style: ItemBkB14,),
                  ],
                ),
                ListTile(
                  tileColor: Colors.grey,
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  title: Row(
                    children: [
                      SizedBox(
                        width:56,
                        height: 56,
                        child: CardFace(photoUrl: ""),
                      ),

                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(_session.signInfo!.sName,
                                maxLines: 1,
                                style: ItemBkB20,
                                overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text("ID:${_session.signInfo!.sKakaoID}",
                                maxLines: 1,
                                style: ItemBkN14,
                                overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(_session.signInfo!.sMobile,
                            maxLines: 1,
                            style: ItemBkN14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: true,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
                      child: CardBarcode(
                        barcodeData: _barcodeData,
                        //_session.signInfo!.sKakaoID.toString(),
                      ),
                    )
                ),
              ],
            ),
          ),
        ]));
  }

  SliverList _renderMember() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Visibility(
            visible: _session.signInfo!.lMemberID != 0,
              child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                    Text(_session.memberInfo!.sState, style: ItemBkB14,),
                  ],
                ),
                ListTile(
                  tileColor: Colors.grey,
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _itemRow(false, "sName","고객명:", _session.memberInfo!.sName),
                      _itemRow(true,  "sGender","성별:", _session.memberInfo!.sGender),
                      _itemRow(true,  "sMobile","연락처:", _session.memberInfo!.sMobile),
                      _itemRow(true,  "sStoreName","주매장:", _session.memberInfo!.sStoreName),
                      //_itemRow(true,  "sAddress", "주소:", "대전시 서구 신갈마로 102"),
                    ],
                  ),
                ),
              ],
            ),
          )
          ),
        ]));
  }

  SliverList _renderPoint() {
    return SliverList(
        delegate: SliverChildListDelegate([
        Visibility(
          visible: _session.signInfo!.lMemberID != 0,
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                  children: const [
                    Icon(Icons.star, color: Colors.amber,),
                    Spacer(),
                    Text("포인트", style: ItemBkB14,),
                  ],
                ),
                ListTile(
                  tileColor: Colors.grey,
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _itemRow(false, "", "전체:", _session.memberInfo!.rTotalBonus.toString()),
                      _itemRow(false, "", "잔여:", _session.memberInfo!.rNowBonus.toString()),
                    ],
                  ),
                ),
              ],
            ),
          )
        ),
        ])
    );
  }

  Widget _itemRow(bool bEdit, String tag, String label, String value) {
    return Container(
        padding: (bEdit) ? EdgeInsets.zero : const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: ItemG1N14,
                )),
            Expanded(
              flex: 8,
              child:Container(
                      color: Colors.transparent,
                      child:Text(
                        value,
                        style: ItemBkN16,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ))
            ),
            Expanded(
              child: Visibility(
                visible: bEdit,
                child: IconButton(
                onPressed: () {
                  switch(tag) {
                    case "sGender": {
                      showEditItem(context: context,
                        title: label,
                        tag: tag, value: value,
                        ext:null,
                        items: _sexItems,
                        onResult: (bDirty, item, value, ext) {
                          _reqUpdate({"lMemberId":_session.signInfo!.lMemberID, "fGender":item.tag });
                        },
                      );
                      break;
                    }

                    case "sStoreName": {
                      showEditItem(context: context,
                        title: label,
                        tag: tag, value: value,
                        ext:null,
                        items: _storeItems,
                        onResult: (bDirty, item, value, ext) {
                          _reqUpdate({"lMemberId":_session.signInfo!.lMemberID, "lStoreId":item.tag });
                        },
                      );
                      break;
                    }

                    case "sMobile": {
                      showEditItem(context: context,
                        title: label,
                        tag: tag,
                        value: value,
                        ext:null,
                        items: [],
                        onResult: (bDirty, item, value, ext) {
                          _reqUpdate({
                            "lMemberId":_session.signInfo!.lMemberID,
                            "sMobile":value.trim() });
                        },
                      );
                      break;
                    }
                    case "sAddress": {
                      showEditItem(context: context,
                        title: label,
                        tag: tag,
                        value: value,
                        ext:"",
                        items: [],
                        onResult: (bDirty, item, value, ext) {  },
                      );
                      break;
                    }
                  }
                },
                icon: const Icon(Icons.edit),
                iconSize: 14,
                padding: EdgeInsets.zero,
              ),
              )
            ),
          ],
        ));
  }


  // 서버에서 데이터를 가져온다.
  Future <void> _reqData() async {
     _showProgress(true);
     await _reqStoreInfo();
     await _reqMemberInfo();
     await _reqMemberBarcode();
     _showProgress(false);
  }

  // 재고실사 데이터 저장
  Future <void> _reqUpdate(Map<String, dynamic> params) async {
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/updateMember",
        params: params,
        onResult: (dynamic params) async {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            await _reqMemberInfo();
            _session.notifyListeners();
          }
          else {
            showToastMessage(response['message']);
          }
        },
        onError: (String error) { }
    );
  }

  Future <void> _reqStoreInfo() async {
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/listStore",
        params: { },
        onResult: (dynamic data) {
          _showProgress(false);

          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['data'] != null) {
            var content = data['data'];
            _storeItems = EditViewItem.fromStoreSnapshot(content);
          }
        },
        onError: (String error) {}
    );
  }

  Future <void> _reqMemberInfo() async {
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "auth/token",
        params: {},
        onResult: (dynamic data) {

          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['status'] == "success") {
            MemberInfo member = MemberInfo();
            SignInfo sign = SignInfo.fromJson(data['data']['signInInfo']);
            if(sign.lMemberID != 0) {
              member = MemberInfo.fromJson(data['data']['userInfo']);
            }
            _session.signInfo   = sign;
            _session.memberInfo = member;
          }
        },
        onError: (String error) {}
    );
  }

  Future <void> _reqJoin() async {
    if(_joinCode.isEmpty) {
      showToastMessage("안내받은 코드를 입력해주세요.");
      return;
    }

    bool flag = await _reqMemberJoin();
    if(flag) {
      showToastMessage("회원 연결이 정상적으로 처리되었습니다.");
      await _reqData();
    }
  }

  /*
  /point/matchingMember
{ "sMemberNo" : "126457", "sMobile": "01020010937", "sKakaoId": "2557190055"}
   */
  Future <bool> _reqMemberJoin() async {
    bool flag = false;
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/matchingMember",
        params: {
          "sMemberNo": _joinCode,
          "sMobile":   _session.signInfo!.sMobile,
          "sKakaoId":  _session.signInfo!.sKakaoID
        },
        onError: (String error) {},
        onResult: (dynamic data) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }
          if (data['status'] == "success") {
            flag = true;
          } else {
            showOkDialogBox(
                context: context,
                title: "확인",
                message: data['message']
            );
          }
        },
    );
    _showProgress(false);
    return flag;
  }

  Future <void> _reqMemberBarcode() async {
    if(_session.signInfo!.lMemberID != 0) {
      return;
    }

    _barcodeData = null;
    _showProgress(true);
    await Remote.apiPost(
      context: context,
      session: _session,
      method: "point/getBarcode",
      params: {
        "lMemberId": _session.signInfo!.lMemberID,
      },
      onError: (String error) {},
      onResult: (dynamic data) {
        if (kDebugMode) {
          var logger = Logger();
          logger.d(data);
        }
        if (data['status'] == "success") {
            String barcode = data['data'].toString().trim();
            if(barcode.isNotEmpty) {
              _barcodeData = createBarcodeData(barcode);
            }
        } else {
          //showToastMessage(data['message']);
        }
      },
    );
    _showProgress(false);
  }

}
