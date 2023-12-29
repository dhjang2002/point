import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemStock {
  int lStoreID;
  String sStoreName;       // 매장명칭
  String sLot;             // 진열위치
  int rStoreStock;         // 재고수량

  ItemStock({
    this.lStoreID = 0,
    this.sStoreName="",
    this.rStoreStock=0,
    this.sLot ="",
  });

  static List<ItemStock> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStock.fromJson(data);
    }).toList();
  }

  factory ItemStock.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    return ItemStock(
      lStoreID:(jdata['lStoreID'] != null)
          ? int.parse(jdata['lStoreID'].toString().trim()) : 0,

      sStoreName: (jdata['sStoreName'] != null)
          ? jdata['sStoreName'].toString().trim() : "",

      sLot: (jdata['sLot'] != null)
          ? jdata['sLot'].toString().trim() : "",

      rStoreStock:(jdata['rStoreStock'] != null)
          ? int.parse(jdata['rStoreStock'].toString().trim()) : 0,
    );
  }

}
