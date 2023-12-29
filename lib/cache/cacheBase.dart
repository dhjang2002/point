import 'package:flutter/material.dart';

abstract class CacheBase with ChangeNotifier {
  var  cache = [];
  bool isFirst = true;
  bool loading = false;
  bool hasMore = true;

  CacheBase();

  void clear() {
    isFirst = true;
    loading = false;
    hasMore = true;
    if(cache.isNotEmpty) {
      cache.clear();
    }
  }
}