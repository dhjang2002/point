class ItemGoodsList {
  int lGoodsId;
  String sName;
  String sGoodsClassName1;
  String sGoodsClassName2;
  String sGoodsClassName3;
  int mSalesPrice;
  int mStorePrice;
  int mNormalPrice;
  int mPromotePrice;
  int mDisposePrice;
  int rStoreStock;
  String sState;
  String Maker;
  String sMainPicture;
  String sShowStock;
  ItemGoodsList({

    this.lGoodsId=0,
    this.sName="",
    this.sGoodsClassName1 ="",
    this.sGoodsClassName2 = "",
    this.sGoodsClassName3 = "",
    this.mSalesPrice   = 0,
    this.mStorePrice   = 0,
    this.mNormalPrice  = 0,
    this.mPromotePrice = 0,
    this.mDisposePrice = 0,
    this.rStoreStock = 0,
    this.sState = "",
    this.Maker = "",
    this.sMainPicture = "",
    this.sShowStock = "",
  });

  void setDisplayStock() {
    sShowStock = "◎";
    if(rStoreStock<1) {
      sShowStock = "X";
    }
  }

  void computeSalesPrice() {
    mSalesPrice = 999999999;
    if(mPromotePrice>0) {
      mSalesPrice = mPromotePrice;
    }
    else {
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

  static List<ItemGoodsList> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemGoodsList.fromJson(data);
    }).toList();
  }

  factory ItemGoodsList.fromJson(Map<String, dynamic> jdata){

    ItemGoodsList item = ItemGoodsList(
      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sName: (jdata['sName'] != null)
          ? jdata['sName'].trim() : "",
      sGoodsClassName1: (jdata['sGoodsClassName1'] != null)
          ? jdata['sGoodsClassName1'].toString().trim() : "",
      sGoodsClassName2: (jdata['sGoodsClassName2'] != null)
          ? jdata['sGoodsClassName2'].toString().trim() : "",
      sGoodsClassName3: (jdata['sGoodsClassName3'] != null)
          ? jdata['sGoodsClassName3'].toString().trim() : "",

      mStorePrice: (jdata['mStorePrice'] != null)
          ? double.parse(jdata['mStorePrice'].toString().trim()).toInt() : 0,

      mNormalPrice: (jdata['mNormalPrice'] != null)
          ? double.parse(jdata['mNormalPrice'].toString().trim()).toInt() : 0,

      mPromotePrice: (jdata['mPromotePrice'] != null)
            ? double.parse(jdata['mPromotePrice'].toString().trim()).toInt() : 0,
      mDisposePrice:(jdata['mDisposePrice'] != null)
          ? double.parse(jdata['mDisposePrice'].toString().trim()).toInt() : 0,
      rStoreStock: (jdata['rStoreStock'] != null)
          ? double.parse(jdata['rStoreStock'].toString().trim()).toInt() : 0,
      sState: (jdata['sState'] != null)
          ? jdata['sState'].trim() : "",
      Maker: (jdata['Maker'] != null)
          ? jdata['Maker'].trim() : "",
      sMainPicture: (jdata['sMainPicture'] != null)
          ? jdata['sMainPicture'].trim() : "",
    );

    item.setDisplayStock();
    item.computeSalesPrice();
    return item;
  }
}
