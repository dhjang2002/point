// ignore_for_file: non_constant_identifier_names, file_names
import 'package:flutter/material.dart';
import 'package:point/common/cardDescriptionImage.dart';
import 'package:point/common/cardPhotoItem.dart';
import 'package:point/models/kGoodsFiles.dart';

import '../constant/constant.dart';

class InfoGoods {
  String  sName;              // 상품명
  String  sBarcode;           // 상품 바코드
  String  Maker;
  String  sGoodsClassName1;   // 상품타입
  String  sGoodsClassName2;   // 상품타입
  String  sGoodsClassName3;   // 상품타입
  String  sMallGoodsID;       // 판매상태
  String  sState;             //
  int     mNormalPrice;       //
  int     mStorePrice;
  int     mDisposePrice;
  int     mPromotePrice;
  int     mSalesPrice;
  String  rNowStock;          // 재고
  String  sShowStock;
  String  sLot;
  String  sLotMemo;

  String  sMainPicture;
  GoodsFiles? picInfo;
  List<CardPhotoItem> photoList = [];
  String descriptionImageUrl;
  double descriptionImageHeight;

  InfoGoods({
    this.descriptionImageUrl = "",
    this.descriptionImageHeight = 0,
    this.sGoodsClassName1 = "",
    this.sGoodsClassName2 = "",
    this.sGoodsClassName3 = "",
    this.sMallGoodsID="",
    this.sName="",
    this.sBarcode="",
    this.Maker="",
    this.sState="",
    this.rNowStock="",
    this.sLot="",
    this.sLotMemo="",
    this.mNormalPrice = 0,
    this.mStorePrice  = 0,
    this.mDisposePrice= 0,
    this.mPromotePrice= 0,
    this.mSalesPrice  = 0,
    this.sMainPicture="",
    this.picInfo,
    this.photoList = const [],
    this.sShowStock = "",
  });

  void setDisplayStock() {
    int rStock = 0;
    if(rNowStock.isNotEmpty) {
      rStock = double.parse(rNowStock).toInt();
    }
    sShowStock = "판매 가능";//"◎";
    if(rStock<1) {
      sShowStock = "재고 없음";
    }
  }

  Future <void> setDescriptionImage(BuildContext context) async {
    //descriptionImageUrl    = "https://wms.point-i.co.kr/files/S4573236195117.jpg";
    //descriptionImageHeight = await computeImageHeight(context, descriptionImageUrl);
  }

  void setPictInfoAddUrl() {
    photoList = [];
    if(picInfo!.sVideo.isNotEmpty) {
      photoList.add(CardPhotoItem(
          url: "$URL_IMAGE/${picInfo!.sVideo}",
          type: "v"));
    }

    if(picInfo!.sMainPicture.isNotEmpty) {
      photoList.add(CardPhotoItem(
          url: "$URL_IMAGE/${picInfo!.sMainPicture}",
          type: "p"));
    }

    if(picInfo!.sSubPic1.isNotEmpty) {
      photoList.add(CardPhotoItem(
          url: "$URL_IMAGE/${picInfo!.sSubPic1}",
          type: "p"));
    }

    if(picInfo!.sSubPic2.isNotEmpty) {
      photoList.add(CardPhotoItem(
          url: "$URL_IMAGE/${picInfo!.sSubPic2}",
          type: "p"));
    }

    if(picInfo!.sSubPic3.isNotEmpty) {
      photoList.add(CardPhotoItem(
          url: "$URL_IMAGE/${picInfo!.sSubPic3}",
          type: "p"));
    }

    if(picInfo!.sSubPic4.isNotEmpty) {
      photoList.add(CardPhotoItem(
          url: "$URL_IMAGE/${picInfo!.sSubPic4}",
          type: "p"));
    }
  }

