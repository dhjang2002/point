// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:point/common/buttonSingle.dart';
import 'package:point/common/cardGoodsTile.dart';
import 'package:point/models/kItemGoodsList.dart';

const Color _colorGrayBack = Color(0xFFF4F4F4);

class _ContentView extends StatefulWidget {
  final String title;
  final double viewHeight;
  final List<ItemGoodsList> items;
  final Function(bool bDirty, ItemGoodsList item) onClose;
  const _ContentView({
    Key? key,
    required this.title,
    required this.viewHeight,
    required this.onClose,
    this.items = const [],

  }) : super(key: key);

  @override
  State<_ContentView> createState() => __ContentViewState();
}

class __ContentViewState extends State<_ContentView> {
  int iSelect = -1;

  //late SessionData _session;
  @override
  void initState() {
    //_session = Provider.of<SessionData>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorGrayBack,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: _colorGrayBack,
        title: Text(widget.title),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 28,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                }),
          ),
        ],
      ),
      body: Container(
          color: Colors.white,

          child:Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  height: widget.viewHeight,
                  child: SingleChildScrollView(
                    child:ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                              margin: EdgeInsets.fromLTRB(0,3,0,0),
                              child:CardGoodTile(
                                tileHeight: 110,
                                  item: widget.items[index],
                                  bSelected: (iSelect == index),
                                  onTab: (item){
                                    setState(() {
                                      iSelect = index;
                                    });
                                  }
                              )
                          ),
                          Divider(height: 1),
                        ],
                      );
                    },
                  )
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,left: 0, right: 0,
                  child:ButtonSingle(
                      visible: true,
                      isBottomPading: true,
                      text: "선택",
                      enable: iSelect>=0,
                      onClick: () {
                        Navigator.pop(context);
                        widget.onClose(true, widget.items[iSelect]);
                      }
                  ),
              ),
            ],
          )
      ),
    );
  }
}

Future<void> showGoodsSelect({
  required BuildContext context,
  required String title,
  required List<ItemGoodsList> items,
  required Function(bool bDirty, ItemGoodsList item) onResult}) {
  double viewHeight = MediaQuery.of(context).size.height * 0.8;
  return showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    useRootNavigator: false,
    isDismissible: true,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => true,
        child: SizedBox(
          height: viewHeight,
          child: _ContentView(
            title: title,
            viewHeight:viewHeight,
            items: items,
            onClose: (bDirty, items){
              onResult(bDirty, items);
            },
          ),
        ),
      );
    },
  );
}