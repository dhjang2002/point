
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:point/common/cardPhoto.dart';
import 'package:point/constant/constant.dart';
import 'package:point/models/kItemGoodsList.dart';
import 'package:point/utils/utils.dart';

class CardGoodSqare extends StatelessWidget {
  final ItemGoodsList item;
  final Function(ItemGoodsList item) onTab;
  final Function(ItemGoodsList item)? onFavorites;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  const CardGoodSqare({
    Key? key,
    required this.item,
    required this.onTab,
    this.onFavorites,
    this.margin  = const EdgeInsets.fromLTRB(1, 1, 1, 1),
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, 15),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return _cardItem(context);
  }

  Widget _cardItem(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.width / 2 * 0.9;
    String sale_price   = "${currencyFormat(item.mSalesPrice.toString())}원";
    String normal_price = currencyFormat(item.mStorePrice.toString());
    // if(item.mPromotePrice>=0) {
    //   sale_price = "${currencyFormat(item.mPromotePrice.toString())}원";
    // }
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
      onTap: (){ onTab(item); },
      child: Container(
        color: Colors.transparent,
        margin: margin,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품사진
            SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: CardPhoto(photoUrl: imageUrl, fit: BoxFit.fill,)),

            // Category
            Container(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                child: _labelCard(
                    isFavorites: false,
                    isGreyColor: true,
                    imagePath: "assets/icon/icon_grp_03.png",
                    value:category)
            ),

            // 상품명
            Container(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Text(item.sName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        letterSpacing: -1.5,
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
            const Spacer(),
            // 즐겨찾기
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom:0, top:0),
              child: Row(
                children: [
                  Expanded(
                      flex: 6,
                      child:
                      _labelCard(
                          isFavorites: false,
                          imagePath: "assets/icon/icon_grp_02.png",
                          value:item.Maker)
                  ),
                  Expanded(
                      flex: 4,
                      child:
                      _labelCard(
                          isFavorites: false,
                          imagePath: "assets/icon/icon_grp_04.png",
                          value:item.sState)
                  ),
                ],
              ),
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
      //padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if(isFavorites && onFavorites != null) {
                onFavorites!(item);
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
          const SizedBox(width: 3),
          Expanded(
              child: Text(value, maxLines: 1,
            style: style,
            overflow: TextOverflow.ellipsis,)),
        ],
      ),
    );
  }
}
