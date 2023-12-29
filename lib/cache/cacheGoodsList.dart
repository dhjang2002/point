import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:point/cache/cacheBase.dart';
import 'package:point/cache/requestParam.dart';
import 'package:point/models/kItemGoodsList.dart';
import 'package:point/remote/remote.dart';

class CacheGoodList extends CacheBase{
  CacheGoodList() : super();

  Future <void> requestFrom({
    required BuildContext context,
    required bool first,
    required RequestParam param,
    }) async {

    isFirst = first;
    if(isFirst) {
      param.lPageNo = 1;
    }
    else
    {
      param.lPageNo = param.lPageNo+1;
    }

    if (kDebugMode) {
      print( "requestFrom: param -> ${param.toString()}");
    }


    loading = true;
    if(isFirst && cache.isNotEmpty) {
      hasMore = true;
      cache.clear();
    }

    notifyListeners();
    var items = await geItems(context, param);

    if(items.isNotEmpty) {
      cache = [
        ...cache,
        ...items,
      ];

      if(items.length<param.lRowNo) {
        hasMore = false;
      }
    }
    else {
      hasMore = false;
    }

    loading = false;
    notifyListeners();
  }

  Future<List<ItemGoodsList>> geItems(BuildContext context, RequestParam param) async {
    List<ItemGoodsList> items = [];
    await Remote.apiPost(
        context: context,
        session: param.session,
        method: "point/listGoods",
        params: param.toMap(),
        onResult: (dynamic data) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

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