  void computeSalesPrice() {
    mSalesPrice = 999999999;
    if(mPromotePrice>0) {
      mSalesPrice = mPromotePrice;
    }
    else {
      if (mPromotePrice > 0 && mSalesPrice > mPromotePrice) {
        mSalesPrice = mPromotePrice;
      }
      if (mNormalPrice > 0 && mSalesPrice > mNormalPrice) {
        mSalesPrice = mNormalPrice;
      }
      if (mStorePrice > 0 && mSalesPrice > mStorePrice) {
        mSalesPrice = mStorePrice;
      }
      if (mDisposePrice > 0 && mSalesPrice > mDisposePrice) {
        mSalesPrice = mDisposePrice;
      }
    }

    if(mSalesPrice == 999999999) {
      mSalesPrice = 0;
    }
    // print("mPromotePrice=$mPromotePrice, "
    //     "mNormalPrice=$mNormalPrice, "
    //     "mStorePrice=$mStorePrice "
    //     "==> mSalesPrice=$mSalesPrice");
  }

  factory InfoGoods.fromJson(Map<String, dynamic> jdata)
  {
    // if (kDebugMode) {
    //   var logger = Logger();
    //   logger.d(jdata);
    // }
    GoodsFiles picInfo = GoodsFiles();
    picInfo.sMainPicture = (jdata['sMainPicture'] != null)
        ? jdata['sMainPicture'].toString().trim() : "";
    picInfo.sSubPic1 = (jdata['sSubPic1'] != null)
        ? jdata['sSubPic1'].toString().trim() : "";
    picInfo.sSubPic2 = (jdata['sSubPic2'] != null)
        ? jdata['sSubPic2'].toString().trim() : "";
    picInfo.sSubPic3 = (jdata['sSubPic3'] != null)
        ? jdata['sSubPic3'].toString().trim() : "";
    picInfo.sSubPic4 = (jdata['sSubPic4'] != null)
        ? jdata['sSubPic4'].toString().trim() : "";
    picInfo.sVideo = (jdata['sVideo'] != null)
        ? jdata['sVideo'].toString().trim() : "";

    InfoGoods goods = InfoGoods(
      sName: (jdata['sName'] != null)
          ? jdata['sName'].toString().trim() : "",
      Maker: (jdata['Maker'] != null)
          ? jdata['Maker'].toString().trim() : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      sGoodsClassName3: (jdata['sGoodsClassName3'] != null)
            ? jdata['sGoodsClassName3'].toString().trim() : "",

      sGoodsClassName1: (jdata['sGoodsClassName1'] != null)
          ? jdata['sGoodsClassName1'].toString().trim() : "",


      sGoodsClassName2:(jdata['sGoodsClassName2'] != null)
            ? jdata['sGoodsClassName2'].toString().trim() : "",

      sMallGoodsID: (jdata['sMallGoodsID'] != null)
          ? jdata['sMallGoodsID'] : "",

      sState: (jdata['sState'] != null)
          ? jdata['sState'].toString().trim():"",

      sLot:(jdata['sLot'] != null)
          ? jdata['sLot'].toString().trim() : "",

      sLotMemo: (jdata['sLotMemo'] != null)
          ? jdata['sLotMemo'].toString().trim() : "",

      mNormalPrice: (jdata['mNormalPrice'] != null)
          ? double.parse(jdata['mNormalPrice'].toString().trim()).toInt() : 0,

      mStorePrice:(jdata['mStorePrice'] != null)
          ? double.parse(jdata['mStorePrice'].toString().trim()).toInt() : 0,

      mDisposePrice:(jdata['mDisposePrice'] != null)
          ? double.parse(jdata['mDisposePrice'].toString().trim()).toInt() : 0,

      mPromotePrice:(jdata['mPromotePrice'] != null)
          ? double.parse(jdata['mPromotePrice'].toString().trim()).toInt() : 0,

      rNowStock:(jdata['rNowStock'] != null)
          ? jdata['rNowStock'].toString().trim() : "",

      sMainPicture: (jdata['sMainPicture'] != null)
          ? jdata['sMainPicture'].toString().trim() : "",

      picInfo:picInfo,
    );

    goods.computeSalesPrice();
    goods.setDisplayStock();
    goods.setPictInfoAddUrl();
    return goods;
  }

  static List<InfoGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoGoods.fromJson(data);
    }).toList();
  }
}
