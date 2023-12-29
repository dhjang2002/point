
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:point/common/cardPhoto.dart';
import 'package:point/constant/constant.dart';
import 'package:point/models/kItemGoodsList.dart';
import 'package:point/utils/utils.dart';

class CardGoodTile extends StatelessWidget {
  final ItemGoodsList item;
  final bool? bSelected;
  final double? tileHeight;
  final Function(ItemGoodsList item)? onTab;
  final Function(ItemGoodsList item)? onFavorites;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  const CardGoodTile({
    Key? key,
    required this.item,
    this.tileHeight = 130,
    this.bSelected = false,
    this.onFavorites,
    this.onTab,
    this.margin  = const EdgeInsets.fromLTRB(1, 1, 1, 1),
    this.padding = const EdgeInsets.fromLTRB(0, 0, 3, 5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return _cardItem(context);
  }

  Widget _cardItem(BuildContext context) {
    String sale_price   = "${currencyFormat(item.mSalesPrice.toString())}원";
    String normal_price = currencyFormat(item.mStorePrice.toString());
    String imageUrl = "";
    if(item.sMainPicture.isNotEmpty) {
      imageUrl = "$URL_IMAGE${item.sMainPicture}";
    }
    String category = item.sGoodsClassName1;
    if(item.sGoodsClassName2.isNotEmpty) {
      category = "$category/${item.sGoodsClassName2}";
    }
    if(item.sGoodsClassName3.isNotEmpty) {
      category = "$category/${item.sGoodsClassName3}";
    }

    return GestureDetector(
      onTap: (){
        if(onTab != null) {
          onTab!(item);
        }
      },
      child: Container(
        height: tileHeight,
        decoration: BoxDecoration(
          color: (bSelected!)? Colors.amber[50]: Colors.transparent,
            border: Border.all(
              width: 2,
              color: (bSelected!)? Colors.amber: Colors.white,
            ),
        ),
        // margin: margin,
        // padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 상품사진
            Container(
                height: tileHeight,
                width:  tileHeight,
                //color:Colors.black,
                child: CardPhoto(
                  radious: 0,
                  photoUrl: imageUrl, fit: BoxFit.fill,)
            ),
            Expanded(
                child: Container(
                    //color: Colors.amber,
                    //margin: margin,
                    padding: padding,
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Container(
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 3),
                            child: _labelCard(
                                isFavorites: false,
                                isGreyColor: true,
                                imagePath: "assets/icon/icon_grp_03.png",
                                value:category)
                        ),
                        // 상품명
                        Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(item.sName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                //textAlign:TextAlign.justify,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: -1.7,
                                  height: 1.1, color:
                                  Colors.black,
                                )
                            )
                        ),
                        const Spacer(),
                        // 가격정보
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              Expanded(flex: 6, child: Text(sale_price, maxLines: 1,
                                  overflow: TextOverflow.ellipsis, style: ItemBkB18),),
                              Expanded(flex: 4, child: Text(
                                normal_price,
                                style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.2,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.red,
                                    decorationStyle: TextDecorationStyle.double,
                                    decorationThickness: 1),
                              )),
                            ],
                          ),
                        ),

                        Spacer(),
                        // 즐겨찾기
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 5, bottom:2, top:0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child:
                                  _labelCard(
                                      isFavorites: false,
                                      imagePath: "assets/icon/icon_grp_02.png",
                                      value:item.Maker)),
                              Expanded(
                                  flex: 4,
                                  child:
                                  _labelCard(
                                      isFavorites: true,
                                      isGreyColor: false,
                                      imagePath: "assets/icon/icon_grp_03.png",
                                      value:item.sState)),

                            ],
                          ),
                        ),
                      ],
                    )
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelCard({
    required isFavorites,
    required String imagePath,
    required String value,
    bool? isBold=false,
    bool? isGreyColor=false,
  }) {
    TextStyle style = ItemBkN12;
    if(isBold!) {
      style = ItemBkB12;
    }
    if(isGreyColor!) {
      style = ItemG1N12;
    }

    return Container(
      //padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
      //color: Colors.amber[100],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if(isFavorites) {
                if(onFavorites != null) {
                  onFavorites!(item);
                }
              }
            },
            child: Container(
                margin: EdgeInsets.only(top:3),
                width: CardItemIconSize,
                height: CardItemIconSize,
                child: Image.asset(imagePath,
                  width: CardItemIconSize,
                  height: CardItemIconSize,
                  //color: (isRedColor)? Colors.red : Colors.amber
                )
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
              child: Text(value, maxLines: 1,
            style: style,
            overflow: TextOverflow.ellipsis,)),
        ],
      ),
    );
  }
}
