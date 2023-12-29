// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point/constant/constant.dart';
import 'package:point/models/kItemNotify.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/remote/remote.dart';
import 'package:provider/provider.dart';

class ShowNotify extends StatefulWidget {
  const ShowNotify({Key? key}) : super(key: key);

  @override
  State<ShowNotify> createState() => _ShowNotifyState();
}

class _ShowNotifyState extends State<ShowNotify> {
  List<ItemNotify> _itemList = [];

  late SessionData _session;
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqNotice();
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("알림"),
          leading: IconButton(
              icon: Image.asset(
                "assets/icon/top_back.png",
                height: 32,
                fit: BoxFit.fitHeight,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
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
                    _reqNotice();
                  }),
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          child: Container(color: Colors.white, child: _renderBody()),
        ));
  }

  Widget _renderBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Row(
            children: [
              const Spacer(),
              const Text("카운트 :  ", style: ItemBkN14,),
              Text("${_itemList.length}", style: ItemBkB16,),
            ],
          ),
        ),
        const Divider(height: 5,),
        Expanded(
            child: ListView.builder(
                itemCount: _itemList.length,
                itemBuilder: (context, index) {
                  return _ItemNotice(_itemList[index]);
                }
            )
        ),
      ],
    );
  }

  Widget _ItemNotice(ItemNotify item) {
    final span=TextSpan(text:item.tContent);
    final tp =TextPainter(text:span,maxLines: 3,textDirection: TextDirection.ltr);
    tp.layout(maxWidth: MediaQuery.of(context).size.width); // equals the parent screen width
    //print("tp.didExceedMaxLines=${tp.didExceedMaxLines}");
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.dtRegDate, style: ItemBkN12,),
              const Spacer(),
              Visibility(
                  visible: tp.didExceedMaxLines,//!item.showMore,
                  child: TextButton(
                          onPressed: (){
                            setState(() {
                              item.showMore = !item.showMore;
                            });
                          },
                          child: Icon((item.showMore)
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_outlined)
                      )
              ),
            ],
          ),
          SizedBox(height: 5,),
          Text(item.sTitle, style: ItemBkB18, maxLines: 3,
            textAlign:TextAlign.justify,
            overflow: TextOverflow.ellipsis,),
          Padding(
            padding: EdgeInsets.fromLTRB(0,5,0,0),
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

  Future<void> _reqNotice() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/listNotice",
        params: {
          "lPageNo": "1",  "lRowNo" : "32"
        },
        onResult: (dynamic data) async {
          _showProgress(false);
          if (data['data'] != null) {
            var content = data['data'];
            _itemList = ItemNotify.fromSnapshot(content);
            if(_itemList.isNotEmpty) {
              String noticeId = _itemList[0].lNoticeID.toString();
              if(noticeId != _session.NoticeId) {
                await _session.setNoticeId(noticeId);
                _session.notifyListeners();
              }
            }
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }
}
