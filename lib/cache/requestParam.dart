import 'package:point/provider/sessionData.dart';

class RequestParam {
  int lPageNo;
  int lRowNo;
  String category;
  String isPromotion;
  String keyword;
  String sBarcode;
  String order;
  String order_dir;
  late SessionData session;

  String orderValue;
  String orderDesc;
  final List<String> orderList = <String>[
    "상품 이름순",
    "낮은 가격순",
    "높은 가격순",
    "최신 상품순",
  ];

  RequestParam({
    this.lPageNo = 1,
    this.lRowNo = 12,
    this.category = "",
    this.isPromotion = "",
    this.keyword = "",
    this.sBarcode= "",
    this.orderValue = "상품 이름순",
    this.orderDesc  = "상품 이름순으로 표시합니다.",
    this.order = "name",
    this.order_dir = "asc",
  });

  void setOrder(String value) {
    orderValue = value;
    print("setOrder():orderby=$orderValue");
    switch(orderValue) {
      case "상품 이름순":
        order = "name";
        order_dir = "asc";
        orderDesc  = "상품 이름순으로 표시합니다.";
        break;
      case "낮은 가격순":
        order = "price";
        order_dir = "asc";
        orderDesc  = "낮은 가격순으로 표시합니다.";
        break;
      case "높은 가격순":
        order = "price";
        order_dir = "desc";
        orderDesc  = "높은 가격순으로 표시합니다.";
        break;
      case "최신 상품순":
        order = "date";
        order_dir = "desc";
        orderDesc  = "최신 상품순으로 표시합니다.";
        break;
      default:
        order = "name";
        order_dir = "asc";
        orderDesc  = "상품 이름순으로 표시합니다.";
    }
  }

  @override
  String toString(){
    return 'RequestParam {'
        'lPageNo:$lPageNo, '
        'lRowNo:$lRowNo, '
        'category:$category, '
        'isPromotion:$isPromotion, '
        'order:$order, '
        '}';
  }

  void setSession(SessionData session) {
    this.session = session;
  }

  void setPromotion() {
    isPromotion = "Y";
  }

  void setCategory(String code) {
    category = code;
  }

  void setContentType(String contentType) {
    category = contentType;
  }

  void setKeyword(String word) {
    keyword = word;
  }

  void setBarcode(String barcode) {
    //keyword  = "";
    sBarcode = barcode;
  }

  Map<String, dynamic> toRequest({String keyword="request"}) {
    return toMap();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if(keyword.isNotEmpty) {
      map.addAll({'keyword': keyword});
    }
    if(sBarcode.isNotEmpty) {
      map.addAll({'sBarcode': sBarcode});
    }
    if(category.isNotEmpty) {
      map.addAll({'category': category});
    }
    if(isPromotion.isNotEmpty) {
      map.addAll({'isPromotion': isPromotion});
    }
    if(order.isNotEmpty) {
      map.addAll({'order': order});
    }
    if(order_dir.isNotEmpty) {
      map.addAll({'order_dir': order_dir});
    }
    map.addAll({'lPageNo': lPageNo.toString()});
    map.addAll({'lRowNo': lRowNo.toString()});
    return map;
  }
}
