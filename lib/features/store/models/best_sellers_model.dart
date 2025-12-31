class CBestSellersModel {
  int _productId = 0;
  int _totalSales = 0;
  String _productName = "";
  double _unitSellingPrice = 0.0;

  CBestSellersModel(
    this._productId,
    this._productName,
    this._totalSales,
    this._unitSellingPrice,
  );

  //CBestSellersModel.withId(this._productName, this._quantity);

  static List<String> getHeaders() {
    return [
      'productId',
      'productName',
      'totalSales',
      'unitSellingPrice',
    ];
  }

  int get productId => _productId;
  String get productName => _productName;
  int get totalSales => _totalSales;
  double get unitSellingPrice => _unitSellingPrice;

  set productId(int newPid) {
    _productId = newPid;
  }

  set productName(String newPname) {
    _productName = newPname;
  }

  set totalSales(int newTotalSales) {
    if (newTotalSales >= 0) {
      _totalSales = newTotalSales;
    }
  }

  set unitSellingPrice(double newUnitSP) {
    _unitSellingPrice = newUnitSP;
  }

  // convert a SoldItemsModel Object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['productId'] = _productId;
    map['productName'] = _productName;
    map['totalSales'] = _totalSales;
    map['unitSellingPrice'] = _unitSellingPrice;

    return map;
  }

  // extract a SoldItemsModel object from a Map object
  CBestSellersModel.fromMapObject(Map<String, dynamic> map) {
    _productId = map['productId'];
    _productName = map['productName'];
    _totalSales = map['totalSales'];
    _unitSellingPrice = map['unitSellingPrice'];
  }
}
