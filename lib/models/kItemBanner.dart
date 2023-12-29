import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemBanner {
  int lBannerId;
  String sBannerFile;
  String sBannerTitle;
  String sBannerLink;
  String sPhoneNumber;
  String sFaxNumber;
  ItemBanner({
    this.lBannerId = 0,
    this.sBannerFile="",
    this.sBannerLink="",
    this.sBannerTitle ="",
    this.sPhoneNumber="",
    this.sFaxNumber ="",
  });

  static List<ItemBanner> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemBanner.fromJson(data);
    }).toList();
  }

  factory ItemBanner.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    return ItemBanner(
      lBannerId:(jdata['lBannerId'] != null)
          ? int.parse(jdata['lBannerId'].toString().trim()) : 0,

      sBannerTitle: (jdata['sBannerTitle'] != null)
          ? jdata['sBannerTitle'].toString().trim() : "",

      sBannerFile: (jdata['sBannerFile'] != null)
          ? jdata['sBannerFile'].toString().trim() : "",

      sBannerLink: (jdata['sBannerLink'] != null)
          ? jdata['sBannerLink'].toString().trim() : "",
      sPhoneNumber: (jdata['sPhoneNumber'] != null)
          ? jdata['sPhoneNumber'].toString().trim() : "",
      sFaxNumber: (jdata['sFaxNumber'] != null)
          ? jdata['sFaxNumber'].toString().trim() : "",
    );
  }

}
